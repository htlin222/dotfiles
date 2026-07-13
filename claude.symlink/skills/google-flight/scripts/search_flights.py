#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "fast-flights>=3.0.2",
#     "typing_extensions>=4.12",
# ]
# ///
"""Deterministic Google Flights search via raw HTTP GET — no browser, no GUI, no CSS.

Run with `uv run search_flights.py ...` — uv installs the pinned deps into an
ephemeral env on first run, nothing to set up by hand.

Built on the `fast-flights` library, which base64/protobuf-encodes the search
into Google Flights' `tfs` URL param and parses the JSON embedded in the
returned HTML. It never launches a browser or renders anything, so it's a lot
faster and lighter than driving a real page.

Known limitations (see SKILL.md for the full story):
  - A single call returns OUTBOUND leg options plus an aggregate round-trip
    price estimate, not a specific paired return-leg time. Google Flights'
    own UI is two-step (pick outbound, then see return options) and this
    library only automates the first step.
  - The parser can raise IndexError/TypeError on itineraries with unusual
    layouts (observed on some 2-stop long-haul routes). This is caught below
    and reported as a clear error rather than a stack trace.
  - Results can differ from what an interactive/logged-in browser session
    shows (Google varies results by session, locale, and IP). Treat prices
    as a fast first-pass estimate, not a quote — verify before booking.
"""

import argparse
import json
import sys
from datetime import datetime

# Mirrors fast_flights.types.Currency's Literal values (extracted from the
# library's own type hints) — validated here because the library silently
# echoes back whatever currency you ask for even if Google didn't honor it.
KNOWN_CURRENCIES = {
    "ALL", "DZD", "ARS", "AMD", "AWG", "AUD", "AZN", "BSD", "BHD", "BYN", "BMD", "BAM",
    "BRL", "GBP", "BGN", "CAD", "XPF", "CLP", "CNY", "COP", "CRC", "CUP", "CZK", "DKK",
    "DOP", "EGP", "EUR", "GEL", "HKD", "HUF", "ISK", "INR", "IDR", "IRR", "ILS", "JMD",
    "JPY", "JOD", "KZT", "KWD", "LBP", "MKD", "MYR", "MXN", "MDL", "MAD", "TWD", "NZD",
    "NOK", "OMR", "PKR", "PAB", "PEN", "PHP", "PLN", "QAR", "RON", "RUB", "SAR", "RSD",
    "SGD", "ZAR", "KRW", "SEK", "CHF", "THB", "TRY", "UAH", "AED", "USD", "VND",
}


def fail(message):
    print(json.dumps({"error": message}))
    sys.exit(1)


def validate_iata(code, flag):
    code = code.strip().upper()
    if len(code) != 3 or not code.isalpha():
        fail(f"{flag} must be a 3-letter IATA airport code, got {code!r}")
    return code


def validate_date(spec, flag):
    try:
        return datetime.strptime(spec, "%Y-%m-%d")
    except ValueError:
        fail(
            f"{flag} must be YYYY-MM-DD, got {spec!r} — fast-flights silently misinterprets "
            "malformed dates instead of rejecting them, so this is checked here rather than "
            "left to the library."
        )


def parse_window(spec, flag):
    if not spec:
        return None
    parts = spec.split("-")
    if len(parts) != 2:
        fail(f'{flag} must look like "HH:MM-HH:MM", got {spec!r}')
    try:
        start = datetime.strptime(parts[0].strip(), "%H:%M").time()
        end = datetime.strptime(parts[1].strip(), "%H:%M").time()
    except ValueError:
        fail(f'{flag} must look like "HH:MM-HH:MM" with valid 24h times, got {spec!r}')
    return (start, end)


def in_window(t, window):
    if window is None:
        return True
    start, end = window
    if start <= end:
        return start <= t <= end
    # window crosses midnight, e.g. "22:00-04:00" for red-eyes
    return t >= start or t <= end


def patch_resilient_parser():
    """Monkey-patch fast_flights' HTML/JSON parser to skip malformed result
    entries instead of aborting the whole parse.

    Root cause (found by sweeping ~20 routes): fast_flights.parser.parse_js
    does `price = k[1][0][1]` for every raw itinerary entry `k` in Google's
    payload, with no bounds check. Some entries (observed on TPE-LHR,
    TPE-BNE, TPE-JNB, and intermittently others) have no price data in that
    slot, and that one bad entry throws IndexError for the *entire* result
    set — even when the payload also contains other, perfectly good entries.

    This re-implements parse_js with the same per-entry logic, but wraps
    each entry in try/except and skips just that one instead of the whole
    response. If fast_flights changes its internal parser shape in a future
    release, this patch fails closed: the try/except below falls back to
    the library's own (unpatched) behavior rather than raising here.
    """
    try:
        import json as _json

        import fast_flights.parser as _parser
        from fast_flights.exceptions import FlightsNotFound
        from fast_flights.model import (
            Airline,
            Airport,
            Alliance,
            CarbonEmission,
            Flights,
            JsMetadata,
            SimpleDatetime,
            SingleFlight,
        )

        def resilient_parse_js(js):
            data = js.split("data:", 1)[1].rsplit(",", 1)[0]
            if data.endswith("errorHasStatus: true"):
                raise FlightsNotFound("no flights found; received error")
            payload = _json.loads(data)

            alliances, airlines_meta = [], []
            alliances_data, airlines_data = payload[7][1][0], payload[7][1][1]
            for code, name in alliances_data:
                alliances.append(Alliance(code=code, name=name))
            for code, name in airlines_data:
                airlines_meta.append(Airline(code=code, name=name))
            meta = JsMetadata(alliances=alliances, airlines=airlines_meta)

            flights = _parser.ResultList()
            skipped = 0
            if payload[3][0] is not None:
                for k in payload[3][0]:
                    try:
                        flight = k[0]
                        price = k[1][0][1]
                        sg_flights = [
                            SingleFlight(
                                from_airport=Airport(code=sf[3], name=sf[4]),
                                to_airport=Airport(code=sf[6], name=sf[5]),
                                departure=SimpleDatetime(date=sf[20], time=sf[8]),
                                arrival=SimpleDatetime(date=sf[21], time=sf[10]),
                                duration=sf[11],
                                plane_type=sf[17],
                            )
                            for sf in flight[2]
                        ]
                        extras = flight[22]
                        flights.append(
                            Flights(
                                type=flight[0],
                                price=price,
                                airlines=flight[1],
                                flights=sg_flights,
                                carbon=CarbonEmission(typical_on_route=extras[8], emission=extras[7]),
                            )
                        )
                    except (IndexError, TypeError, KeyError):
                        skipped += 1
                        continue

            flights.metadata = meta
            flights.parse_skipped = skipped
            return flights

        _parser.parse_js = resilient_parse_js
    except Exception as e:
        print(f"note: resilient-parser patch didn't apply ({type(e).__name__}: {e}); using stock fast_flights", file=sys.stderr)


class IncompleteLegData(Exception):
    """Raised when Google's payload left a leg's date/time fields as None.

    Observed on some long-haul routes (e.g. TPE-SYD) where fast-flights'
    parser successfully returns a Flights object but one of its legs has
    unresolved timing data. Callers should skip the offending result rather
    than crash the whole run.
    """


def to_time(simple_dt):
    h = simple_dt.time[0] if simple_dt.time else None
    m = simple_dt.time[1] if simple_dt.time and len(simple_dt.time) > 1 else 0
    if h is None:
        raise IncompleteLegData("missing departure/arrival hour")
    return datetime.strptime(f"{h:02d}:{m:02d}", "%H:%M").time()


def to_date_str(simple_dt):
    if not simple_dt.date or any(part is None for part in simple_dt.date):
        raise IncompleteLegData("missing date")
    y, mo, d = simple_dt.date
    return f"{y:04d}-{mo:02d}-{d:02d}"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--from", dest="from_airport", required=True, help="IATA origin code, e.g. TPE")
    ap.add_argument("--to", dest="to_airport", required=True, help="IATA destination code, e.g. MAD")
    ap.add_argument("--depart", required=True, help="Outbound date YYYY-MM-DD")
    ap.add_argument("--return", dest="return_date", help="Return date YYYY-MM-DD (omit for one-way)")
    ap.add_argument("--adults", type=int, default=1)
    ap.add_argument("--seat", default="economy", choices=["economy", "premium-economy", "business", "first"])
    ap.add_argument("--currency", default="", help="e.g. TWD, USD (blank = let Google decide)")
    ap.add_argument("--max-stops", type=int, help="Filter client-side by number of stops on the outbound leg")
    ap.add_argument("--depart-window", help='Filter outbound departure clock time, e.g. "06:00-12:00"')
    ap.add_argument("--arrive-window", help='Filter outbound arrival clock time, e.g. "12:00-18:00"')
    ap.add_argument("--limit", type=int, default=10, help="Max results to print, sorted by price")
    ap.add_argument("--format", choices=["json", "table"], default="table")
    args = ap.parse_args()

    args.from_airport = validate_iata(args.from_airport, "--from")
    args.to_airport = validate_iata(args.to_airport, "--to")
    if args.from_airport == args.to_airport:
        fail(f"--from and --to are both {args.from_airport!r} — nothing to search")

    depart_dt = validate_date(args.depart, "--depart")
    if args.return_date:
        return_dt = validate_date(args.return_date, "--return")
        if return_dt < depart_dt:
            fail(f"--return ({args.return_date}) is before --depart ({args.depart})")

    if not (1 <= args.adults <= 9):
        fail(f"--adults must be 1-9 (Google Flights' own UI cap), got {args.adults}")
    if args.limit < 1:
        fail(f"--limit must be >= 1, got {args.limit}")
    if args.max_stops is not None and args.max_stops < 0:
        fail(f"--max-stops must be >= 0, got {args.max_stops}")
    if args.currency:
        args.currency = args.currency.strip().upper()
        if args.currency not in KNOWN_CURRENCIES:
            fail(
                f"--currency {args.currency!r} isn't a currency fast-flights recognizes. "
                "The library would silently echo it back on the price label even if Google "
                "priced in something else — rejecting instead of risking a mislabeled price."
            )

    try:
        import fast_flights as ff
    except ImportError:
        print(
            json.dumps({"error": "fast-flights not installed. Run this file with `uv run search_flights.py ...`."}),
            file=sys.stderr,
        )
        sys.exit(2)

    patch_resilient_parser()

    flights = [ff.FlightQuery(date=args.depart, from_airport=args.from_airport, to_airport=args.to_airport)]
    trip = "one-way"
    if args.return_date:
        flights.append(ff.FlightQuery(date=args.return_date, from_airport=args.to_airport, to_airport=args.from_airport))
        trip = "round-trip"

    filt = ff.create_filter(
        flights=flights,
        seat=args.seat,
        trip=trip,
        passengers=ff.Passengers(adults=args.adults),
        currency=args.currency,
    )

    try:
        result = ff.get_flights(filt)
    except ff.FlightsNotFound:
        print(json.dumps({"error": "no flights found for this query"}))
        sys.exit(1)
    except Exception as e:
        print(
            json.dumps(
                {
                    "error": f"{type(e).__name__}: {e}",
                    "note": (
                        "fast-flights couldn't parse Google's response for this query. "
                        "--from/--to passed format validation but might not be a real/servable "
                        "airport code, or this hit a still-unresolved parser edge case. "
                        "Double-check the airport codes, then fall back to a real-browser tool "
                        "(e.g. kimi-webbridge) if the route is definitely valid."
                    ),
                }
            ),
            file=sys.stderr,
        )
        sys.exit(1)

    depart_window = parse_window(args.depart_window, "--depart-window")
    arrive_window = parse_window(args.arrive_window, "--arrive-window")

    rows = []
    skipped = getattr(result, "parse_skipped", 0)
    for f in result:
        # fast-flights' round-trip response only ever populates the outbound
        # itinerary here (see module docstring) — treat all legs as one leg
        # of travel from --from to --to, in order.
        outbound_legs = f.flights
        if not outbound_legs or outbound_legs[-1].to_airport.code != args.to_airport:
            continue

        try:
            first_dep = to_time(outbound_legs[0].departure)
            last_arr = to_time(outbound_legs[-1].arrival)
            depart_str = f"{to_date_str(outbound_legs[0].departure)} {first_dep}"
            arrive_str = f"{to_date_str(outbound_legs[-1].arrival)} {last_arr}"
        except IncompleteLegData:
            # Google's payload left this one result's timing unresolved.
            # Skip it rather than crash the whole search — see SKILL.md.
            skipped += 1
            continue

        stops = len(outbound_legs) - 1

        if args.max_stops is not None and stops > args.max_stops:
            continue
        if not in_window(first_dep, depart_window):
            continue
        if not in_window(last_arr, arrive_window):
            continue

        rows.append(
            {
                "price": f.price,
                "currency": args.currency or "default",
                "airlines": f.airlines,
                "stops": stops,
                "depart": depart_str,
                "arrive": arrive_str,
                "duration_min": sum(leg.duration for leg in outbound_legs),
                "route": " -> ".join(
                    [outbound_legs[0].from_airport.code] + [leg.to_airport.code for leg in outbound_legs]
                ),
            }
        )

    rows.sort(key=lambda r: r["price"])
    rows = rows[: args.limit]

    if not rows:
        print(
            json.dumps(
                {
                    "error": "no results matched the given filters",
                    "trip": trip,
                    "skipped_incomplete": skipped,
                }
            )
        )
        sys.exit(1)

    if args.format == "json":
        print(json.dumps({"results": rows, "skipped_incomplete": skipped}, ensure_ascii=False, indent=2))
    else:
        widths = [8, 6, 30, 6, 20, 20, 10]
        header = ["PRICE", "STOPS", "AIRLINES", "DUR(m)", "DEPART", "ARRIVE", "ROUTE"]
        print(" | ".join(h.ljust(w) for h, w in zip(header, widths)))
        for r in rows:
            print(
                " | ".join(
                    str(v).ljust(w)
                    for v, w in zip(
                        [
                            r["price"],
                            r["stops"],
                            ",".join(r["airlines"])[:28],
                            r["duration_min"],
                            r["depart"],
                            r["arrive"],
                            r["route"],
                        ],
                        widths,
                    )
                )
            )
        if trip == "round-trip":
            print(
                "\nNote: price is the round-trip total; times above are the OUTBOUND leg only. "
                "This library returns outbound options + total price in one call, mirroring "
                "Google Flights' own two-step UI (pick outbound, then see return options) — "
                "it does not resolve which specific return flight is paired with the total."
            )
        if skipped:
            print(
                f"\n{skipped} result(s) omitted: Google's payload left their timing data "
                "unresolved (seen on some long-haul routes, e.g. TPE-SYD). Not a sign the "
                "route has no flights — just that those specific results couldn't be parsed."
            )


if __name__ == "__main__":
    main()

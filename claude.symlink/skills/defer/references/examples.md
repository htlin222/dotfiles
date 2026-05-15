# Examples

## Arm a slash command

```
User: /defer 30 mins: /plan refactor the auth module
You:  Deferring for 30 min (id bn322rwmb). Will run: /plan refactor the auth module
[…30 min later, on wakeup…]
You:  Timer elapsed. Executing: /plan refactor the auth module
      [invokes the plan skill]
```

## Arm a plain prompt

```
User: /defer 45s: summarize the diff so far
You:  Deferring for 45 s (id ck891pa2v). Will run: summarize the diff so far
[…45 s later…]
You:  Timer elapsed. Executing: summarize the diff so far
      [produces the summary]
```

## List

```
User: /defer list
You:  id            remaining   prompt
      bn322rwmb     29:14       /plan refactor the auth module
      ck891pa2v     00:08       summarize the diff so far
```

`remaining` format:
- `MM:SS` when under one hour.
- `HH:MM:SS` for one hour or longer.
- `00:00` if the deadline has passed but the wakeup hasn't fired yet (rare; means the bash is mid-tick).
- Append ` (stale)` if the temp file exists but the corresponding background task no longer exists — offer to `rip` it.

If no files match: `No pending defers.`

## Cancel one

```
User: /defer cancel bn322rwmb
You:  Cancelled defer bn322rwmb.
```

If the id is unknown to TaskStop:

```
You:  No live defer with id bn322rwmb. State file removed if it existed.
```

## Cancel all

```
User: /defer cancel all
You:  Cancelled 2 defers: bn322rwmb, ck891pa2v.
```

## Invalid input

```
User: /defer 1.5h: summarize
You:  Decimal durations not supported. Use `/defer 90m: summarize`.

User: /defer 0s: foo
You:  Duration must be positive.

User: /defer 8h: long-running thing
You:  Defer cap is 6 h (21600 s). Use `/schedule` for longer waits.

User: /defer 30 mins:
You:  Empty deferred prompt. Provide a prompt after the `:`.

User: /defer make me a sandwich
You:  Couldn't parse. Expected `/defer <duration>: <prompt>` — e.g. `/defer 30m: /plan foo`.
```

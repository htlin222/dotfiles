#!/usr/bin/env python3
"""Wrap a recording into a self-contained, batteries-included HTML player.

The output is ONE .html file with the media inlined (base64 / embedded text),
so it opens offline and "just plays" with real play/pause controls.

Inputs by extension:
  .mp4 / .webm  -> HTML5 <video controls> (native play/pause/seek). Fully
                   self-contained (base64 data URI).
  .cast         -> by DEFAULT, rendered to the VHS look (Catppuccin theme +
                   JetBrains Mono via agg) as an HTML5 <video> — matches a VHS
                   video, with play/pause. Pass --player for asciinema-player
                   instead: SELECTABLE TEXT, and ALSO VHS-themed (same Catppuccin
                   palette + embedded JetBrains Mono). --cdn = player from CDN.
  .gif          -> auto-converted to MP4 via ffmpeg, then embedded as video
                   (GIFs cannot be paused; MP4 can). Use --as-img to keep the
                   GIF as a plain <img> instead.

Usage:
  gen_html.py demo.mp4 -o demo.html
  gen_html.py demo.gif -o demo.html          # converts to mp4 for play/pause
  gen_html.py session.cast -o demo.html          # offline; --cdn for smaller
"""
import argparse
import base64
import json
import subprocess
import sys
import tempfile
from pathlib import Path
from urllib.request import urlopen

PLAYER_CSS = "https://cdn.jsdelivr.net/npm/asciinema-player@3/dist/bundle/asciinema-player.css"
PLAYER_JS = "https://cdn.jsdelivr.net/npm/asciinema-player@3/dist/bundle/asciinema-player.min.js"

# Terminal palettes matching VHS's themes, so a .cast renders in the same look
# (Catppuccin Mocha/Latte) whether via agg (video) or asciinema-player. agg's
# default font is already JetBrains Mono — VHS's default.
THEME_COLORS = {
    "dark": {  # Catppuccin Mocha
        "fg": "#cdd6f4", "bg": "#1e1e2e",
        "ansi": ["#45475a", "#f38ba8", "#a6e3a1", "#f9e2af", "#89b4fa", "#f5c2e7",
                 "#94e2d5", "#bac2de", "#585b70", "#f38ba8", "#a6e3a1", "#f9e2af",
                 "#89b4fa", "#f5c2e7", "#94e2d5", "#a6adc8"]},
    "light": {  # Catppuccin Latte
        "fg": "#4c4f69", "bg": "#eff1f5",
        "ansi": ["#5c5f77", "#d20f39", "#40a02b", "#df8e1d", "#1e66f5", "#ea76cb",
                 "#179299", "#acb0be", "#6c6f85", "#d20f39", "#40a02b", "#df8e1d",
                 "#1e66f5", "#ea76cb", "#179299", "#bcc0cc"]},
}
# JetBrains Mono (the font VHS uses), latin subset, embedded for offline 1:1.
JBM_WOFF2 = {400: "https://cdn.jsdelivr.net/npm/@fontsource/jetbrains-mono/files/jetbrains-mono-latin-400-normal.woff2",
             700: "https://cdn.jsdelivr.net/npm/@fontsource/jetbrains-mono/files/jetbrains-mono-latin-700-normal.woff2"}
# CJK fallback after JetBrains Mono (which has no CJK — same as VHS behavior)
FONT_STACK = "'JBMono','PingFang TC','Hiragino Sans','Microsoft JhengHei','Noto Sans CJK TC',monospace"


def cast_theme(theme):
    """asciicast v2 header theme dict for agg."""
    c = THEME_COLORS[theme]
    return {"fg": c["fg"], "bg": c["bg"], "palette": ":".join(c["ansi"])}


def embed_jbm_fonts():
    """@font-face blocks with JetBrains Mono woff2 inlined; '' if offline."""
    faces = []
    for weight, url in JBM_WOFF2.items():
        try:
            b64 = base64.b64encode(urlopen(url).read()).decode()
        except Exception:
            return ""  # offline: fall back to the system font stack
        faces.append(
            f"@font-face{{font-family:'JBMono';font-weight:{weight};font-display:swap;"
            f"src:url(data:font/woff2;base64,{b64}) format('woff2')}}")
    return "".join(faces)

PAGE = """<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<style>
  html,body{{margin:0;background:#1e1e2e;display:flex;min-height:100vh;
    align-items:center;justify-content:center}}
  .wrap{{max-width:96vw}}
  video{{max-width:96vw;max-height:92vh;border-radius:8px;display:block}}
  img{{max-width:96vw;max-height:92vh;border-radius:8px;display:block}}
  /* player framed like the video: centered 16:9 box, rounded, letterboxed */
  #player{{width:min(94vw,1100px);aspect-ratio:1600/900;border-radius:8px;overflow:hidden}}
</style>{head_extra}</head>
<body><div class="wrap">{body}</div></body></html>
"""


def b64_data_uri(path, mime):
    return f"data:{mime};base64," + base64.b64encode(Path(path).read_bytes()).decode()


def gif_to_mp4(gif):
    out = Path(tempfile.gettempdir()) / (Path(gif).stem + "._gen.mp4")
    # yuv420p + even dimensions for broad browser compatibility
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(gif),
         "-movflags", "faststart", "-pix_fmt", "yuv420p",
         "-vf", "scale=trunc(iw/2)*2:trunc(ih/2)*2", str(out)],
        check=True, capture_output=True)
    return out


def video_html(path, mime, loop):
    uri = b64_data_uri(path, mime)
    # controls always on (play/pause/seek); loop adds autoplay+muted so it
    # starts moving on open, like a GIF, but stays pausable.
    extra = " autoplay muted loop playsinline" if loop else ""
    return f'<video controls{extra} src="{uri}"></video>'


def cast_to_styled_gif(cast_path, theme, font_size, speed):
    """Render a .cast to a GIF in the VHS look: embed the matching palette in
    the cast header so agg (JetBrains Mono by default) reproduces VHS's style.
    """
    lines = Path(cast_path).read_text().splitlines()
    hdr = json.loads(lines[0])
    hdr["theme"] = cast_theme(theme)
    lines[0] = json.dumps(hdr)
    tmp_cast = Path(tempfile.gettempdir()) / (Path(cast_path).stem + "._themed.cast")
    tmp_cast.write_text("\n".join(lines) + "\n")
    out = Path(tempfile.gettempdir()) / (Path(cast_path).stem + "._styled.gif")
    subprocess.run(
        ["agg", "--font-size", str(font_size), "--speed", str(speed),
         str(tmp_cast), str(out)], check=True, capture_output=True)
    tmp_cast.unlink(missing_ok=True)
    return out


def cast_html(path, use_cdn, theme):
    cast = Path(path).read_text()
    cast_b64 = base64.b64encode(cast.encode()).decode()
    if use_cdn:
        head = f'<link rel="stylesheet" href="{PLAYER_CSS}">'
        libs = f'<script src="{PLAYER_JS}"></script>'
    else:
        # default: embed the player so the file is fully offline
        css = urlopen(PLAYER_CSS).read().decode()
        js = urlopen(PLAYER_JS).read().decode()
        head = f"<style>{css}</style>"
        libs = f"<script>{js}</script>"
    # VHS look: embed JetBrains Mono + override the player's theme variables
    # (the player reads --term-font-family and --term-color-* on .ap-player).
    c = THEME_COLORS[theme]
    color_vars = (f"--term-color-foreground:{c['fg']};--term-color-background:{c['bg']};"
                  + "".join(f"--term-color-{i}:{hexv};" for i, hexv in enumerate(c["ansi"])))
    head += (f"<style>{embed_jbm_fonts()}"
             f"#player .ap-player{{--term-font-family:{FONT_STACK};{color_vars}}}</style>")
    # Inline via the documented {data: <cast string>} source form. Decode the
    # base64 as UTF-8 (atob alone yields Latin-1 bytes, mangling box-drawing
    # and non-ASCII text).
    body = f"""<div id="player"></div>{libs}
<script>
  var bytes = Uint8Array.from(atob("{cast_b64}"), c => c.charCodeAt(0));
  var data = new TextDecoder("utf-8").decode(bytes);
  AsciinemaPlayer.create(
    {{data: data}},
    document.getElementById('player'),
    {{autoPlay:true, controls:"auto", fit:"both"}});
</script>"""
    return head, body


def main():
    p = argparse.ArgumentParser(description="Wrap a recording into a play/pause HTML.")
    p.add_argument("input", help="path to .mp4/.webm/.cast/.gif")
    p.add_argument("-o", "--output", help="output .html (default: <input>.html)")
    p.add_argument("--title", default="agent demo")
    p.add_argument("--no-loop", action="store_true", help="video: don't autoplay-loop")
    p.add_argument("--as-img", action="store_true", help="gif: embed as <img>, no convert")
    p.add_argument("--cdn", action="store_true",
                   help="cast+player: load asciinema-player from CDN instead "
                        "of embedding it offline")
    p.add_argument("--player", action="store_true",
                   help="cast: use asciinema-player (SELECTABLE TEXT) instead of "
                        "the default video — also VHS-themed (Catppuccin + "
                        "embedded JetBrains Mono)")
    p.add_argument("--theme", choices=["dark", "light"], default="dark",
                   help="cast video: palette to match VHS (Catppuccin Mocha/Latte)")
    p.add_argument("--cast-font-size", type=int, default=28,
                   help="cast video: agg font size px (VHS-look ~ 28)")
    p.add_argument("--speed", type=float, default=1.0,
                   help="cast video: playback speed multiplier")
    a = p.parse_args()

    src = Path(a.input)
    ext = src.suffix.lower()
    out = Path(a.output) if a.output else src.with_suffix(".html")
    head_extra = ""

    if ext in (".mp4", ".webm"):
        mime = "video/mp4" if ext == ".mp4" else "video/webm"
        body = video_html(src, mime, loop=not a.no_loop)
    elif ext == ".gif":
        if a.as_img:
            body = f'<img src="{b64_data_uri(src, "image/gif")}" alt="{a.title}">'
        else:
            mp4 = gif_to_mp4(src)
            body = video_html(mp4, "video/mp4", loop=not a.no_loop)
            mp4.unlink(missing_ok=True)
    elif ext == ".cast":
        if a.player:
            head_extra, body = cast_html(src, a.cdn, a.theme)
        else:
            # default: VHS-look — themed agg GIF -> mp4 -> HTML5 video
            gif = cast_to_styled_gif(src, a.theme, a.cast_font_size, a.speed)
            mp4 = gif_to_mp4(gif)
            body = video_html(mp4, "video/mp4", loop=not a.no_loop)
            gif.unlink(missing_ok=True)
            mp4.unlink(missing_ok=True)
    else:
        sys.exit(f"unsupported input: {ext} (use .mp4/.webm/.cast/.gif)")

    out.write_text(PAGE.format(title=a.title, head_extra=head_extra, body=body))
    size_kb = out.stat().st_size / 1024
    print(f"wrote {out} ({size_kb:.0f} KB)", file=sys.stderr)


if __name__ == "__main__":
    main()

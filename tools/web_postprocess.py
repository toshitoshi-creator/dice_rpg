#!/usr/bin/env python3
"""Prepare a Godot Web export for Cloudflare Pages.

Cloudflare Pages rejects files larger than 25 MiB, but Godot's index.wasm is
~35 MB. This script:
  1. gzips index.wasm -> index.wasm.gz (~8 MB) and removes the original,
  2. writes wasm-gz-loader.js, which wraps window.fetch so the engine's
     request for *.wasm is served from *.wasm.gz and decompressed in the
     browser (DecompressionStream; Chrome 80+, Safari 16.4+, Firefox 113+),
  3. injects that loader into index.html before the engine script,
  4. adds a _headers file with sensible cache rules.

Usage: python3 tools/web_postprocess.py build/web
"""
import gzip
import pathlib
import shutil
import sys

LOADER_JS = r"""// Serves *.wasm from a gzipped copy (Cloudflare Pages has a 25 MiB file limit).
(function () {
  var nativeFetch = window.fetch.bind(window);
  var WASM_RE = /\.wasm(\?.*)?$/;
  function isGzip(bytes) {
    return bytes.length > 2 && bytes[0] === 0x1f && bytes[1] === 0x8b;
  }
  window.fetch = function (input, init) {
    var url = typeof input === 'string' ? input : (input && input.url) || '';
    if (!WASM_RE.test(url)) {
      return nativeFetch(input, init);
    }
    var gzUrl = url.replace(WASM_RE, '.wasm.gz$1');
    return nativeFetch(gzUrl, init).then(function (res) {
      if (!res.ok) {
        return nativeFetch(input, init); // no .gz (e.g. local export): use the plain file
      }
      return res.arrayBuffer().then(function (buf) {
        var bytes = new Uint8Array(buf);
        var headers = { 'Content-Type': 'application/wasm' };
        if (!isGzip(bytes)) {
          // Already decoded by the server/browser (Content-Encoding: gzip).
          return new Response(bytes, { status: 200, headers: headers });
        }
        if (typeof DecompressionStream === 'undefined') {
          throw new Error('このブラウザは未対応です。最新の Chrome / Safari / Firefox でお試しください。');
        }
        var stream = new Blob([bytes]).stream().pipeThrough(new DecompressionStream('gzip'));
        return new Response(stream).arrayBuffer().then(function (wasm) {
          return new Response(wasm, { status: 200, headers: headers });
        });
      });
    });
  };
})();
"""

HEADERS = """/*
  X-Content-Type-Options: nosniff

/index.html
  Cache-Control: no-cache

/
  Cache-Control: no-cache

/*.wasm.gz
  Content-Type: application/octet-stream
  Cache-Control: public, max-age=3600

/*.pck
  Cache-Control: public, max-age=3600
"""


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    out = pathlib.Path(sys.argv[1])
    html = out / "index.html"
    wasm = out / "index.wasm"
    if not html.exists() or not wasm.exists():
        sys.exit(f"index.html / index.wasm not found in {out}")

    with wasm.open("rb") as src, gzip.open(out / "index.wasm.gz", "wb", compresslevel=9) as dst:
        shutil.copyfileobj(src, dst)
    wasm.unlink()

    (out / "wasm-gz-loader.js").write_text(LOADER_JS, encoding="utf-8")
    text = html.read_text(encoding="utf-8")
    tag = '<script src="wasm-gz-loader.js"></script>'
    if tag not in text:
        marker = '<script src="index.js"></script>'
        if marker not in text:
            sys.exit("could not find the engine <script> tag in index.html")
        text = text.replace(marker, tag + "\n\t\t" + marker, 1)
    html.write_text(text, encoding="utf-8")
    (out / "_headers").write_text(HEADERS, encoding="utf-8")

    too_big = [p for p in out.iterdir() if p.stat().st_size > 25 * 1024 * 1024]
    for p in sorted(out.iterdir()):
        print(f"  {p.name:28s} {p.stat().st_size / 1024 / 1024:6.2f} MB")
    if too_big:
        sys.exit(f"files over Cloudflare's 25 MiB limit: {[p.name for p in too_big]}")


if __name__ == "__main__":
    main()

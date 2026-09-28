#!/usr/bin/env python3
"""Build the bundled Japanese UI font (assets/fonts/NotoSansJP-ExtraBold-subset.ttf).

Web builds cannot use system fonts, so the game ships its own font. The full
Noto Sans JP is ~5 MB, so we keep only what the game needs:
  ASCII, full-width forms, CJK punctuation, all hiragana / katakana,
  plus every other character that appears in scripts/ and scenes/.

When you add new kanji to UI text, re-run:
  pip install fonttools
  python3 tools/make_font_subset.py path/to/NotoSansJP-ExtraBold.ttf

The source TTF can be taken from Google Fonts (Noto Sans JP, SIL OFL 1.1),
e.g. the npm package @expo-google-fonts/noto-sans-jp (800ExtraBold).
"""
import pathlib
import sys

from fontTools import subset

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "fonts" / "NotoSansJP-ExtraBold-subset.ttf"


def collect_text() -> str:
    chars = set(chr(c) for c in range(0x20, 0x7F))
    for lo, hi in [(0x3000, 0x303F), (0x3040, 0x309F), (0x30A0, 0x30FF), (0xFF01, 0xFF5E)]:
        chars.update(chr(c) for c in range(lo, hi + 1))
    chars.update("…・「」『』！？：〜ー×÷")
    for pattern in ("scripts/**/*.gd", "scenes/**/*.tscn"):
        for path in ROOT.glob(pattern):
            chars.update(ch for ch in path.read_text(encoding="utf-8") if ord(ch) >= 0x80)
    return "".join(sorted(chars))


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    text = collect_text()
    options = subset.Options()
    options.layout_features = ["*"]
    options.name_IDs = ["*"]
    options.name_languages = ["*"]
    options.notdef_outline = True
    font = subset.load_font(sys.argv[1], options)
    subsetter = subset.Subsetter(options)
    subsetter.populate(text=text)
    subsetter.subset(font)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    subset.save_font(font, str(OUT), options)
    print(f"{len(text)} chars -> {OUT.relative_to(ROOT)} ({OUT.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    main()

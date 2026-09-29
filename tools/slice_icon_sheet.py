#!/usr/bin/env python3
"""Cut an icon sheet (a grid of items on a dark background) into separate icons.

    pip install pillow numpy
    python3 tools/slice_icon_sheet.py art/icon_sheets/swords.png assets/icons/swords --cols 5 --rows 10 --labels

- Finds the thin grid lines automatically (rows/columns do not need to be equal).
  If the lines cannot be found, the sheet is divided evenly.
- --labels removes the white number printed in the top-left corner of each cell.
- The background connected to the cell border is made transparent, so dark parts
  of the item itself (black armor etc.) stay opaque.
- Each icon is trimmed, centered on a square canvas and saved as 01.png, 02.png, ...
  in reading order (left to right, top to bottom).
"""
import argparse
import pathlib

import numpy as np
from PIL import Image, ImageDraw, ImageFilter


def find_lines(gray: np.ndarray, axis: int, count: int) -> list[int]:
    """Cell boundaries along one axis (count + 1 values, including both edges)."""
    prof = np.percentile(gray, 30, axis=axis)
    length = len(prof)
    base = np.median(prof)
    clusters: list[list[int]] = []
    for i in np.where(prof > base + 12)[0]:
        if clusters and i - clusters[-1][-1] <= 2:
            clusters[-1].append(int(i))
        else:
            clusters.append([int(i)])
    # Grid lines are thin; wide bright bands are items, not lines
    lines = [(c[0] + c[-1]) / 2 for c in clusters if c[-1] - c[0] <= 4]
    cell = length / count
    # Lines close to the sheet edge are the outer frame: use them as the first / last boundary
    start = max([0.0] + [x for x in lines if x <= cell * 0.4])
    end = min([float(length)] + [x for x in lines if x >= length - cell * 0.4])
    lines = [x for x in lines if cell * 0.4 < x < length - cell * 0.4]
    bounds = [start] + lines + [end]
    ok = len(bounds) == count + 1 and all(
        cell * 0.6 < b - a < cell * 1.4 for a, b in zip(bounds, bounds[1:]))
    if not ok:
        bounds = [start + k * (end - start) / count for k in range(count + 1)]
    return [int(round(b)) for b in bounds]


def erase_label(cell: Image.Image, bg: tuple) -> None:
    """Paint over the white number in the top-left corner."""
    w, h = cell.size
    box_w, box_h = int(w * 0.22), int(h * 0.2)
    a = np.asarray(cell).astype(int)[:box_h, :box_w]
    bright = a.min(axis=2) > 110
    low_sat = (a.max(axis=2) - a.min(axis=2)) < 40
    mask = Image.fromarray(((bright & low_sat) * 255).astype(np.uint8))
    mask = mask.filter(ImageFilter.MaxFilter(5))
    patch = Image.new("RGB", mask.size, bg)
    region = cell.crop((0, 0, box_w, box_h))
    region.paste(patch, (0, 0), mask)
    cell.paste(region, (0, 0))


def remove_background(cell: Image.Image, tolerance: float) -> Image.Image:
    a = np.asarray(cell).astype(float)
    h, w = a.shape[:2]
    border = np.concatenate([a[0], a[-1], a[:, 0], a[:, -1]])
    bg = np.median(border, axis=0)
    dist = np.sqrt(((a - bg) ** 2).sum(axis=2))
    like_bg = Image.fromarray(((dist < tolerance) * 255).astype(np.uint8)).copy()  # copy: fromarray images are read-only
    # Only background reachable from the border counts (flood fill)
    for x, y in [(x, 0) for x in range(w)] + [(x, h - 1) for x in range(w)] + \
                [(0, y) for y in range(h)] + [(w - 1, y) for y in range(h)]:
        if like_bg.getpixel((x, y)) == 255:
            ImageDraw.floodfill(like_bg, (x, y), 128)
    region = np.asarray(like_bg) == 128
    alpha = Image.fromarray(np.where(region, 0, 255).astype(np.uint8))
    alpha = alpha.filter(ImageFilter.GaussianBlur(0.8))
    out = cell.convert("RGBA")
    out.putalpha(alpha)
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("sheet")
    ap.add_argument("out_dir")
    ap.add_argument("--cols", type=int, default=5)
    ap.add_argument("--rows", type=int, default=10)
    ap.add_argument("--labels", action="store_true", help="erase the number in each cell's top-left corner")
    ap.add_argument("--size", type=int, default=128)
    ap.add_argument("--tolerance", type=float, default=24.0)
    ap.add_argument("--inset", type=int, default=4, help="pixels cut from each cell edge (grid line remains)")
    args = ap.parse_args()

    sheet = Image.open(args.sheet).convert("RGB")
    gray = np.asarray(sheet.convert("L")).astype(float)
    xs = find_lines(gray, 0, args.cols)
    ys = find_lines(gray, 1, args.rows)
    out = pathlib.Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    n = 0
    for r in range(args.rows):
        for c in range(args.cols):
            n += 1
            cell = sheet.crop((xs[c] + args.inset, ys[r] + args.inset, xs[c + 1] - args.inset, ys[r + 1] - args.inset))
            if args.labels:
                a = np.asarray(cell).astype(float)
                bg = tuple(int(v) for v in np.median(np.concatenate([a[-1], a[:, -1]]), axis=0))
                erase_label(cell, bg)
            icon = remove_background(cell, args.tolerance)
            bbox = icon.getchannel("A").point(lambda v: 255 if v > 24 else 0).getbbox()
            if bbox:
                icon = icon.crop(bbox)
            side = int(max(icon.size) * 1.08)
            canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
            canvas.paste(icon, ((side - icon.width) // 2, (side - icon.height) // 2))
            canvas.resize((args.size, args.size), Image.LANCZOS).save(out / f"{n:02d}.png", optimize=True)
    print(f"{n} icons -> {out}  (columns {xs}, rows {ys})")


if __name__ == "__main__":
    main()

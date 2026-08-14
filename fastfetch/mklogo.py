#!/usr/bin/env python3
"""Turn a photo of a planet into a transparent-background fastfetch logo.

    ./mklogo.py earth.jpg logo.png

Fits a circle to the lit limb, cuts everything outside it, and fades the night
side out with a smooth alpha ramp — so the logo sits on the terminal background
instead of on a black square, and a disc the frame clipped doesn't show a flat edge.

Needs python3-pil and python3-numpy. No ImageMagick CLI required.
"""
import sys
import numpy as np
from PIL import Image

SS = 4          # mask supersampling -> antialiased limb
OUT = 512       # output size, px
LO, HI = 6.0, 70.0   # luminance band the night side fades across


def fit_limb(lum):
    """Least-squares circle through the leftmost lit pixel of each row."""
    pts = []
    for y in range(0, lum.shape[0], 4):
        lit = np.where(lum[y] > 40)[0]
        if len(lit):
            pts.append((lit[0], y))
    x, y = np.array(pts, float).T
    A = np.stack([x, y, np.ones_like(x)], axis=1)
    D, E, F = np.linalg.lstsq(A, -(x**2 + y**2), rcond=None)[0]
    cx, cy = -D / 2, -E / 2
    r = np.sqrt(cx**2 + cy**2 - F)
    resid = np.median(np.abs(np.hypot(x - cx, y - cy) - r))
    print(f"circle ({cx:.0f}, {cy:.0f}) r={r:.0f}  median residual {resid:.1f}px")
    if resid > 3:
        print("WARNING: poor circle fit — check the result, the limb may be occluded")
    return cx, cy, r


def main(src_path, dst_path):
    src = np.asarray(Image.open(src_path).convert("RGB")).astype(np.uint8)
    H, W, _ = src.shape
    cx, cy, r = fit_limb(src.max(axis=2).astype(np.float32))

    # Square canvas over the whole disc. The frame may not cover all of it
    # (planet running off an edge), so start black-and-transparent and paste.
    side = int(round(2 * r))
    x0, y0 = int(round(cx - r)), int(round(cy - r))
    canvas = np.zeros((side, side, 3), np.uint8)
    sx0, sy0, sx1, sy1 = max(0, x0), max(0, y0), min(W, x0 + side), min(H, y0 + side)
    canvas[sy0 - y0:sy1 - y0, sx0 - x0:sx1 - x0] = src[sy0:sy1, sx0:sx1]

    g = (np.arange(side * SS) + 0.5) / SS - r
    disc = (np.hypot(g[None, :], g[:, None]) <= r - 0.5).astype(np.float32)
    disc = disc.reshape(side, SS, side, SS).mean(axis=(1, 3))
    covered = np.zeros((side, side), np.float32)
    covered[sy0 - y0:sy1 - y0, sx0 - x0:sx1 - x0] = 1.0   # uncovered rows are space
    disc *= covered

    t = np.clip((canvas.max(axis=2).astype(np.float32) - LO) / (HI - LO), 0, 1)
    alpha = disc * (t * t * (3 - 2 * t))                   # smoothstep

    rgba = np.dstack([canvas, (alpha * 255).astype(np.uint8)])

    # Center on what is actually VISIBLE, not on the disc. Fading out the night
    # side leaves dead space on whichever side it was, which would otherwise push
    # the crescent off-center inside fastfetch's logo box.
    ys, xs = np.where(rgba[:, :, 3] > 8)
    y1, y2, x1, x2 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    crop = rgba[y1:y2, x1:x2]
    box = max(crop.shape[0], crop.shape[1])
    sq = np.zeros((box, box, 4), np.uint8)
    oy, ox = (box - crop.shape[0]) // 2, (box - crop.shape[1]) // 2
    sq[oy:oy + crop.shape[0], ox:ox + crop.shape[1]] = crop
    print(f"visible {crop.shape[1]}x{crop.shape[0]} -> centered in {box}x{box}")

    Image.fromarray(sq, "RGBA").resize((OUT, OUT), Image.LANCZOS).save(dst_path)
    print(f"wrote {dst_path} ({OUT}x{OUT})")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])

/**
 * Generates assets/icon/app_icon.png — 1024×1024 Feddan brand icon.
 * Design: dark-green background, white squircle, green plant (stem + leaves + wheat head).
 * Pure Node.js, no external dependencies.
 */
const fs   = require('fs');
const path = require('path');
const zlib = require('zlib');

const W = 1024, H = 1024, C = W / 2;

// ── Colours ──────────────────────────────────────────────────────────────────
const BG    = [27, 94, 32];    // #1B5E20 outer background
const WHITE = [255, 255, 255];
const PLANT = [27, 94, 32];    // same dark green inside the white circle

// ── Shape predicates ─────────────────────────────────────────────────────────
function inSquircle(x, y) {
  const dx = (x - C) / 390, dy = (y - C) / 390;
  return dx * dx * dx * dx + dy * dy * dy * dy <= 1;
}

function inPlant(x, y) {
  const dx = x - C, dy = y - C;

  // Stem: tall vertical rectangle
  if (Math.abs(dx) <= 24 && dy >= -80 && dy <= 200) return true;

  // Left leaf: tilted ellipse (rotated 35°)
  {
    const ang = 35 * Math.PI / 180;
    const lx = (x - (C - 95)) * Math.cos(ang) + (y - (C - 30)) * Math.sin(ang);
    const ly = -(x - (C - 95)) * Math.sin(ang) + (y - (C - 30)) * Math.cos(ang);
    if ((lx / 130) ** 2 + (ly / 42) ** 2 <= 1) return true;
  }

  // Right leaf: tilted ellipse (mirrored)
  {
    const ang = -35 * Math.PI / 180;
    const lx = (x - (C + 95)) * Math.cos(ang) + (y - (C - 30)) * Math.sin(ang);
    const ly = -(x - (C + 95)) * Math.sin(ang) + (y - (C - 30)) * Math.cos(ang);
    if ((lx / 130) ** 2 + (ly / 42) ** 2 <= 1) return true;
  }

  // Wheat head: cluster of small circles at top of stem
  const seeds = [
    [0, -150, 38], [-30, -120, 30], [30, -120, 30],
    [-18, -90, 26],  [18, -90, 26],
  ];
  for (const [sx, sy, sr] of seeds) {
    if ((x - (C + sx)) ** 2 + (y - (C + sy)) ** 2 <= sr * sr) return true;
  }

  return false;
}

// ── Build raw pixel data (filter-byte + RGB per row) ─────────────────────────
const raw = Buffer.allocUnsafe(H * (1 + W * 3));

for (let y = 0; y < H; y++) {
  const base = y * (1 + W * 3);
  raw[base] = 0; // None filter
  for (let x = 0; x < W; x++) {
    const i = base + 1 + x * 3;
    let col;
    if (inSquircle(x, y)) {
      col = inPlant(x, y) ? PLANT : WHITE;
    } else {
      col = BG;
    }
    raw[i] = col[0]; raw[i + 1] = col[1]; raw[i + 2] = col[2];
  }
}

// ── Encode as PNG ─────────────────────────────────────────────────────────────
function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) {
    c ^= buf[i];
    for (let j = 0; j < 8; j++) c = (c >>> 1) ^ (0xedb88320 & -(c & 1));
  }
  return (c ^ 0xffffffff) >>> 0;
}

function pngChunk(type, data) {
  const typeBuf = Buffer.from(type, 'ascii');
  const len  = Buffer.allocUnsafe(4); len.writeUInt32BE(data.length);
  const crc  = Buffer.allocUnsafe(4); crc.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])));
  return Buffer.concat([len, typeBuf, data, crc]);
}

const ihdr = Buffer.allocUnsafe(13);
ihdr.writeUInt32BE(W, 0); ihdr.writeUInt32BE(H, 4);
ihdr[8] = 8; ihdr[9] = 2; ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;

const compressed = zlib.deflateSync(raw, { level: 6 });

const png = Buffer.concat([
  Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
  pngChunk('IHDR', ihdr),
  pngChunk('IDAT', compressed),
  pngChunk('IEND', Buffer.alloc(0)),
]);

const outPath = path.join(__dirname, '..', 'assets', 'icon', 'app_icon.png');
fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, png);
console.log(`✓ Icon written to ${outPath} (${(png.length / 1024).toFixed(0)} KB)`);

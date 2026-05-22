// oralb-caddy — parametric caddy for Oral-B electric toothbrushes,
// replacement brush heads, and a toothpaste tube. One or two rows of
// slots; each slot independently configured as a "body" (full brush),
// "head" (replacement head on a small peg), or "toothpaste" (tube).
//
// Each slot type carries its own floor depth, hole diameter and
// optional bottom peg so a row of bodies can be plain through-holes
// while a row of heads sits raised on pegs higher up in the caddy.
//
// Defaults are sensible Oral-B Pro / Vitality / iO-class values; every
// dimension is overridable. Author: John Mylchreest <jmylchreest@gmail.com>.
// MIT licensed.

/* [Output] */
// `all` shows the caddy + four feet side-by-side for plate arrangement.
render_target = "all";  // [caddy, feet, all]

/* [Layout] */
// Each inner list is one row of slots (front to back when viewed from
// the user side). Allowed types: "body", "head", "toothpaste", "".
//
//   1 row (matches the source 3MF):
//     slot_rows = [["body", "toothpaste", "body"]];
//
//   2 rows (heads at the back, bodies + toothpaste at the front):
//     slot_rows = [["body", "toothpaste", "body"],
//                  ["head", "head", "head"]];
//
//   Sparse layouts — leave a position empty with "":
//     slot_rows = [["body", "", "body"]];
slot_rows = [["body", "toothpaste", "body"]];

/* [Body slot — Oral-B brush body] */
// Oral-B Pro / Vitality / iO bodies are ~28 mm across at the grip.
// 30 mm hole gives ~1 mm clearance per side — slides in without play.
// Default: pass-through (floor 0). Set body_floor_h > 0 and body_peg_d
// > 0 to make the slot a closed cup with a peg in the base of the
// charging recess.
body_hole_d        = 30;
body_floor_h       = 0;
body_peg_d         = 0;     // 0 = no peg (brush stands on what's below the caddy)
body_peg_h         = 5;

/* [Head slot — Oral-B replacement brush head] */
// The replacement head has a hollow inner shaft ~5 mm Ø. A 4 mm peg
// gives a snug friction fit. By default the head slot is raised up the
// caddy (head_floor_h > 0) so the head sits visible near the top
// rather than buried in a deep cup.
head_hole_d        = 0;     // 0 = no through-hole (caddy is solid at head slots)
head_floor_h       = 30;    // mm of solid material below the peg base
head_pad_d         = 14;    // small disc the head's bottom rim rests on
head_pad_h         = 2;
head_peg_d         = 4.0;
head_peg_h         = 12;

/* [Toothpaste slot] */
// Tubes vary — 30 mm covers most family-size paste. Bump up for larger
// tubes, down for kids' / travel.
toothpaste_hole_d  = 32;
toothpaste_floor_h = 0;

/* [Caddy body] */
caddy_h            = 50;   // body height
slot_spacing_x     = 55;   // distance between slot centres along X
slot_spacing_y     = 50;   // distance between rows
caddy_wall_t       = 10;   // wall thickness from outermost slot edge to caddy edge
caddy_corner_r     = 12;   // outer corner radius

/* [Feet — separate pieces, glue or friction-fit into the caddy bottom] */
feet_d             = 8;    // foot diameter
feet_h             = 17;   // foot height
feet_inset         = 18;   // distance from caddy corner to foot centre
feet_count         = 4;    // 4 feet at corners (3 = triangle, not implemented)

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

// ---- per-type dispatchers ----

function _slot_hole_d(t)  =
      t == "body"       ? body_hole_d
    : t == "head"       ? head_hole_d
    : t == "toothpaste" ? toothpaste_hole_d
    :                     0;

function _slot_floor_h(t) =
      t == "body"       ? body_floor_h
    : t == "head"       ? head_floor_h
    : t == "toothpaste" ? toothpaste_floor_h
    :                     0;

function _slot_peg_d(t)   =
      t == "body" ? body_peg_d
    : t == "head" ? head_peg_d
    :               0;

function _slot_peg_h(t)   =
      t == "body" ? body_peg_h
    : t == "head" ? head_peg_h
    :               0;

function _slot_pad_d(t)   = t == "head" ? head_pad_d : 0;
function _slot_pad_h(t)   = t == "head" ? head_pad_h : 0;

// Effective footprint diameter — used to size the caddy so every slot
// has enough wall around it.
function _slot_footprint_d(t) =
    max(_slot_hole_d(t), _slot_pad_d(t), _slot_peg_d(t));

// ---- derived ----
num_rows = len(slot_rows);
max_cols = max([for (row = slot_rows) len(row)]);
max_footprint = max([
    for (row = slot_rows)
        for (t = row)
            if (_slot_footprint_d(t) > 0) _slot_footprint_d(t)
]);

caddy_w = (max_cols - 1) * slot_spacing_x + max_footprint + 2 * caddy_wall_t;
caddy_d = (num_rows - 1) * slot_spacing_y + max_footprint + 2 * caddy_wall_t;

function _slot_xy(col, row) = [
    col * slot_spacing_x - (max_cols - 1) * slot_spacing_x / 2,
    row * slot_spacing_y - (num_rows - 1) * slot_spacing_y / 2
];

// ---- shapes ----

module rounded_box(w, d, h, r) {
    rr = min(r, min(w, d) / 2 - 0.001);
    hull() {
        for (xi = [-1, 1])
            for (yi = [-1, 1])
                translate([xi * (w / 2 - rr), yi * (d / 2 - rr), 0])
                    cylinder(r = rr, h = h);
    }
}

// Per-slot additive features (pad + peg) — built relative to the slot
// centre at Z=0 (the caddy's bottom face). Pad/peg rise from
// Z = floor_h.
module _slot_additions(t) {
    floor_h = _slot_floor_h(t);
    pad_d   = _slot_pad_d(t);
    pad_h   = _slot_pad_h(t);
    peg_d   = _slot_peg_d(t);
    peg_h   = _slot_peg_h(t);

    if (pad_d > 0 && pad_h > 0)
        translate([0, 0, floor_h])
            cylinder(d = pad_d, h = pad_h);
    if (peg_d > 0 && peg_h > 0)
        translate([0, 0, floor_h + pad_h])
            cylinder(d = peg_d, h = peg_h);
}

// Per-slot subtractive features (through-hole / cup). Hole starts at
// Z = floor_h and goes up through the caddy top.
module _slot_subtractions(t) {
    hole_d  = _slot_hole_d(t);
    floor_h = _slot_floor_h(t);
    if (hole_d > 0)
        translate([0, 0, floor_h - 0.01])
            cylinder(d = hole_d, h = caddy_h - floor_h + 0.02);
}

module caddy() {
    difference() {
        union() {
            // Main caddy block, X centred, Y centred, Z = 0 to caddy_h.
            translate([0, 0, 0])
                rounded_box(caddy_w, caddy_d, caddy_h, caddy_corner_r);
            // Per-slot additions (head pad + peg, body peg, etc.)
            for (j = [0 : num_rows - 1])
                for (i = [0 : len(slot_rows[j]) - 1]) {
                    p = _slot_xy(i, j);
                    translate([p[0], p[1], 0])
                        _slot_additions(slot_rows[j][i]);
                }
        }
        // Per-slot subtractions (through-holes / cups).
        for (j = [0 : num_rows - 1])
            for (i = [0 : len(slot_rows[j]) - 1]) {
                p = _slot_xy(i, j);
                translate([p[0], p[1], 0])
                    _slot_subtractions(slot_rows[j][i]);
            }
    }
}

module foot() {
    cylinder(d = feet_d, h = feet_h);
}

module feet_arrangement() {
    // Lay the four feet out in a 2 × 2 grid matching the caddy's corner
    // positions, with the configured inset. Prints on a flat bed.
    fx = caddy_w / 2 - feet_inset;
    fy = caddy_d / 2 - feet_inset;
    for (xi = [-1, 1])
        for (yi = [-1, 1])
            translate([xi * fx, yi * fy, 0]) foot();
}

// ---- output ----
if (render_target == "caddy") {
    caddy();
} else if (render_target == "feet") {
    feet_arrangement();
} else if (render_target == "all") {
    // Caddy on the right, feet laid out to its left for slicer plate
    // arrangement. The feet are printed separately and glued (or
    // friction-fit into a base recess if you add one).
    caddy();
    translate([-caddy_w / 2 - feet_inset * 4, 0, 0])
        feet_arrangement();
}

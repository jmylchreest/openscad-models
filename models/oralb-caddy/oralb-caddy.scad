// oralb-caddy — parametric stadium-prism caddy for Oral-B electric
// toothbrushes, replacement brush heads, and a toothpaste tube. The
// caddy is a solid oval (stadium-prism) block; brushes slot in through
// cylindrical tunnels that pierce the prism along its depth. Each slot
// independently picks a type — "body" (through-hole + small charging-
// recess peg), "head" (shallow recess + tall retention peg) or
// "toothpaste" (through-hole). The caddy sits on four splayed cone
// feet with an adhesive-rubber-foot recess underneath.
//
// Coordinates are USE ORIENTATION:
//   X — long axis (left ↔ right when standing on the counter)
//   Y — depth   (front ↔ back)
//   Z — vertical (brushes stand UP through Z)
// Bambu / OrcaSlicer will likely want the caddy printed on its side
// (rotate 90° on X in the slicer) — that's the orientation in the
// source 3MF's print plate.
//
// Defaults are sensible Oral-B Pro / Vitality / iO-class values; every
// dimension is overridable.
//
// Author: John Mylchreest <jmylchreest@gmail.com>. MIT licensed.

/* [Output] */
// `all` shows the caddy + four feet side-by-side for plate arrangement.
// `assembled` shows the caddy with the feet inserted at the splayed
// angles — visualisation only, not for slicing.
render_target = "all";  // [caddy, feet, all, assembled]

/* [Layout] */
// Each inner list is one row of slots. Multiple rows arrange front-to-
// back (different Y positions). Allowed types: "body", "head",
// "toothpaste", "".
//
//   1 row (matches the source 3MF):
//     slot_rows = [["body", "toothpaste", "body"]];
//
//   2 rows (heads in front, brushes + paste in back):
//     slot_rows = [["head", "head", "head"],
//                  ["body", "toothpaste", "body"]];
//
//   Sparse — leave a position empty with "":
//     slot_rows = [["body", "", "body"]];
slot_rows = [["body", "toothpaste", "body"]];

/* [Caddy frame — the stadium-prism block] */
caddy_w        = 175;  // overall width along X (long axis of the stadium)
caddy_d        = 60;   // overall depth along Y (short axis of the stadium)
caddy_h        = 50;   // overall height along Z (brush passes through)
// Outer corner radius in XY (the footprint). caddy_d/2 = full oval
// stadium shape; smaller values give a rounded rectangle.
corner_r       = 30;

/* [Body slot — Oral-B brush body] */
// Oral-B Pro / Vitality / iO bodies are ~28 mm across. 30 mm hole gives
// ~1 mm clearance per side. Bottom is solid by default with a small
// charging-recess peg that engages the brush base for stability — set
// body_bottom_hole_d > 0 to make it a full pass-through instead.
body_top_hole_d    = 30;
body_bottom_hole_d = 0;     // 0 = solid bottom (brush rests on it)
body_peg_d         = 3.0;   // small peg into the brush's charging recess
body_peg_h         = 5.0;

/* [Head slot — Oral-B replacement brush head] */
// Replacement heads have a hollow shaft ~5 mm Ø; a 4 mm peg gives a
// snug friction fit. Top hole sized for the head's body so the
// bristles sit just above the caddy with the shaft engaged on the peg.
head_top_hole_d    = 14;
head_bottom_hole_d = 0;     // 0 = solid bottom; required for a peg
head_peg_d         = 4.0;
head_peg_h         = 25;    // long peg — fills the head's hollow shaft

/* [Toothpaste slot] */
// Tubes vary — 32 mm covers most family-size tubes. Pass-through by
// default so the tube cap rests on the counter.
toothpaste_top_hole_d    = 32;
toothpaste_bottom_hole_d = 32;
toothpaste_peg_d         = 0;
toothpaste_peg_h         = 0;

/* [Slot positions] */
slot_spacing_x = 55;  // distance between slot centres along X
slot_spacing_y = 30;  // distance between rows (Y), only matters with 2 rows

/* [Feet — splayed truncated cones with adhesive recess] */
// Each foot is a truncated cone, narrow at the bottom (touches the
// counter) and wide at the top (inserts into a socket in the caddy).
// The bottom face has a recess for a stick-on rubber foot.
feet_top_d            = 9;    // wide end (caddy-facing)
feet_bottom_d         = 5.5;  // narrow end (counter-facing)
feet_h                = 17;   // overall height
feet_recess_d         = 5;    // adhesive rubber foot diameter
feet_recess_h         = 0.2;  // recess depth (≈ adhesive backing thickness)
feet_rim_t            = 0.4;  // rim thickness flaring out around the recess

/* [Feet layout — only used by `assembled` render] */
// Four feet sit at the four corners of the caddy's bottom face. They
// can be splayed by `feet_angle` (off-vertical tilt), with `feet_rotation_delta`
// rotating each foot around its own vertical axis so a tapered or non-
// round profile presents at the desired angle.
//   Foot 1 (back-left):   tilt = +A,  rotation = -Δ
//   Foot 2 (back-right):  tilt = -A,  rotation = +Δ
//   Foot 3 (front-left):  tilt = +A,  rotation = 180 - Δ
//   Foot 4 (front-right): tilt = -A,  rotation = 180 + Δ
// (An angle of 0 makes rotation visually irrelevant for a round cone.)
feet_inset_x          = 18;   // distance from caddy edge to foot centre (X)
feet_inset_y          = 12;   // same in Y
feet_angle            = 0;    // tilt magnitude (degrees) — try 20 for splay
feet_rotation_delta   = 0;    // rotation delta around Z (degrees)

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

// ---- per-type dispatchers ----

function _slot_top_hole_d(t)    =
      t == "body"       ? body_top_hole_d
    : t == "head"       ? head_top_hole_d
    : t == "toothpaste" ? toothpaste_top_hole_d
    :                     0;

function _slot_bottom_hole_d(t) =
      t == "body"       ? body_bottom_hole_d
    : t == "head"       ? head_bottom_hole_d
    : t == "toothpaste" ? toothpaste_bottom_hole_d
    :                     0;

function _slot_peg_d(t)         =
      t == "body"       ? body_peg_d
    : t == "head"       ? head_peg_d
    : t == "toothpaste" ? toothpaste_peg_d
    :                     0;

function _slot_peg_h(t)         =
      t == "body"       ? body_peg_h
    : t == "head"       ? head_peg_h
    : t == "toothpaste" ? toothpaste_peg_h
    :                     0;

// ---- derived ----
num_rows = len(slot_rows);
max_cols = max([for (row = slot_rows) len(row)]);

function _slot_xy(col, row) = [
    col * slot_spacing_x - (max_cols - 1) * slot_spacing_x / 2,
    row * slot_spacing_y - (num_rows - 1) * slot_spacing_y / 2
];

// ---- 2D helpers ----

module rounded_rect_2d(w, h, r) {
    rr = min(r, min(w, h) / 2 - 0.001);
    if (rr <= 0)
        square([w, h], center = true);
    else
        offset(r = rr) offset(r = -rr) square([w, h], center = true);
}

// ---- caddy geometry ----

// Solid stadium prism — 2D stadium footprint in XY (caddy_w × caddy_d),
// extruded upward by caddy_h.
module _outer_solid() {
    linear_extrude(height = caddy_h)
        rounded_rect_2d(caddy_w, caddy_d, corner_r);
}

// Subtractive features for every slot: top hole (from above) + optional
// bottom hole (if the slot is pass-through).
module _slot_subtractions() {
    for (j = [0 : num_rows - 1])
        for (i = [0 : len(slot_rows[j]) - 1]) {
            t = slot_rows[j][i];
            p = _slot_xy(i, j);
            top_d = _slot_top_hole_d(t);
            bot_d = _slot_bottom_hole_d(t);

            if (top_d > 0 && bot_d > 0 && top_d == bot_d) {
                // Pure pass-through — single cylinder through the whole height.
                translate([p[0], p[1], -0.01])
                    cylinder(d = top_d, h = caddy_h + 0.02);
            } else {
                if (top_d > 0)
                    translate([p[0], p[1], -0.01])
                        cylinder(d = top_d, h = caddy_h + 0.02);
                if (bot_d > 0)
                    translate([p[0], p[1], -0.01])
                        cylinder(d = bot_d, h = caddy_h + 0.02);
            }
        }
}

// Additive features: bottom-sitting pegs (head retention, body charging
// recess). These are placed AFTER the slot subtractions so they survive.
module _slot_additions() {
    for (j = [0 : num_rows - 1])
        for (i = [0 : len(slot_rows[j]) - 1]) {
            t = slot_rows[j][i];
            p = _slot_xy(i, j);
            peg_d = _slot_peg_d(t);
            peg_h = _slot_peg_h(t);
            bot_d = _slot_bottom_hole_d(t);

            // Only attach pegs to slots with a solid bottom (no through-hole).
            if (peg_d > 0 && peg_h > 0 && bot_d == 0)
                translate([p[0], p[1], 0])
                    cylinder(d = peg_d, h = peg_h);
        }
}

module caddy() {
    union() {
        difference() {
            _outer_solid();
            _slot_subtractions();
        }
        _slot_additions();
    }
}

// ---- foot ----

// One foot — truncated cone with a recess on the bottom (z=0 face) for
// an adhesive rubber foot. The recess sits inside a rim that flares
// slightly wider than feet_bottom_d so the foot has a small flange at
// its base — the rim doubles as a stop against the counter and a wall
// around the adhesive.
//
// Geometry, bottom to top (Z axis):
//   z = 0                       — flange face, OD = feet_bottom_d + 2*feet_rim_t
//   z = feet_recess_h           — top of flange = start of tapered cone
//   z = feet_h                  — top of cone, OD = feet_top_d
//
// Recess: cylinder of feet_recess_d Ø, feet_recess_h deep, into the
// bottom face.
module foot_solo() {
    flange_d = feet_bottom_d + 2 * feet_rim_t;

    difference() {
        union() {
            // Flange disc at the very bottom (rim).
            cylinder(d = flange_d, h = feet_recess_h);
            // Truncated cone above the flange.
            translate([0, 0, feet_recess_h])
                cylinder(d1 = feet_bottom_d,
                         d2 = feet_top_d,
                         h  = feet_h - feet_recess_h);
        }
        // Adhesive recess — bites into the flange from underneath.
        translate([0, 0, -0.01])
            cylinder(d = feet_recess_d, h = feet_recess_h + 0.01);
    }
}

// Four feet, side-by-side on the bed for printing (no tilt).
module feet_for_print() {
    flange_d = feet_bottom_d + 2 * feet_rim_t;
    spacing  = max(feet_top_d, flange_d) + 4;
    for (i = [0 : 3])
        translate([(i - 1.5) * spacing, 0, 0])
            foot_solo();
}

// Position one foot at a corner of the caddy bottom, tilted by `tilt`
// degrees around the corner's local outward axis and pre-rotated by
// `rot` degrees around Z.
//
// `x_sign`, `y_sign` ∈ {-1, +1} pick the corner (sign = sign of the
// corner's X/Y position). The local outward axis depends on the corner.
module _foot_at_corner(x_sign, y_sign, tilt, rot) {
    cx = x_sign * (caddy_w / 2 - feet_inset_x);
    cy = y_sign * (caddy_d / 2 - feet_inset_y);

    translate([cx, cy, 0])
        rotate([0, 0, rot])
            rotate([0, tilt, 0])
                // Bring the foot's flange face to the caddy bottom and
                // hang it underneath.
                translate([0, 0, -feet_h])
                    foot_solo();
}

// All four feet at the splayed positions (visualisation only).
module feet_assembled() {
    A = feet_angle;
    D = feet_rotation_delta;
    // Indexing per spec: 1=BL, 2=BR, 3=FL, 4=FR.
    //   1 (back-left ,  -X, +Y): tilt = +A, rot = -D
    //   2 (back-right, +X, +Y): tilt = -A, rot = +D
    //   3 (front-left, -X, -Y): tilt = +A, rot = 180 - D
    //   4 (front-right,+X, -Y): tilt = -A, rot = 180 + D
    _foot_at_corner(-1, +1, +A,        -D);
    _foot_at_corner(+1, +1, -A,        +D);
    _foot_at_corner(-1, -1, +A, 180 - D);
    _foot_at_corner(+1, -1, -A, 180 + D);
}

// ---- output ----
if (render_target == "caddy") {
    caddy();
} else if (render_target == "feet") {
    feet_for_print();
} else if (render_target == "all") {
    caddy();
    translate([-caddy_w / 2 - 30, 0, 0])
        feet_for_print();
} else if (render_target == "assembled") {
    caddy();
    feet_assembled();
}

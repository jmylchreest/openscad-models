// oralb-caddy — parametric stadium-prism caddy for Oral-B electric
// toothbrushes, replacement brush heads, and a toothpaste tube. The
// caddy is a solid oval (stadium-prism) block; brushes drop in through
// vertical slot tunnels in the top. Each slot type carries its own
// diameter, floor thickness and peg — "body" (through-hole + small
// charging-recess peg), "head" (shallow recess + tall retention peg)
// or "toothpaste" (through-hole). Four splay-able tapered feet glue
// into keyed sockets on the bottom face.
//
// Coordinates are USE ORIENTATION:
//   X — width  (long axis of the stadium silhouette, left ↔ right)
//   Y — depth  (front ↔ back, the extrusion axis)
//   Z — height (vertical, brushes stand UP through Z)
// The OUTER SHAPE is a stadium PRISM:
//   - 2D stadium drawn in XZ (caddy_w × caddy_h) — this is the front
//     silhouette you actually see when the caddy is on the counter
//   - extruded along Y by caddy_d
//   - corner_r = caddy_h/2 gives the full oval; less = rounded rectangle
// Slot tunnels still go through Z — the brushes drop in from the top
// through the flat top strip of the stadium and rest on (or sit on a
// peg in) the slot floor.
//
// Author: John Mylchreest <jmylchreest@gmail.com>. MIT licensed.

/* [Output] */
// `all` shows the caddy + four feet on a virtual plate.
// `assembled` shows the caddy with the feet inserted (visualisation).
render_target = "all";  // [caddy, feet, all, assembled]

/* [Layout] */
// Each inner list is one row of slots, arranged front-to-back along Y.
// Allowed types: "body", "head", "toothpaste", "".
//
//   1 row (matches the source 3MF):
//     slot_rows = [["body", "toothpaste", "body"]];
//
//   2 rows (heads in front, brushes + paste in back):
//     slot_rows = [["head", "head", "head"],
//                  ["body", "toothpaste", "body"]];
slot_rows = [["body", "toothpaste", "body"]];

/* [Caddy frame — the stadium-prism block] */
caddy_w   = 175;  // X — long axis of the stadium silhouette
caddy_h   = 50;   // Z — short axis of the stadium (visible height)
caddy_d   = 60;   // Y — extrusion depth (front-to-back)
corner_r  = 25;   // outer corner radius in XZ (caddy_h/2 = full oval)

/* [Body slot — Oral-B brush body] */
// Bodies are ~28 mm — 30 mm hole gives ~1 mm clearance per side. A 3 mm
// floor under the brush stops it falling through; a tiny peg engages
// the brush's charging-contact recess.
body_hole_d   = 30;
body_floor_h  = 3;    // solid floor thickness under the brush (0 = through-hole)
body_peg_d    = 3.0;  // small peg into the brush's charging recess
body_peg_h    = 2.0;

/* [Head slot — Oral-B replacement brush head] */
// Heads have a hollow shaft ~5 mm Ø; a 4 mm peg gives a snug fit. A
// thicker floor (10 mm) keeps the peg base stable.
head_hole_d   = 14;
head_floor_h  = 10;
head_peg_d    = 4.0;
head_peg_h    = 25;   // tall — fills the head's hollow shaft

/* [Toothpaste slot] */
// Pass-through so the tube rests on the counter underneath.
toothpaste_hole_d   = 32;
toothpaste_floor_h  = 0;   // 0 = through-hole
toothpaste_peg_d    = 0;
toothpaste_peg_h    = 0;

/* [Slot positions] */
slot_spacing_x = 55;  // distance between slot centres along X
slot_spacing_y = 30;  // distance between rows along Y (matters for ≥2 rows)

/* [Feet — splay-able tapered cones with adhesive-foot recess] */
// Each foot is a truncated cone, narrow at the bottom and wide at the
// top. The top half plugs into a socket on the caddy bottom. The
// bottom has a rim around a recess sized for a stick-on rubber foot.
feet_top_d            = 9;    // wide end (plugs into the caddy)
feet_bottom_d         = 5.5;  // narrow end (rests on the counter)
feet_h                = 17;   // overall height of the foot
feet_recess_d         = 5;    // adhesive rubber foot diameter
feet_recess_h         = 0.2;  // recess depth (≈ adhesive thickness)
feet_rim_t            = 0.4;  // flange flaring out around the recess

/* [Foot ↔ caddy joint] */
// Caddy bottom carries four cylindrical sockets, each with a small
// rectangular keying notch. The foot's top is sized for the cylindrical
// part (with feet_socket_clear total play); a matching notch on the
// foot's top wedges into the socket's slot. This rotationally aligns
// the foot (so a tilted foot lands at the right angle) and gives the
// glue a mechanical key as well as adhesive bond.
feet_socket_h         = 3;    // socket depth (foot insertion length)
feet_socket_clear     = 0.5;  // total Ø clearance — socket Ø = feet_top_d + this
feet_notch_w          = 1.5;  // tangential width of the notch
feet_notch_d          = 1.0;  // radial depth (how far the notch protrudes)
feet_notch_clear      = 0.4;  // extra clearance around the socket-side slot

/* [Foot layout] */
// Four feet sit at the four corners of the caddy's *flat* bottom strip
// (|X| ≤ caddy_w/2 − corner_r). `feet_inset_x` is measured inward from
// the flat strip's X edge; `feet_inset_y` inward from the prism's Y edge.
//   Foot 1 (back-left,  −X, +Y): tilt = +A,  rotation = −Δ
//   Foot 2 (back-right, +X, +Y): tilt = −A,  rotation = +Δ
//   Foot 3 (front-left, −X, −Y): tilt = +A,  rotation = 180 − Δ
//   Foot 4 (front-right,+X, −Y): tilt = −A,  rotation = 180 + Δ
// (Angle = 0 makes rotation visually irrelevant for the round body,
//  but the notch still keys it.)
feet_inset_x          = 8;    // inward from the flat strip's X edge
feet_inset_y          = 12;   // inward from the prism's Y edge
feet_angle            = 0;    // tilt magnitude in degrees (try 15–20 for splay)
feet_rotation_delta   = 0;    // Z-rotation delta per spec

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
      t == "body"       ? body_peg_d
    : t == "head"       ? head_peg_d
    : t == "toothpaste" ? toothpaste_peg_d
    :                     0;

function _slot_peg_h(t)   =
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

// Half-extents of the FLAT bottom strip of the stadium prism — the
// region of the bottom face that's actually at Z = 0 (outside this in
// X, the stadium curves up and there's no surface to mount feet to).
flat_half_w = caddy_w / 2 - corner_r;
flat_half_d = caddy_d / 2;

function _foot_xy(x_sign, y_sign) = [
    x_sign * (flat_half_w - feet_inset_x),
    y_sign * (flat_half_d - feet_inset_y)
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

// Solid stadium prism. The 2D stadium is drawn in (drawing) XY at size
// caddy_w × caddy_h; linear_extrude goes in the drawing's +Z; then
// rotate([-90,0,0]) maps the drawing's Y → world Z (so the stadium's
// short axis becomes vertical) and the drawing's Z → world Y (so the
// extrusion lies along the caddy's depth). Finally translate it up so
// the prism sits on Z = 0.
module _outer_solid() {
    translate([0, 0, caddy_h / 2])
        rotate([-90, 0, 0])
            linear_extrude(height = caddy_d, center = true)
                rounded_rect_2d(caddy_w, caddy_h, corner_r);
}

// Through/recess cylinders for every slot. floor_h == 0 → through-hole;
// floor_h > 0 → recess only, with `floor_h` of solid material below.
module _slot_subtractions() {
    for (j = [0 : num_rows - 1])
        for (i = [0 : len(slot_rows[j]) - 1]) {
            t = slot_rows[j][i];
            p = _slot_xy(i, j);
            hole_d = _slot_hole_d(t);
            floor  = _slot_floor_h(t);
            if (hole_d > 0) {
                if (floor <= 0) {
                    // Through-hole.
                    translate([p[0], p[1], -0.01])
                        cylinder(d = hole_d, h = caddy_h + 0.02);
                } else {
                    // Top recess down to z = floor.
                    translate([p[0], p[1], floor])
                        cylinder(d = hole_d, h = caddy_h - floor + 0.01);
                }
            }
        }
}

// Cylindrical socket + rectangular notch slot, at one corner, oriented
// by the foot's installation rotation so the foot's notch lines up.
// The socket cuts up from Z = 0 (the caddy bottom face) into the prism
// by feet_socket_h.
module _socket(x_sign, y_sign, rot) {
    p = _foot_xy(x_sign, y_sign);
    cavity_d = feet_top_d + feet_socket_clear;
    slot_w   = feet_notch_w + feet_notch_clear;
    slot_d   = feet_notch_d + feet_notch_clear / 2;
    translate([p[0], p[1], -0.01])
        rotate([0, 0, rot])
            union() {
                cylinder(d = cavity_d, h = feet_socket_h + 0.01);
                // Notch slot — extends radially outward from the cavity
                // wall at angle 0 (foot-local +X). Starts slightly inside
                // the cylinder so the two unions overlap cleanly.
                translate([cavity_d / 2 - 0.5, -slot_w / 2, 0])
                    cube([slot_d + 0.5, slot_w, feet_socket_h + 0.01]);
            }
}

// Additive features: bottom-sitting pegs (head retention, body
// charging recess). Only emitted where the slot has a solid floor for
// the peg to attach to.
module _slot_additions() {
    for (j = [0 : num_rows - 1])
        for (i = [0 : len(slot_rows[j]) - 1]) {
            t = slot_rows[j][i];
            p = _slot_xy(i, j);
            peg_d = _slot_peg_d(t);
            peg_h = _slot_peg_h(t);
            floor = _slot_floor_h(t);
            if (peg_d > 0 && peg_h > 0 && floor > 0)
                translate([p[0], p[1], floor])
                    cylinder(d = peg_d, h = peg_h);
        }
}

module caddy() {
    union() {
        difference() {
            _outer_solid();
            _slot_subtractions();
            // Four sockets — one per foot — with notch slots oriented to
            // each foot's installation rotation.
            D = feet_rotation_delta;
            _socket(-1, +1,        -D);  // BL
            _socket(+1, +1,        +D);  // BR
            _socket(-1, -1, 180 -  D);   // FL
            _socket(+1, -1, 180 +  D);   // FR
        }
        _slot_additions();
    }
}

// ---- foot ----

// One foot — truncated cone + flange + adhesive recess + keying notch
// on the top side. The notch protrudes radially outward from the cone's
// top edge at foot-local +X (rotation 0); when the foot is rotated for
// installation, the notch rotates with it and engages the socket slot.
module foot_solo() {
    flange_d = feet_bottom_d + 2 * feet_rim_t;
    union() {
        difference() {
            union() {
                cylinder(d = flange_d, h = feet_recess_h);
                translate([0, 0, feet_recess_h])
                    cylinder(d1 = feet_bottom_d,
                             d2 = feet_top_d,
                             h  = feet_h - feet_recess_h);
            }
            // Adhesive-foot recess bites into the flange from below.
            translate([0, 0, -0.01])
                cylinder(d = feet_recess_d, h = feet_recess_h + 0.01);
        }
        // Keying notch — top socket_h of the foot. Starts slightly
        // inside the cone surface (-0.1 mm) so the union joins cleanly.
        translate([feet_top_d / 2 - 0.1,
                  -feet_notch_w / 2,
                   feet_h - feet_socket_h])
            cube([feet_notch_d + 0.1, feet_notch_w, feet_socket_h]);
    }
}

// Four feet, side-by-side on the bed for printing (no tilt).
module feet_for_print() {
    flange_d = feet_bottom_d + 2 * feet_rim_t;
    spacing  = max(feet_top_d + feet_notch_d, flange_d) + 4;
    for (i = [0 : 3])
        translate([(i - 1.5) * spacing, 0, 0])
            foot_solo();
}

// Place one foot under a corner of the caddy, tilted by `tilt` around
// the local outward axis (after Z-rotation by `rot`). The foot's TOP
// inserts into the caddy socket at Z = 0..feet_socket_h.
module _foot_at_corner(x_sign, y_sign, tilt, rot) {
    p = _foot_xy(x_sign, y_sign);
    translate([p[0], p[1], 0])
        rotate([0, 0, rot])
            rotate([0, tilt, 0])
                translate([0, 0, feet_socket_h - feet_h])
                    foot_solo();
}

// All four feet at the splayed positions (visualisation only).
module feet_assembled() {
    A = feet_angle;
    D = feet_rotation_delta;
    _foot_at_corner(-1, +1, +A,       -D);  // BL
    _foot_at_corner(+1, +1, -A,       +D);  // BR
    _foot_at_corner(-1, -1, +A, 180 - D);   // FL
    _foot_at_corner(+1, -1, -A, 180 + D);   // FR
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

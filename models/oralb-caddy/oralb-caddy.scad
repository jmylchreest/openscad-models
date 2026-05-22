// oralb-caddy — parametric stadium-RING caddy for Oral-B electric
// toothbrushes, replacement brush heads, and a toothpaste tube. The
// caddy is a HOLLOW oval (stadium ring) — open through its depth so
// the brushes are visible inside the frame. The outer profile in the
// front view is a stadium; the inner hollow is a smaller stadium with
// a uniform `wall_t` rim around it. Brushes drop in through holes in
// the top strip and stand inside the hollow, resting on the bottom
// strip (or on a peg). Four splay-able tapered feet glue into keyed
// sockets on the bottom face.
//
// Coordinates are USE ORIENTATION:
//   X — width  (long axis of the stadium silhouette, left ↔ right)
//   Y — depth  (front ↔ back, the open-through direction)
//   Z — height (vertical, brushes stand UP through Z)
// The OUTER SHAPE is a stadium PRISM:
//   - 2D stadium drawn in XZ (caddy_w × caddy_h) — front silhouette
//   - extruded along Y by caddy_d
//   - corner_r = caddy_h/2 gives the full oval; less = rounded rectangle
// The INNER HOLLOW is a smaller stadium prism extruded clear THROUGH
// Y, so the front and back are open and you can see the brushes.
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
slot_rows = [["body", "toothpaste", "body"], ["toothpaste", "body"]];

/* [Caddy frame — the stadium-prism block] */
// caddy_w and caddy_d are 0 by default — sized automatically from the
// slot layout, the largest hole in use, and the rim/end-cap margins.
// Set either to a positive value to override (the model still honours
// the slot layout — you're just claiming more material around it).
//   auto width = (max_cols − 1) · slot_spacing_x + 2·(corner_r + 4)
//   auto depth = (num_rows − 1) · slot_spacing_y + max_hole_d + 28
caddy_w   = 0;    // X — 0 = auto-derived from slot layout
caddy_h   = 55;   // Z — short axis of the stadium (visible height)
caddy_d   = 0;    // Y — 0 = auto-derived from slot layout
corner_r  = 27;   // outer corner radius in XZ (caddy_h/2 = full oval)
wall_t    = 6;    // uniform thickness of the ring's top/bottom/end-cap walls

/* [Body slot — Oral-B brush body] */
// Bodies are ~28 mm — 30 mm hole gives ~1 mm clearance per side. The
// brush passes through the top hole into the hollow interior and
// stands on the bottom strip. The peg engages the small alignment
// recess on the brush's underside; on Printables 279981 you can see
// the peg is an OBLONG, slightly TAPERED nub (not a round cylinder) —
// wider in X than in Y at the base and narrowing toward the tip.
//   body_peg_w → diameter along X at the base (caddy's long axis)
//   body_peg_d → diameter along Y at the base (caddy's depth)
//   body_peg_taper → top dimensions as a fraction of the base (1.0 = no taper)
// Set body_peg_w == body_peg_d for a round peg.
body_hole_d    = 30;
body_through   = false;  // true = also punch the bottom strip (pass-through)
body_peg_w     = 7.0;    // along X at base
body_peg_d     = 5.0;    // along Y at base
body_peg_h     = 10.0;
body_peg_taper = 0.75;

/* [Head slot — Oral-B replacement brush head] */
// Heads have a hollow shaft ~5 mm Ø; a 4 mm peg gives a snug fit. Top
// hole sized for the head's body so the bristles sit just above the
// caddy with the shaft engaged on the peg from below.
head_hole_d   = 14;
head_through  = false;
head_peg_d    = 4.0;
head_peg_h    = 25;     // long — fills the head's hollow shaft

/* [Toothpaste slot] */
// Tube enters through the top hole and rests on the bottom strip.
// Set toothpaste_through = true if you'd rather the tube cap hangs out
// the bottom (resting on the counter).
toothpaste_hole_d   = 32;
toothpaste_through  = false;
toothpaste_peg_d    = 0;
toothpaste_peg_h    = 0;

/* [Slot positions] */
slot_spacing_x = 55;  // distance between slot centres along X
slot_spacing_y = 30;  // distance between rows along Y (matters for ≥2 rows)
// How a short row aligns under the longest one. With slot_rows =
// [["x","x","x"], ["x","x"]] and row_align = "center", the front 2
// slots sit offset between the back 3 (default). "left" aligns the
// short row's first column with the long row's first column;
// "right" aligns the last columns instead.
row_align      = "center";  // [center, left, right]

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
// rectangular keying notch. The notches on the caddy ALL point in the
// same direction (`feet_socket_notch_angle`, default 90° = +Y = toward
// the back of the caddy) so the keying is a consistent "this side
// faces back" indicator. Each printed foot carries its notch at a
// per-corner offset so that, when the foot rotates to its installed
// angle, its notch lands on the back-facing socket slot.
feet_socket_h            = 3;    // socket depth (foot insertion length)
feet_socket_clear        = 0.5;  // total Ø clearance — socket Ø = feet_top_d + this
feet_notch_w             = 1.5;  // tangential width of the notch
feet_notch_d             = 1.0;  // radial depth (how far the notch protrudes)
feet_notch_clear         = 0.4;  // extra clearance around the socket-side slot
feet_socket_notch_angle  = 90;   // world angle for every socket's notch slot

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

function _slot_through(t) =
      t == "body"       ? body_through
    : t == "head"       ? head_through
    : t == "toothpaste" ? toothpaste_through
    :                     false;

function _slot_peg_w(t)   =
      t == "body"       ? body_peg_w
    : t == "head"       ? head_peg_d
    : t == "toothpaste" ? toothpaste_peg_d
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

function _slot_peg_taper(t) =
      t == "body"       ? body_peg_taper
    :                     1.0;

// ---- derived ----
num_rows = len(slot_rows);
max_cols = max([for (row = slot_rows) len(row)]);

// Largest hole in use across every populated slot. Used by the
// auto-size formulas below.
max_hole_d = max([
    for (row = slot_rows) for (t = row)
        if (_slot_hole_d(t) > 0) _slot_hole_d(t)
]);

// Auto-size formulas. Width: span between outermost slot centres plus
// a corner_r-sized end cap (the full rounded stadium tip) on each end,
// with 4 mm of extra meat. Depth: span between rows plus a half-hole +
// 14 mm rim on each side (gives a comfortable 14 mm gap between the
// outermost slot edge and the caddy's Y face — matches the source 3MF
// proportions for both 1- and 2-row layouts).
function _auto_caddy_w() = (max_cols - 1) * slot_spacing_x + 2 * (corner_r + 4);
function _auto_caddy_d() = (num_rows - 1) * slot_spacing_y + max_hole_d + 28;

_caddy_w = caddy_w > 0 ? caddy_w : _auto_caddy_w();
_caddy_d = caddy_d > 0 ? caddy_d : _auto_caddy_d();

// X offset applied to the whole row to honour `row_align`. The row's
// own column index then steps in `slot_spacing_x` from there.
function _row_x_offset(row) =
    let (n = len(slot_rows[row]))
      row_align == "center" ? -(n - 1) * slot_spacing_x / 2
    : row_align == "left"   ? -(max_cols - 1) * slot_spacing_x / 2
    : row_align == "right"  ?  (max_cols - 1) * slot_spacing_x / 2
                                - (n - 1) * slot_spacing_x
                            : -(n - 1) * slot_spacing_x / 2;

function _slot_xy(col, row) = [
    col * slot_spacing_x + _row_x_offset(row),
    row * slot_spacing_y - (num_rows - 1) * slot_spacing_y / 2
];

// Half-extents of the FLAT bottom strip of the stadium prism — the
// region of the bottom face that's actually at Z = 0 (outside this in
// X, the stadium curves up and there's no surface to mount feet to).
flat_half_w = _caddy_w / 2 - corner_r;
flat_half_d = _caddy_d / 2;

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
// _caddy_w × caddy_h; linear_extrude goes in the drawing's +Z; then
// rotate([-90,0,0]) maps the drawing's Y → world Z (so the stadium's
// short axis becomes vertical) and the drawing's Z → world Y (so the
// extrusion lies along the caddy's depth). Finally translate it up so
// the prism sits on Z = 0.
module _outer_solid() {
    translate([0, 0, caddy_h / 2])
        rotate([-90, 0, 0])
            linear_extrude(height = _caddy_d, center = true)
                rounded_rect_2d(_caddy_w, caddy_h, corner_r);
}

// Inner hollow — smaller stadium prism extruded clear through Y so the
// ring is open at both ends. Inset by wall_t on all sides; if corner_r
// shrinks below 0.1 mm the inner falls back to a sharp-cornered rect.
module _inner_hollow() {
    inner_w = _caddy_w - 2 * wall_t;
    inner_h = caddy_h - 2 * wall_t;
    inner_r = max(0.1, corner_r - wall_t);
    translate([0, 0, caddy_h / 2])
        rotate([-90, 0, 0])
            linear_extrude(height = _caddy_d + 2, center = true)
                rounded_rect_2d(inner_w, inner_h, inner_r);
}

// Slot subtractions cut from the caddy's vertical mid-plane UP through
// the top, so they also slice off any inner-hollow corner curve that
// would otherwise protrude into the slot when the slot sits near the
// rounded ends. The lower half of the caddy (and the bottom strip) is
// left intact for the brush to rest on — unless the slot is set
// pass-through, in which case a mirrored cut from below clears that
// half too.
module _slot_subtractions() {
    half = caddy_h / 2;
    for (j = [0 : num_rows - 1])
        for (i = [0 : len(slot_rows[j]) - 1]) {
            t = slot_rows[j][i];
            p = _slot_xy(i, j);
            hole_d = _slot_hole_d(t);
            thru   = _slot_through(t);
            if (hole_d > 0) {
                translate([p[0], p[1], half])
                    cylinder(d = hole_d, h = half + 0.01);
                if (thru)
                    translate([p[0], p[1], -0.01])
                        cylinder(d = hole_d, h = half + 0.01);
            }
        }
}

// Cylindrical socket + rectangular notch slot, at one corner. All four
// sockets share the same notch direction (`feet_socket_notch_angle`),
// so the bottom of the caddy reads consistently regardless of how the
// feet are rotated when installed.
module _socket(x_sign, y_sign) {
    p = _foot_xy(x_sign, y_sign);
    cavity_d = feet_top_d + feet_socket_clear;
    slot_w   = feet_notch_w + feet_notch_clear;
    slot_d   = feet_notch_d + feet_notch_clear / 2;
    translate([p[0], p[1], -0.01])
        rotate([0, 0, feet_socket_notch_angle])
            union() {
                cylinder(d = cavity_d, h = feet_socket_h + 0.01);
                translate([cavity_d / 2 - 0.5, -slot_w / 2, 0])
                    cube([slot_d + 0.5, slot_w, feet_socket_h + 0.01]);
            }
}

// Additive features: pegs rising from the INSIDE face of the bottom
// strip (Z = wall_t) up into the hollow. Skipped on pass-through slots
// since the bottom strip is punched out there.
// Tapered oblong peg standing at the origin, axis along +Z.
// w = base diameter along X, d = base diameter along Y, h = height,
// taper = top scale factor (1.0 = no taper, 0 = come to a point).
// Falls back to a plain cylinder when w == d and taper == 1.
module _peg(w, d, h, taper) {
    if (w == d && taper == 1.0)
        cylinder(d = d, h = h);
    else
        linear_extrude(height = h, scale = taper)
            scale([w / d, 1, 1])
                circle(d = d);
}

module _slot_additions() {
    for (j = [0 : num_rows - 1])
        for (i = [0 : len(slot_rows[j]) - 1]) {
            t = slot_rows[j][i];
            p = _slot_xy(i, j);
            pw = _slot_peg_w(t);
            pd = _slot_peg_d(t);
            ph = _slot_peg_h(t);
            tp = _slot_peg_taper(t);
            thru = _slot_through(t);
            if (pd > 0 && ph > 0 && !thru)
                translate([p[0], p[1], wall_t])
                    _peg(pw, pd, ph, tp);
        }
}

module caddy() {
    union() {
        difference() {
            _outer_solid();
            _inner_hollow();
            _slot_subtractions();
            // Four sockets — all share the same notch direction so the
            // bottom face reads consistently.
            _socket(-1, +1);  // BL
            _socket(+1, +1);  // BR
            _socket(-1, -1);  // FL
            _socket(+1, -1);  // FR
        }
        _slot_additions();
    }
}

// ---- foot ----

// One foot — truncated cone + flange + adhesive recess + keying notch
// on the top side. The notch sits at `notch_offset` degrees around the
// foot's vertical axis (default 0 = foot-local +X). At assembly time
// each foot gets its own offset so that, after the foot rotates by R
// to land at its corner, the notch ends up pointing at the caddy's
// fixed `feet_socket_notch_angle` direction.
module foot_solo(notch_offset = 0) {
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
        // Keying notch at the requested local angle.
        rotate([0, 0, notch_offset])
            translate([feet_top_d / 2 - 0.1,
                      -feet_notch_w / 2,
                       feet_h - feet_socket_h])
                cube([feet_notch_d + 0.1, feet_notch_w, feet_socket_h]);
    }
}

// Four feet, side-by-side on the bed for printing. Each carries the
// notch position that lets it install at one specific corner — the
// notches point in four different directions on the bed but all end up
// pointing the same way (toward the caddy's back) once installed.
module feet_for_print() {
    flange_d = feet_bottom_d + 2 * feet_rim_t;
    spacing  = max(feet_top_d + feet_notch_d, flange_d) + 4;
    D = feet_rotation_delta;
    rots = [-D, +D, 180 - D, 180 + D];  // BL, BR, FL, FR
    for (i = [0 : 3])
        translate([(i - 1.5) * spacing, 0, 0])
            foot_solo(feet_socket_notch_angle - rots[i]);
}

// Place one foot under a corner of the caddy, tilted by `tilt` around
// the local outward axis (after Z-rotation by `rot`). The foot's TOP
// inserts into the caddy socket at Z = 0..feet_socket_h. The notch
// offset is chosen so the notch lands at the caddy's fixed socket
// notch direction after the foot's own rotation.
module _foot_at_corner(x_sign, y_sign, tilt, rot) {
    p = _foot_xy(x_sign, y_sign);
    translate([p[0], p[1], 0])
        rotate([0, 0, rot])
            rotate([0, tilt, 0])
                translate([0, 0, feet_socket_h - feet_h])
                    foot_solo(feet_socket_notch_angle - rot);
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
    translate([-_caddy_w / 2 - 30, 0, 0])
        feet_for_print();
} else if (render_target == "assembled") {
    caddy();
    feet_assembled();
}

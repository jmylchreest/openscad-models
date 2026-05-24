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

use <../../libraries/toothbrush-pegs/toothbrush-pegs.scad>

/* [Output] */
// `all` shows the caddy + four feet on a virtual plate.
// `assembled` shows the caddy with the feet inserted (visualisation).
render_target = "assembled";  // [caddy, feet, all, assembled]

/* [Layout] */
// Each inner list is one row of slots, arranged front-to-back along Y.
// Allowed types:
//   "body"       — brush body slot (hole + peg)
//   "head"       — replacement-head slot (hole + tall peg)
//   "toothpaste" — toothpaste tube hole
//   "solid"      — RESERVED position: counted for spacing, no hole, no
//                  peg. Use to place "real" slots at specific spots in
//                  a grid without filling every grid cell.
//   ""           — same as "solid", legacy spelling.
//
//   1 row (matches the source 3MF):
//     slot_rows = [["body", "toothpaste", "body"]];
//
//   2 rows (heads in front, brushes + paste in back):
//     slot_rows = [["head", "head", "head"],
//                  ["body", "toothpaste", "body"]];
//
//   Sparse — keep the layout, blank some cells with "solid":
//     slot_rows = [["body",  "solid", "body"],
//                  ["solid", "body",  "solid"]];
slot_rows = [
["body", "toothpaste", "toothpaste", "body"]
];

/* [Caddy frame — the stadium-prism block] */
// caddy_w and caddy_d are 0 by default — sized automatically from the
// slot layout, the largest hole in use, and the rim/end-cap margins.
// Set either to a positive value to override (the model still honours
// the slot layout — you're just claiming more material around it).
//   auto width = (max_cols − 1) · slot_spacing_x + 2·(corner_r + 4)
//   auto depth = (num_rows − 1) · slot_spacing_y + max_hole_d + 28
caddy_w   = 0;    // X — 0 = auto-derived from slot layout
caddy_h   = 66;   // Z — short axis of the stadium (visible height)
caddy_d   = 55;    // Y — 0 = auto-derived from slot layout
corner_r  = 33;   // outer corner radius in XZ (caddy_h/2 = full oval)
wall_t    = 5;    // uniform thickness of the ring's top/bottom/end-cap walls

/* [Body slot — Oral-B brush body] */
// Bodies are ~28 mm — 30 mm hole gives ~1 mm clearance per side. The
// brush passes through the top hole and rests on the bottom strip;
// the peg engages the asymmetric recess on the brush's underside.
// Peg shape, size and height are fixed in libraries/toothbrush-pegs;
// only the slide-fit tolerance is exposed here (use oralb-peg-test/
// to dial it in).
body_hole_d         = 32;
body_through        = false;  // true = also punch the bottom strip (pass-through)
body_peg_tolerance  = 0.3;    // total XY clearance — subtracted from each dimension
body_peg_taper      = 2.0;    // total XY shrinkage from peg base to top of main body
body_peg_chamfer    = 0.5;    // extra per-side inset at the very top (insertion lead-in)
body_peg_chamfer_h  = 0.5;    // vertical height of the chamfer (45° at 0.5/0.5)

/* [Head slot — Oral-B replacement brush head] */
// Heads have a hollow shaft ~5 mm Ø; a 4 mm peg gives a snug fit. Top
// hole sized for the head's body so the bristles sit above the caddy
// with the shaft engaged on the peg from below.
//
// head_peg_h is auto-derived from the caddy when set to 0: the peg's
// top sits 5 mm below caddy_h, so the head's ~18 mm hollow shaft can
// engage the top of the peg with the rest of the body standing above
// the caddy.
//   auto height = caddy_h − wall_t − 5
head_hole_d   = 13;
head_through  = false;
head_peg_d    = 4.0;
head_peg_h    = 0;     // 0 = auto: peg top 5 mm below caddy_h

/* [Toothpaste slot] */
// Tube enters through the top hole and rests on the bottom strip.
// Set toothpaste_through = true if you'd rather the tube cap hangs out
// the bottom (resting on the counter).
toothpaste_hole_d   = 45;
toothpaste_through  = false;
toothpaste_peg_d    = 0;
toothpaste_peg_h    = 0;

/* [Slot positions] */
slot_spacing_x = 50;  // distance between slot centres along X
slot_spacing_y = 35;  // distance between rows along Y (matters for ≥2 rows)
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
feet_top_d            = 14;    // wide end (plugs into the caddy)
feet_bottom_d         = 10;  // narrow end (rests on the counter)
feet_h                = 18;   // overall height of the foot
feet_recess_d         = 7.8;    // adhesive rubber foot diameter
feet_recess_h         = 0.4;  // recess depth (≈ adhesive thickness)
feet_rim_t            = 0.0;  // flange flaring out around the recess

/* [Foot ↔ caddy joint] */
// Caddy bottom carries four cylindrical sockets, each with a small
// rectangular keying notch. Notches point OUTWARD along X by default —
// left sockets carry their slot on the −X side, right sockets on +X —
// so the keying also encodes the splay axis: drop a foot in with its
// notch in the slot and it's already rotated to splay outward.
feet_socket_h            = 3;    // socket depth (foot insertion length)
feet_socket_clear        = 0.5;  // total Ø clearance — socket Ø = feet_top_d + this
feet_notch_w             = 1.5;  // tangential width of the notch
feet_notch_d             = 1.0;  // radial depth (how far the notch protrudes)
feet_notch_clear         = 0.4;  // extra clearance around the socket-side slot

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
feet_angle            = 10;    // tilt magnitude in degrees (try 15–20 for splay)
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

// Head + toothpaste are round pegs, dispatched on a single diameter.
// The body peg has its own shape (see _oralb_body_peg) and is dispatched
// separately in _slot_additions.
function _round_peg_d(t)  =
      t == "head"       ? head_peg_d
    : t == "toothpaste" ? toothpaste_peg_d
    :                     0;

// Head peg height: user-set when head_peg_h > 0, otherwise derived from
// the caddy so the peg's top sits 5 mm below caddy_h (leaves the head
// body well above the caddy when 18 mm of the shaft engages the top).
function _head_peg_h() =
    head_peg_h > 0 ? head_peg_h : max(1, caddy_h - wall_t - 5);

function _round_peg_h(t)  =
      t == "head"       ? _head_peg_h()
    : t == "toothpaste" ? toothpaste_peg_h
    :                     0;

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

// Notch direction for each socket: by default the notch faces OUTWARD
// in X (right sockets carry their notch on +X, left sockets on −X), so
// the keying ALSO encodes the splay axis — once the foot is dropped
// into a socket with its notch in the slot, the foot is rotated to
// splay outward along X with no extra setup. Override via the
// per-side angles below if you want a different convention.
feet_socket_notch_angle_right = 0;    // +X direction (world)
feet_socket_notch_angle_left  = 180;  // −X direction (world)

function _socket_notch_angle(x_sign) =
    x_sign > 0 ? feet_socket_notch_angle_right
               : feet_socket_notch_angle_left;

// Cylindrical socket + rectangular notch slot, at one corner. Each
// socket's notch points outward in X (see _socket_notch_angle) so the
// foot's splay axis is implicit in the joint.
module _socket(x_sign, y_sign) {
    p = _foot_xy(x_sign, y_sign);
    cavity_d = feet_top_d + feet_socket_clear;
    slot_w   = feet_notch_w + feet_notch_clear;
    slot_d   = feet_notch_d + feet_notch_clear / 2;
    translate([p[0], p[1], -0.01])
        rotate([0, 0, _socket_notch_angle(x_sign)])
            union() {
                cylinder(d = cavity_d, h = feet_socket_h + 0.01);
                translate([cavity_d / 2 - 0.5, -slot_w / 2, 0])
                    cube([slot_d + 0.5, slot_w, feet_socket_h + 0.01]);
            }
}

// Additive features: pegs rising from the INSIDE face of the bottom
// strip (Z = wall_t) up into the hollow. Skipped on pass-through slots
// since the bottom strip is punched out there.
// Oral-B body peg wrapper — passes the caddy's tolerance / taper /
// chamfer settings through to the library so the peg geometry is one
// source of truth.
module _oralb_body_peg() {
    oralb_body_peg(
        tolerance = body_peg_tolerance,
        taper     = body_peg_taper,
        chamfer   = body_peg_chamfer,
        chamfer_h = body_peg_chamfer_h
    );
}

module _slot_additions() {
    for (j = [0 : num_rows - 1])
        for (i = [0 : len(slot_rows[j]) - 1]) {
            t = slot_rows[j][i];
            p = _slot_xy(i, j);
            thru = _slot_through(t);
            if (!thru)
                translate([p[0], p[1], wall_t])
                    if (t == "body") {
                        _oralb_body_peg();
                    } else {
                        rd = _round_peg_d(t);
                        rh = _round_peg_h(t);
                        if (rd > 0 && rh > 0)
                            cylinder(d = rd, h = rh);
                    }
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
// foot's vertical axis (default 0 = foot-local +X). `bottom_angle`
// shears the BOTTOM face of the foot around the foot's local Y axis,
// so that when the foot is installed tilted by `−bottom_angle` around
// the same axis, its bottom ends up parallel to the ground.
module foot_solo(notch_offset = 0, bottom_angle = 0) {
    difference() {
        _foot_solo_body(notch_offset);
        // Slanted half-space that cuts the foot's bottom at the
        // requested angle around the foot's local Y axis. The cube
        // sits below z = 0 in its own frame; rotating it by
        // `bottom_angle` around Y tilts its top face so the cut plane
        // becomes z = x · tan(bottom_angle) in foot-local coords.
        if (bottom_angle != 0)
            rotate([0, bottom_angle, 0])
                translate([0, 0, -50])
                    cube([200, 200, 100], center = true);
    }
}

module _foot_solo_body(notch_offset) {
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
//
// Feet print UPSIDE DOWN (wide caddy-facing end on the bed). Each
// successive layer is the same width or smaller than the one below
// it, so the cone tapers cleanly to the narrow end with no overhangs
// and the rubber-foot recess opens upward — no supports needed.
module feet_for_print() {
    flange_d = feet_bottom_d + 2 * feet_rim_t;
    spacing  = max(feet_top_d + feet_notch_d, flange_d) + 4;
    D = feet_rotation_delta;
    A = feet_angle;
    xsigns = [-1, +1, -1, +1];            // BL, BR, FL, FR
    rots   = [-D, +D, 180 - D, 180 + D];
    tilts  = [+A, -A, +A,      -A];
    for (i = [0 : 3])
        translate([(i - 1.5) * spacing, 0, feet_h])
            rotate([180, 0, 0])
                foot_solo(
                    notch_offset = _socket_notch_angle(xsigns[i]) - rots[i],
                    bottom_angle = -tilts[i]
                );
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
                    foot_solo(
                        notch_offset = _socket_notch_angle(x_sign) - rot,
                        bottom_angle = -tilt
                    );
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

// Caddy in PRINT orientation: rotate 90° on X so the open front face
// sits on the bed and the stadium-ring cross-section runs straight up.
// Slot tunnels become horizontal (≤ ~35 mm — slicer-bridgeable
// without supports) and the head pegs become near-horizontal posts
// instead of tall vertical pillars. The `assembled` target keeps the
// USE orientation so the visualisation matches how the caddy sits on
// the counter.
module caddy_for_print() {
    translate([0, 0, _caddy_d / 2])
        rotate([90, 0, 0])
            caddy();
}

// ---- output ----
if (render_target == "caddy") {
    caddy_for_print();
} else if (render_target == "feet") {
    feet_for_print();
} else if (render_target == "all") {
    caddy_for_print();
    translate([-_caddy_w / 2 - 30, 0, 0])
        feet_for_print();
} else if (render_target == "assembled") {
    caddy();
    feet_assembled();
}
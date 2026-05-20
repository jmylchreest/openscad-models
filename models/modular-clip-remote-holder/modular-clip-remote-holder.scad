// modular-clip-remote-holder — simple cradle that holds a remote on the
// modular-clip dovetail. Back plate carries the slot; a short bracket at
// the bottom catches the remote so it stands upright with most of its
// body free. Defaults sized for a 34 × 7.5 mm remote.
// Author: John Mylchreest <jmylchreest@gmail.com>. MIT licensed.

use <../../libraries/modular-clip/modular-clip.scad>

/* [Output] */
// `all` arranges the clip and the holder side-by-side on the X axis so
// the slicer can pick each up for separate plates.
render_target = "all";  // [clip, holder, all]

/* [Clip — grips the edge] */
clip_grip_d     = 5;
clip_grip_h     = 25;
clip_width      = 30;
clip_wall_t     = 2.5;
clip_top_r      = 2.0;
clip_arm_extend = 24;

/* [Holder back plate] */
back_w     = 40;   // X width of the back plate
back_h     = 60;   // Z height of the back plate (slot lives near the top)
back_t     = 5;    // Y thickness — must be ≥ dovetail standoff + clearance
back_r     = 3;    // outer corner radius on the back face (cosmetic)

/* [Cradle — bottom bracket that holds the remote] */
// Sized for a 34 × 7.5 mm remote. The remote leans against the back
// plate, its bottom sits on the floor, side rims and a small front rim
// keep it from shifting.
remote_w        = 34.0;
remote_d        = 7.5;
cradle_clear_w  = 0.6;   // total X clearance for the remote in the cradle
cradle_clear_d  = 0.4;   // total Y clearance for the remote
floor_t         = 3.0;   // cradle floor thickness
rim_h           = 6.0;   // cradle rim height (above the floor)
side_rim_t      = 2.0;   // X thickness of each side rim
front_rim_t     = 2.0;   // Y thickness of the front rim

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

/* [Layout — `render_target = all` only] */
all_spacing = 25;

// ---- derived ----
cradle_inner_w = remote_w + cradle_clear_w;
cradle_inner_d = remote_d + cradle_clear_d;
cradle_outer_w = cradle_inner_w + 2 * side_rim_t;
cradle_outer_d = cradle_inner_d + front_rim_t;       // back side shares the back plate
cradle_total_h = floor_t + rim_h;

// ---- modules ----

// 2D rounded rectangle centred at origin.
module _rrect2d(w, d, r) {
    rr = min(r, min(w, d) / 2 - 0.001);
    offset(r = rr) offset(r = -rr) square([w, d], center = true);
}

// Cradle: a short L-bracket attached to the front face of the back plate.
// Floor at Z in [0, floor_t]; side and front rims at Z in [floor_t,
// floor_t + rim_h]. The back face of the cradle (-Y end) butts against
// the back plate's front face at Y = back_t.
module cradle() {
    // Cradle outer footprint (X width = cradle_outer_w, Y depth =
    // cradle_outer_d). Origin: cradle centred in X, back face at
    // Y = back_t (front face of the back plate).
    cx = 0;
    y0 = back_t;
    y1 = y0 + cradle_outer_d;

    // Floor — solid plate covering the full cradle footprint.
    translate([cx, (y0 + y1) / 2, floor_t / 2])
        cube([cradle_outer_w, cradle_outer_d, floor_t], center = true);

    // Left side rim.
    translate([-cradle_inner_w / 2 - side_rim_t / 2,
               (y0 + y1) / 2,
               floor_t + rim_h / 2])
        cube([side_rim_t, cradle_outer_d, rim_h], center = true);

    // Right side rim.
    translate([ cradle_inner_w / 2 + side_rim_t / 2,
               (y0 + y1) / 2,
               floor_t + rim_h / 2])
        cube([side_rim_t, cradle_outer_d, rim_h], center = true);

    // Front rim.
    translate([cx,
               y1 - front_rim_t / 2,
               floor_t + rim_h / 2])
        cube([cradle_inner_w, front_rim_t, rim_h], center = true);
}

// Full holder = back plate (with slot) + cradle in front of it.
module remote_holder() {
    union() {
        modular_holder_back(width   = back_w,
                            height  = back_h,
                            wall_t  = back_t,
                            corner_r = back_r);
        cradle();
    }
}

// ---- output ----
if (render_target == "clip") {
    clip(grip_d = clip_grip_d, grip_h = clip_grip_h, width = clip_width,
         wall_t = clip_wall_t, top_r = clip_top_r,
         arm_extend = clip_arm_extend);
} else if (render_target == "holder") {
    remote_holder();
} else if (render_target == "all") {
    // Clip rotated 90° so its width is along X for compact layout.
    translate([-all_spacing - clip_width / 2 - 2, 0, 0])
        rotate([0, 0, 90])
            clip(grip_d = clip_grip_d, grip_h = clip_grip_h,
                 width = clip_width, wall_t = clip_wall_t,
                 top_r = clip_top_r, arm_extend = clip_arm_extend);
    translate([all_spacing + back_w / 2, 0, 0])
        remote_holder();
}

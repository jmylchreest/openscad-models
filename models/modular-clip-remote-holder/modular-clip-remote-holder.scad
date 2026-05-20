// modular-clip-remote-holder — slim back plate (male dovetail) with a
// short cup at the bottom that catches the lower edge of a remote. The
// remote rests in the cup and leans against the plate, with its whole
// upper body free. Defaults sized for a 34 × 7.5 mm remote.
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
clip_arm_extend = 32;   // ≥ CLIP_DOVETAIL_L + 2 mm so the slot fits

/* [Holder — slim back plate carrying the male connector] */
// The plate is just a slim "spine" — wide enough for the cup at the
// bottom + the dovetail rail behind. Total height covers the rail at
// the top + the cup at the bottom.
plate_w     = 38;   // X width (slightly wider than the cup outer width)
plate_h     = 48;   // Z height — top region carries the rail, bottom region carries the cup
plate_t     = 3.0;  // Y thickness behind the rail (default library minimum)
plate_r     = 4;    // plate outer corner radius (cosmetic)

/* [Cup — small cradle at the bottom that catches the remote] */
remote_w        = 34.0;
remote_d        = 7.5;
cup_clear_w     = 0.6;  // total X clearance for the remote in the cup
cup_clear_d     = 0.4;  // total Y clearance for the remote
cup_side_t      = 2.0;  // X thickness of each cup side wall
cup_front_t     = 2.0;  // Y thickness of the cup front wall
cup_floor_t     = 2.5;  // floor thickness (solid bottom)
cup_h           = 12;   // total cup height (floor + walls)
cup_corner_r    = 3.0;  // rounding on the cup's outer corners

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

/* [Layout — `render_target = all` only] */
all_spacing = 25;

// ---- derived ----
cup_inner_w = remote_w + cup_clear_w;             // X interior of the cup
cup_inner_d = remote_d + cup_clear_d;             // Y interior of the cup
cup_outer_w = cup_inner_w + 2 * cup_side_t;       // X exterior
cup_outer_d = cup_inner_d + cup_front_t;          // Y exterior (back is shared with plate)

// ---- modules ----

// 2D rounded rectangle with the back-left corner at (0,0), front in +Y.
module _rrect2d_corner(w, d, r) {
    rr = min(r, min(w, d) / 2 - 0.001);
    offset(r = rr) offset(r = -rr)
        translate([rr, rr]) square([w - 2 * rr, d - 2 * rr]);
}

// Small cup at the bottom of the plate. Outer footprint X width =
// cup_outer_w, Y depth = cup_outer_d (back face shared with the plate's
// +Y face at Y=0). Interior cavity (X = cup_inner_w, Y = cup_inner_d)
// is open at the top; the back of the cavity is the plate itself.
module cup() {
    difference() {
        // Outer cup body — extruded from a 2D rounded rectangle sitting
        // on the +Y face of the plate (Y=0 to Y=cup_outer_d, X centred).
        translate([-cup_outer_w / 2, 0, 0])
            linear_extrude(height = cup_h)
                _rrect2d_corner(cup_outer_w, cup_outer_d, cup_corner_r);

        // Interior cavity for the remote — open at the top, back at Y=0
        // (against the plate's front face).
        translate([-cup_inner_w / 2, -0.01, cup_floor_t])
            cube([cup_inner_w, cup_inner_d + 0.01, cup_h - cup_floor_t + 1]);
    }
}

// Full holder = slim back plate (male rail on its back) + cup at the bottom.
module remote_holder() {
    union() {
        modular_holder_back(width    = plate_w,
                            height   = plate_h,
                            wall_t   = plate_t,
                            corner_r = plate_r);
        cup();
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
    translate([all_spacing + plate_w / 2, 0, 0])
        remote_holder();
}

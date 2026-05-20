// modular-clip-remote-holder — parametric remote-control pocket that
// snaps onto the modular-clip dovetail. Default sizing fits a 34 × 7.5 mm
// remote. Author: John Mylchreest <jmylchreest@gmail.com>. MIT licensed.

use <../../libraries/modular-clip/modular-clip.scad>

/* [Output] */
// `all` arranges the clip and the holder side-by-side on the X axis so
// the slicer can pick each up for separate plates.
render_target = "all";  // [clip, holder, all]

/* [Clip — grips the edge] */
clip_grip_d     = 5;    // edge thickness the clip grips (between arms)
clip_grip_h     = 25;   // vertical extent of the grip region
clip_width      = 30;   // clip width along the gripped edge
clip_wall_t     = 2.5;  // plastic wall thickness
clip_top_r      = 2.0;  // inner radius of the 180° top fold
clip_arm_extend = 24;   // front-arm extension below the grip (carries the rail)

/* [Holder — remote pocket] */
// Defaults sized for a 34 × 7.5 mm remote.
remote_w        = 34.0;   // remote long-axis (X)
remote_d        = 7.5;    // remote short-axis (Y, depth front-to-back)
holder_h        = 65;     // pocket height in Z (≤ remote height, leaves top exposed)
pocket_clear_w  = 0.6;    // pocket is this much wider than the remote (per side)
pocket_clear_d  = 0.3;    // pocket is this much deeper than the remote (per side)
wall_t          = 2.0;    // side wall thickness
back_wall_t     = 5.0;    // back wall — thicker so the dovetail slot fits in it
floor_t         = 2.5;    // solid bottom floor — stops the remote falling through
front_lip_w     = 9.0;    // X extent of each front retention lip
front_lip_t     = 1.8;    // Y thickness of the front lip (overhangs the pocket front)
front_lip_band  = 12;     // Z extent of the lip band at the top of the pocket
corner_r        = 2.0;    // outer corner radius of the holder body

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

/* [Layout — `render_target = all` only] */
all_spacing = 25;

// ---- derived ----
pocket_w        = remote_w + 2 * pocket_clear_w;    // interior cavity X
pocket_d        = remote_d + 2 * pocket_clear_d;    // interior cavity Y
holder_outer_w  = pocket_w + 2 * wall_t;
holder_outer_d  = back_wall_t + pocket_d + front_lip_t;
pocket_front_y  = back_wall_t + pocket_d;           // Y of the pocket's front face
front_gap       = pocket_w - 2 * front_lip_w;       // gap between the two front lips

// ---- modules ----

// 2D rounded rectangle centred at origin.
module _rrect2d(w, d, r) {
    rr = min(r, min(w, d) / 2 - 0.001);
    offset(r = rr) offset(r = -rr) square([w, d], center = true);
}

// Solid holder block: floor + back wall + 2 side walls + 2 front
// retention lips at the top. Pocket cavity is pocket_w × pocket_d ×
// (holder_h - floor_t), open at the top. Below the lip band the front
// face is fully open; within the lip band only the middle gap is open
// (the two lips retain the remote at the top-front). The back wall
// carries a dovetail slot, open at the top, that mates with the clip's
// rail.
//
// Frame: holder centred at X=0; back face at Y=0; floor at Z=0; top at
// Z=holder_h.
module remote_holder() {
    difference() {
        // Outer body — full block.
        translate([0, holder_outer_d / 2, 0])
            linear_extrude(height = holder_h)
                _rrect2d(holder_outer_w, holder_outer_d, corner_r);

        // Pocket cavity (open at top).
        translate([0, back_wall_t + pocket_d / 2, floor_t])
            linear_extrude(height = holder_h - floor_t + 1)
                _rrect2d(pocket_w, pocket_d, 0.5);

        // Open the front face BELOW the lip band — full pocket width.
        translate([-pocket_w / 2,
                   pocket_front_y - 0.01,
                   floor_t])
            cube([pocket_w,
                  front_lip_t + 0.02,
                  holder_h - floor_t - front_lip_band + 0.001]);

        // Open the front face WITHIN the lip band — only the gap
        // between the two retention lips (leaves the lips standing).
        translate([-front_gap / 2,
                   pocket_front_y - 0.01,
                   holder_h - front_lip_band])
            cube([front_gap,
                  front_lip_t + 0.02,
                  front_lip_band + 0.01]);

        // Dovetail slot, centred along X, opens at the top of the holder
        // so it slides DOWN onto the clip's rail. Library frame puts the
        // standoff in +X; rotate([0,0,90]) maps that to world +Y so the
        // slot cuts INTO the back wall from the Y=0 face.
        slot_centre_z = holder_h - clip_dovetail_l() / 2 - 1.5;
        translate([0, 0, slot_centre_z])
            rotate([0, 0, 90])
                dovetail_slot(open_ends = "high");
    }
}

// Where the holder ends up when "docked" on the clip — used for the
// `all` layout preview (NOT for actual printing; clip and holder are
// always printed separately).
module clip_with_holder_preview() {
    color("SteelBlue") clip(grip_d = clip_grip_d,
                            grip_h = clip_grip_h,
                            width = clip_width,
                            wall_t = clip_wall_t,
                            top_r = clip_top_r,
                            arm_extend = clip_arm_extend);

    // Place the holder so its back face hugs the clip's front-arm outer
    // face, and its dovetail slot lines up with the rail.
    rail_x = 2 * clip_wall_t + clip_grip_d;
    rail_z = -clip_grip_h - clip_arm_extend / 2;
    color("LightCoral") translate([rail_x, 0, rail_z - (clip_dovetail_l()/2) + 1.0])
        rotate([0, 0, 0])
            remote_holder();
}

// ---- output ----
if (render_target == "clip") {
    clip(grip_d = clip_grip_d,
         grip_h = clip_grip_h,
         width = clip_width,
         wall_t = clip_wall_t,
         top_r = clip_top_r,
         arm_extend = clip_arm_extend);
} else if (render_target == "holder") {
    remote_holder();
} else if (render_target == "all") {
    // Clip on the left, holder on the right, side by side for slicing.
    translate([-all_spacing - clip_width / 2 - 2, 0, 0])
        rotate([0, 0, 90])
            clip(grip_d = clip_grip_d,
                 grip_h = clip_grip_h,
                 width = clip_width,
                 wall_t = clip_wall_t,
                 top_r = clip_top_r,
                 arm_extend = clip_arm_extend);
    translate([all_spacing + holder_outer_w / 2, 0, 0])
        remote_holder();
}

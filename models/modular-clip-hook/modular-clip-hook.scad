// modular-clip-hook — L-style hook accessory that slides onto a
// modular-clip via the shared dovetail interface. Use it for cables,
// keys, headphones, small bags, etc.
// Author: John Mylchreest <jmylchreest@gmail.com>. MIT licensed.

use <../../libraries/modular-clip/modular-clip.scad>

/* [Output] */
render_target = "all";  // [clip, hook, all]

/* [Clip — grips the edge] */
clip_grip_d     = 5;
clip_grip_h     = 25;
clip_width      = 30;
clip_wall_t     = 2.5;
clip_top_r      = 2.0;
clip_arm_extend = 32;   // ≥ CLIP_DOVETAIL_L + 2 mm so the slot fits

/* [Hook back plate] */
plate_w     = 24;   // X width of the back plate
plate_h     = 35;   // Z height — covers the rail at the top + the hook anchor below
plate_t     = 3;    // Y thickness behind the rail
plate_r     = 3;    // outer corner radius (cosmetic)

/* [Hook] */
hook_w        = 8;     // X width of the hook itself
hook_shaft_l  = 28;    // Y extent of the horizontal shaft (out from the back plate)
hook_shaft_t  = 5;     // Z thickness of the horizontal shaft
hook_tip_h    = 14;    // Z height of the upturned tip
hook_tip_t    = 4;     // Y thickness of the upturned tip
hook_fillet   = 2.5;   // corner-rounding radius on the 2D hook profile
hook_z_offset = 6;     // Z offset from the bottom of the plate to the hook bottom

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

/* [Layout — `render_target = all` only] */
all_spacing = 25;

// ---- modules ----

// 2D side profile of the L-hook in the YZ plane. Origin at the corner
// where the shaft meets the back plate; +Y forward, +Z upward.
module _hook_profile_2d() {
    offset(r =  hook_fillet) offset(r = -hook_fillet)
        offset(r = -hook_fillet) offset(r =  hook_fillet)
            polygon([
                [0,                       0],
                [hook_shaft_l,            0],
                [hook_shaft_l,            hook_shaft_t + hook_tip_h],
                [hook_shaft_l - hook_tip_t, hook_shaft_t + hook_tip_h],
                [hook_shaft_l - hook_tip_t, hook_shaft_t],
                [0,                       hook_shaft_t],
            ]);
}

// L-hook attached to the front face of the back plate (which sits at Y=0
// in the new male-connector frame). Shaft sticks out in +Y; vertical tip
// at the end of the shaft points up in +Z.
module hook_body() {
    translate([0, 0, hook_z_offset])
        rotate([90, 0, 90])
            linear_extrude(height = hook_w, center = true)
                _hook_profile_2d();
}

// Full hook = back plate (with male rail on its back) + hook body in front.
module hook() {
    union() {
        modular_holder_back(width    = plate_w,
                            height   = plate_h,
                            wall_t   = plate_t,
                            corner_r = plate_r);
        hook_body();
    }
}

// ---- output ----
if (render_target == "clip") {
    clip(grip_d = clip_grip_d, grip_h = clip_grip_h, width = clip_width,
         wall_t = clip_wall_t, top_r = clip_top_r,
         arm_extend = clip_arm_extend);
} else if (render_target == "hook") {
    hook();
} else if (render_target == "all") {
    translate([-all_spacing - clip_width / 2 - 2, 0, 0])
        rotate([0, 0, 90])
            clip(grip_d = clip_grip_d, grip_h = clip_grip_h,
                 width = clip_width, wall_t = clip_wall_t,
                 top_r = clip_top_r, arm_extend = clip_arm_extend);
    translate([all_spacing + plate_w / 2, 0, 0])
        hook();
}

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
clip_grip_d     = 2.55;
clip_grip_h     = 25;
clip_width      = 20;
clip_wall_t     = 2.5;
clip_top_r      = 2.0;
clip_arm_extend = 32;   // ≥ CLIP_DOVETAIL_L + 2 mm so the slot fits

/* [Spine — narrow back panel that carries the male connector] */
// Just wide enough to mount the dovetail rail + a small margin. The
// remote leans against this spine (only the centre of its back makes
// contact); the cradle at the bottom catches the remote's feet and
// the arms hold it forward.
spine_w     = 20;    // X width of the spine (near dovetail base width)
spine_h     = 50;    // Z height — top carries the rail, bottom meets the cradle
spine_t     = 3.0;   // Y thickness behind the rail
spine_r     = 2;     // spine outer corner radius (cosmetic)

/* [Cradle — small bottom tray + arms that clip the remote] */
// Floor catches the remote's bottom edge; thin side and front arms
// rise from the floor and clip around the remote's lower body to keep
// it from falling forward. Light remote = minimal material.
remote_w         = 34.0;
remote_d         = 7.5;
cradle_clear_w   = 0.6;  // total X clearance for the remote in the cradle
cradle_clear_d   = 0.4;  // total Y clearance for the remote
floor_t          = 2.0;  // floor thickness (solid bottom — stops the remote falling through)
arm_t            = 1.6;  // thickness of each arm (Y for side arms, X for the front arm)
arm_h            = 30.0;  // arms rise this far above the floor
front_arm_w      = 8.0;  // X width of each front arm (a gap in the middle for thumb access)

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

/* [Layout — `render_target = all` only] */
all_spacing = 25;

// ---- derived ----
cradle_inner_w = remote_w + cradle_clear_w;     // X gap inside the cradle for the remote
cradle_inner_d = remote_d + cradle_clear_d;     // Y depth inside the cradle for the remote
cradle_outer_w = cradle_inner_w + 2 * arm_t;    // total cradle X span (with side arms)
cradle_outer_d = cradle_inner_d + arm_t;        // total cradle Y depth (front arm)

// ---- modules ----

// Minimal cradle: a thin floor with three skinny arms rising from it —
// one on each side and one (or two) at the front — that clip around
// the lower body of the remote. The back of the remote rests against
// the spine. Material is kept thin throughout.
//
// Origin: cradle centred along X, back at Y=0 (against the spine's
// front face), floor's bottom at Z=0.
module cradle() {
    // Floor (full cradle footprint, thin).
    translate([-cradle_outer_w / 2, 0, 0])
        cube([cradle_outer_w, cradle_outer_d, floor_t]);

    // Left side arm.
    translate([-cradle_outer_w / 2, 0, floor_t])
        cube([arm_t, cradle_outer_d, arm_h]);

    // Right side arm.
    translate([cradle_outer_w / 2 - arm_t, 0, floor_t])
        cube([arm_t, cradle_outer_d, arm_h]);

    // Two front arms with a thumb gap in the middle — they clip the
    // remote's front face so it can't tip forward.
    // Left front arm.
    translate([-cradle_inner_w / 2, cradle_inner_d, floor_t])
        cube([front_arm_w, arm_t, arm_h]);
    // Right front arm.
    translate([cradle_inner_w / 2 - front_arm_w, cradle_inner_d, floor_t])
        cube([front_arm_w, arm_t, arm_h]);
}

// Full holder = narrow spine carrying the male connector + minimal
// cradle at the bottom that clips the remote.
module remote_holder() {
    union() {
        modular_holder_back(width    = spine_w,
                            height   = spine_h,
                            wall_t   = spine_t,
                            corner_r = spine_r);
        cradle();
    }
}

// Clip dropped onto its side and shifted so its lowest Z is at Z=0 —
// the whole side profile rests on the bed for a low-support print.
// In world Y after the flat-rotation, the clip's "top fold to arm tip"
// runs along Y from `-clip_top_r - clip_wall_t` to `clip_grip_h + clip_arm_extend`.
module _printable_clip() {
    translate([0, 0, clip_width / 2])
        rotate([90, 0, 0])
            clip(grip_d = clip_grip_d, grip_h = clip_grip_h,
                 width = clip_width, wall_t = clip_wall_t,
                 top_r = clip_top_r, arm_extend = clip_arm_extend);
}

// ---- output ----
if (render_target == "clip") {
    _printable_clip();
} else if (render_target == "holder") {
    remote_holder();
} else if (render_target == "all") {
    // Both parts sit with their lowest face at Z=0 (the bed). Clip on
    // the left (laid flat), holder on the right (standing upright on
    // its cradle floor).
    clip_x_w = clip_top_r + clip_wall_t * 2 + clip_grip_d;  // clip's X footprint
    translate([-all_spacing - clip_x_w / 2, 0, 0])
        _printable_clip();
    translate([all_spacing + cradle_outer_w / 2, 0, 0])
        remote_holder();
}
// modular-clip.scad — parametric spring clip + standardised dovetail
// connector for mix-and-match holders.
// Author: John Mylchreest <jmylchreest@gmail.com>. MIT licensed.
//
// The "clip system" is a two-part design:
//   * A clip body (this file) that grips an edge (belt, shelf back, desk
//     edge, etc.) with a sprung hairpin shape. The downward-extending arm
//     of the clip carries a dovetail rail on its outside face.
//   * A holder body (your model) with a matching dovetail SLOT on its
//     back that slides onto the clip from above.
//
// Any clip mates with any holder as long as both use the constants below.
// Vary clip width / grip depth / arm length per use; vary holder geometry
// per item — the dovetail interface stays fixed.
//
// Frame: the clip is rendered with the top fold at +Z, arms hanging in
// -Z, the gripped edge passing through in ±Y (so the clip width is along
// Y). The back arm is at X=0 (against the wall side); the front arm is
// at X = 2*wall_t + grip_d, with the dovetail rail on its +X (outward)
// face. The front arm extends below the grip region by `arm_extend` mm
// to carry the rail.

/* [Standard dovetail interface — DO NOT change per-model] */
CLIP_DOVETAIL_W_BASE    = 12.0;  // rail base width (against mount surface)
CLIP_DOVETAIL_W_TOP     =  8.0;  // rail top width (narrower → locks)
CLIP_DOVETAIL_D         =  3.0;  // how proud the rail stands
CLIP_DOVETAIL_L         = 20.0;  // length along the slide direction
CLIP_DOVETAIL_CLEARANCE =  0.25; // slot is this much larger than rail per side

// Accessors so `use<>` consumers can read the constants (variables
// aren't imported by use<>).
function clip_dovetail_w_base()    = CLIP_DOVETAIL_W_BASE;
function clip_dovetail_w_top()     = CLIP_DOVETAIL_W_TOP;
function clip_dovetail_d()         = CLIP_DOVETAIL_D;
function clip_dovetail_l()         = CLIP_DOVETAIL_L;
function clip_dovetail_clearance() = CLIP_DOVETAIL_CLEARANCE;

// Cross-section of the dovetail in 2D, centred on the slide-axis. The
// shape is drawn in OpenSCAD's XY plane (drawing X = width across, drawing
// Y = standoff from the mount surface). Apply `extra` to scale up
// uniformly — used by the slot to add slide clearance.
module _dovetail_section_2d(extra = 0) {
    wb = CLIP_DOVETAIL_W_BASE + 2 * extra;
    wt = CLIP_DOVETAIL_W_TOP  + 2 * extra;
    d  = CLIP_DOVETAIL_D       + extra;
    polygon([
        [-wb / 2, 0],
        [ wb / 2, 0],
        [ wt / 2, d],
        [-wt / 2, d],
    ]);
}

// Positive dovetail rail. Origin at the centre of the mount-surface side
// (so the rail's base sits on Z=0 of its parent's surface after that
// surface is rotated to face +X). The rail stands in +X, with width
// along Y and length running along Z (centred at origin).
//   length      mm of rail length along the slide axis (default = CLIP_DOVETAIL_L)
//
// Holder slot opens at the +Z end; rail's matching closed end on the
// slot side supports the holder under gravity, so no separate stop tab
// is needed — just rely on the slot's closed -Z cap meeting the rail's
// -Z bottom face.
module dovetail_rail(length = CLIP_DOVETAIL_L) {
    // Section drawn in XY (X = width, Y = standoff), extruded in +Z.
    // rotate([0, 0, -90]) maps:
    //   drawing X (width)    → world -Y (centred → ±Y)
    //   drawing Y (standoff) → world +X
    //   extrude Z (length)   → world +Z
    rotate([0, 0, -90])
        linear_extrude(height = length, center = true)
            _dovetail_section_2d();
}

// Negative dovetail slot for subtraction. Same frame as `dovetail_rail`:
// rail base at X=0, depth into +X, width ±Y, slide along ±Z.
// `open_ends` says which Z end(s) are open through the parent. The
// default "high" opens at +Z so the holder can slide DOWN onto the
// rail; the closed -Z end caps the slot and rests on the rail's -Z
// face, supporting the holder under gravity.
module dovetail_slot(length    = CLIP_DOVETAIL_L + 0.6,
                     open_ends = "high",
                     overcut   = 0.4) {
    // Body — trapezoid prism with clearance.
    rotate([0, 0, -90])
        linear_extrude(height = length, center = true)
            _dovetail_section_2d(extra = CLIP_DOVETAIL_CLEARANCE);

    // Through-cut "lead-in" at the open Z end(s) so the slot exits the
    // parent's top (or bottom) face cleanly even if the parent is taller.
    cap_w = CLIP_DOVETAIL_W_BASE + 2 * CLIP_DOVETAIL_CLEARANCE;
    cap_d = CLIP_DOVETAIL_D      +     CLIP_DOVETAIL_CLEARANCE + overcut;
    if (open_ends == "high" || open_ends == "both")
        translate([-overcut, -cap_w / 2, length / 2])
            cube([cap_d, cap_w, 5]);
    if (open_ends == "low" || open_ends == "both")
        translate([-overcut, -cap_w / 2, -length / 2 - 5])
            cube([cap_d, cap_w, 5]);
}

// Parametric spring clip — hairpin shape. Back arm at X=0, front arm at
// X = 2*wall_t + grip_d. Top fold connects them at the top (+Z). The
// front arm extends in -Z below the grip region by `arm_extend` mm; that
// extension carries the dovetail rail on its +X face.
//
//   grip_d      mm — thickness of the edge being gripped (channel width)
//   grip_h      mm — vertical extent of the grip region (both arms cover)
//   width       mm — clip width along Y (along the gripped edge)
//   wall_t      mm — plastic wall thickness
//   top_r       mm — inner radius of the 180° top fold (clamped to grip_d/2)
//   arm_extend  mm — how far the front arm extends below the grip in -Z
//                    (must be ≥ CLIP_DOVETAIL_L to hold the rail)
//   with_rail   bool — draw the dovetail rail on the front arm extension
//
// Top of the back arm sits at Z = 0; arms hang in -Z; top fold curves up
// into +Z.
module clip(
    grip_d     = 5,
    grip_h     = 25,
    width      = 28,
    wall_t     = 2.5,
    top_r      = 2.0,
    arm_extend = 24,
    with_rail  = true
) {
    // 2D side profile in OpenSCAD XY (drawing X = world X, drawing Y =
    // world Z). After linear_extrude in +Z then rotate, the profile lies
    // in world XZ with the extruded width along Y.
    rotate([90, 0, 0])
        linear_extrude(height = width, center = true)
            _clip_profile_2d(grip_d, grip_h, wall_t, top_r, arm_extend);

    if (with_rail) {
        // Front arm outer face is at world X = 2*wall_t + grip_d.
        // Extension occupies Z = [-(grip_h + arm_extend), -grip_h];
        // rail is centred along the extension and along the clip width.
        rail_z = -grip_h - arm_extend / 2;
        rail_x = 2 * wall_t + grip_d;
        translate([rail_x, 0, rail_z])
            dovetail_rail(length = min(arm_extend - 1, CLIP_DOVETAIL_L));
    }
}

// 2D side profile of the clip in OpenSCAD's XY plane:
//   drawing X = world X (across the channel)
//   drawing Y = world Z (vertical — top of clip at higher Y, arms hang in -Y)
// Back arm at drawing X in [0, wall_t]. Front arm at drawing X in
// [wall_t + grip_d, 2*wall_t + grip_d]. The top fold curves above Y = 0.
module _clip_profile_2d(grip_d, grip_h, wall_t, top_r, arm_extend) {
    r_in  = max(top_r, grip_d / 2);
    r_out = r_in + wall_t;
    cx    = wall_t + grip_d / 2;

    union() {
        // Back arm: from (0, -grip_h) up to (wall_t, 0)
        translate([0, -grip_h]) square([wall_t, grip_h]);
        // Front arm: from (wall_t+grip_d, -(grip_h+arm_extend)) up to (2*wall_t+grip_d, 0)
        translate([wall_t + grip_d, -(grip_h + arm_extend)])
            square([wall_t, grip_h + arm_extend]);
        // Top fold: semi-annulus above Y = 0
        difference() {
            translate([cx, 0]) circle(r = r_out);
            translate([cx, 0]) circle(r = r_in);
            // Keep only the +Y half — chop off everything at Y < 0
            translate([cx - r_out - 1, -r_out - 1])
                square([2 * r_out + 2, r_out + 1]);
        }
    }
}

// Demo — only runs when this file is opened directly.
if ($preview) {
    $fa = 1; $fs = 0.2; $fn = 64;
    color("SteelBlue") clip();
    // Visualise the slot side as a translucent block with the slot cut.
    translate([60, 0, -25])
        color("LightCoral", 0.7)
            difference() {
                translate([-3, -15, -20]) cube([15, 30, 35]);
                translate([0, 0, 0]) dovetail_slot();
            }
}

// modular-clip.scad — parametric spring clip + standardised dovetail
// connector for mix-and-match holders.
// Author: John Mylchreest <jmylchreest@gmail.com>. MIT licensed.
//
// The "clip system" is a two-part design:
//   * A clip body (this file) that grips an edge (belt, shelf back, desk
//     edge, etc.) with a sprung hairpin shape. The downward-extending
//     arm of the clip carries a dovetail SLOT (female) on its outside
//     face, closed at the bottom so the slot's closed end acts as a
//     "bottom plate" that holds the holder up under load.
//   * A holder body (your model) with the matching dovetail RAIL (male)
//     on its back. The rail has small friction bumps to give a snug
//     hold. Slide the holder DOWN onto the clip from above; the rail
//     enters the slot through the open top, the bumps grip on the way
//     down, and the slot's closed bottom catches the rail when it
//     bottoms out.
//
// Any clip mates with any holder as long as both use the constants below.
// Vary clip width / grip depth / arm length per use; vary holder geometry
// per item — the dovetail interface stays fixed.
//
// Frame: the clip is rendered with the top fold at +Z, arms hanging in
// -Z, the gripped edge passing through in ±Y. The back arm is at X=0
// (against the wall side); the front arm is at X = 2*wall_t + grip_d
// (locally thickened in the extension region to make room for the slot,
// cut into the +X outward face).

/* [Standard dovetail interface — DO NOT change per-model] */
// Sized for confident hold under load: 14 × 4 mm cross-section gives a
// 56 mm² bottom-face contact patch carrying the holder's weight, and the
// 2 mm undercut per side resists any pull-off perpendicular to the slide
// axis. 25 mm of engaged length keeps the holder from rocking.
CLIP_DOVETAIL_W_BASE    = 14.0;  // rail base width (against mount surface)
CLIP_DOVETAIL_W_TOP     = 10.0;  // rail top width (narrower → locks)
CLIP_DOVETAIL_D         =  4.0;  // how proud the rail stands
CLIP_DOVETAIL_L         = 25.0;  // length along the slide direction
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
// (so the rail's base sits on Z=0 of its parent's surface). The rail
// stands in +X, with width along Y and length along Z (centred). Two
// small friction bumps on the rail's +X (outermost) face grip the slot's
// interior as the rail slides in, holding the holder snugly in place.
//
//   length     mm rail length along the slide axis (default = CLIP_DOVETAIL_L)
//   bumps      bool — include friction bumps (default true)
//   bump_size  mm — bump proud height (default 0.4)
//   bump_count integer — number of bumps along the rail length (default 2)
module dovetail_rail(length     = CLIP_DOVETAIL_L,
                     bumps      = true,
                     bump_size  = 0.4,
                     bump_count = 2) {
    union() {
        // Rail body. Section drawn in XY (X = width, Y = standoff),
        // extruded in +Z. rotate([0, 0, -90]) maps:
        //   drawing X (width)    → world -Y (centred → ±Y)
        //   drawing Y (standoff) → world +X
        //   extrude Z (length)   → world +Z
        rotate([0, 0, -90])
            linear_extrude(height = length, center = true)
                _dovetail_section_2d();

        // Friction bumps on the +X (outer) face of the rail. Hemispheres
        // sized to give a slight interference fit with the slot's clearance
        // — bump_size mm proud → bump_size − slot_clearance mm of squeeze.
        if (bumps && bump_count > 0) {
            br = bump_size;
            for (i = [0 : bump_count - 1]) {
                z = bump_count == 1
                        ? 0
                        : -length / 2 + (i + 0.5) * length / bump_count;
                translate([CLIP_DOVETAIL_D, 0, z])
                    sphere(r = br);
            }
        }
    }
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
// front arm extends in -Z below the grip region by `arm_extend` mm; the
// outside of the extension is locally thickened so a dovetail slot
// (female) can be cut into it without breaking through to the grip
// channel. The slot opens at +Z (toward the grip) and is closed at -Z
// — that closed bottom is the "bottom plate" that catches the holder's
// rail and supports it under gravity.
//
//   grip_d      mm — thickness of the edge being gripped (channel width)
//   grip_h      mm — vertical extent of the grip region
//   width       mm — clip width along Y
//   wall_t      mm — plastic wall thickness in the grip region
//   top_r       mm — inner radius of the 180° top fold (clamped to grip_d/2)
//   arm_extend  mm — how far the front arm extends below the grip in -Z
//                    (must be ≥ CLIP_DOVETAIL_L for the slot to fit)
//   with_slot   bool — cut the dovetail slot into the extension
module clip(
    grip_d     = 5,
    grip_h     = 25,
    width      = 28,
    wall_t     = 2.5,
    top_r      = 2.0,
    arm_extend = 30,
    with_slot  = true
) {
    // Extension needs enough thickness to hold the slot. The slot is
    // CLIP_DOVETAIL_D + clearance deep; leave at least 1.5 mm of arm
    // wall behind it. Build an extra bump on the outside of the front
    // arm in the extension region to hit that thickness.
    slot_total_d = CLIP_DOVETAIL_D + CLIP_DOVETAIL_CLEARANCE;
    min_ext_thk  = slot_total_d + 1.5;
    ext_bump     = max(0, min_ext_thk - wall_t);
    arm_outer_x  = 2 * wall_t + grip_d;
    ext_outer_x  = arm_outer_x + ext_bump;

    difference() {
        union() {
            // Base hairpin body (2D side profile extruded along width).
            rotate([90, 0, 0])
                linear_extrude(height = width, center = true)
                    _clip_profile_2d(grip_d, grip_h, wall_t, top_r, arm_extend);

            // Extension thickener — only in the extension Z range, on the
            // outside of the front arm. Slot is cut from this thicker wall.
            if (ext_bump > 0)
                translate([arm_outer_x - 0.01,
                           -width / 2,
                           -grip_h - arm_extend])
                    cube([ext_bump + 0.01, width, arm_extend]);
        }

        if (with_slot) {
            // Slot opens at +Z, closed at -Z (the "bottom plate"). Cut
            // from the extension's outer face (+X) inward toward the
            // grip. rotate([0,0,180]) flips the rail-frame +X standoff
            // to world -X so the slot eats INTO the arm.
            slot_centre_z = -grip_h - CLIP_DOVETAIL_L / 2 - 2.5;
            translate([ext_outer_x, 0, slot_centre_z])
                rotate([0, 0, 180])
                    dovetail_slot(open_ends = "high");
        }
    }
}

// Reusable back-plate for a modular holder — the MALE side of the
// connector. A flat plate with the dovetail RAIL (with friction bumps)
// mounted on its back face. Accessories union their body in front of
// the plate (+Y) or below it (-Z).
//
// To install: lift the holder above the clip, line up the rail's top
// with the clip's slot opening, and slide DOWN. The bumps engage the
// slot interior with light friction; the rail bottoms out on the slot's
// closed bottom (the clip's "bottom plate"), which carries the load.
//
// Frame: plate centred along X, front face at Y=0, back face at
// Y=-wall_t, bottom at Z=0, top at Z=height. The rail sits on the back
// face (-Y side), centred along X, near the top of the plate (so the
// accessory body can extend down past it).
//
//   width                  mm — X extent (default leaves margin around
//                               the rail base width)
//   height                 mm — Z extent (default = rail length + room
//                               for the accessory below)
//   wall_t                 mm — Y thickness of the plate behind the rail
//                               (default 3 mm — backs the rail without
//                               being bulky)
//   corner_r               mm — plate outer corner radius (cosmetic)
//   rail_z_offset_from_top mm — rail top sits this far below the plate
//                               top so the plate has room above the rail
//                               (default 0 → rail flush with plate top)
//   bumps                  bool — include friction bumps on the rail
module modular_holder_back(width                  = CLIP_DOVETAIL_W_BASE + 6,
                           height                 = CLIP_DOVETAIL_L + 8,
                           wall_t                 = 3,
                           corner_r               = 2,
                           rail_z_offset_from_top = 0,
                           bumps                  = true) {
    rail_centre_z = height - CLIP_DOVETAIL_L / 2 - rail_z_offset_from_top;

    // Flat plate, X centred on 0, Y from -wall_t to 0, Z from 0 to height.
    // rotate([-90,0,0]) puts the extrusion thickness into +Y; translate
    // by -wall_t shifts it into the -Y half-space (behind the front face
    // at Y=0).
    translate([0, -wall_t, height / 2])
        rotate([-90, 0, 0])
            linear_extrude(height = wall_t)
                offset(r = corner_r) offset(r = -corner_r)
                    square([width, height], center = true);

    // Male rail on the plate's back face (Y = -wall_t), standoff into -Y.
    // rotate([0,0,180]) flips the library frame's +X standoff to -X;
    // rotate([0,0,90]) would put standoff in +Y, so combine to get -Y.
    // Net rotation: rotate([0,0,-90]) maps +X (rail standoff) → -Y.
    translate([0, -wall_t, rail_centre_z])
        rotate([0, 0, -90])
            dovetail_rail(bumps = bumps);
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

// Demo — only runs when this file is opened directly. Shows the clip
// (with the female slot in its extension) on the left and a
// `modular_holder_back` plate (with the male rail + friction bumps on
// its back) on the right.
if ($preview) {
    $fa = 1; $fs = 0.2; $fn = 64;
    color("SteelBlue") clip();
    color("LightCoral") translate([55, 0, -50])
        modular_holder_back();
}

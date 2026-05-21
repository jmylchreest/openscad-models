// bambu-rfid-tag — thin RFID sticker holder that snaps into the side
// holes of a Bambu filament spool. A round disc holds an adhesive RFID
// sticker (default 25.5 mm) on the visible face; two snap-fit posts on
// the back clip into two adjacent spool side holes.
//
// Spool hole geometry (measured on a Bambu spool side): each hole is
// 2.5 mm at the surface, opens out to ~2.8 mm interior and is ~3 mm
// deep. The small mouth catches the barb behind it on the way out, so
// the snap-fit only needs to flex enough to push the barb past the
// 2.5 mm pinch on insertion.
//
// Author: John Mylchreest <jmylchreest@gmail.com>. MIT licensed.

/* [Output] */
// `outside` — disc mounts on the outer face of the spool, clips bite
//             into the spool hole's surface mouth (short clip total ≤ 1 mm).
// `inside`  — disc mounts on the inner face of the spool, clips pass
//             through the spool side wall and the barb catches on the
//             outside (~3.2 mm clip total).
// `all`     — both variants side-by-side on the X axis for slicing.
render_target = "all";  // [outside, inside, all]

/* [RFID sticker] */
tag_d           = 25.5;   // sticker diameter
tag_clear       = 0.5;    // recess sized = tag_d + tag_clear (per total)
tag_recess_h    = 0.4;    // recess depth (≈ sticker thickness)

/* [Disc — visible face on the outside of the spool] */
disc_d          = 30;     // overall disc diameter
disc_t          = 1.2;    // total disc thickness (6 layers at 0.2 mm)
disc_chamfer    = 0.4;    // edge chamfer (2 layers at 0.2 mm — prints cleaner than 1)

/* [Clips — shared cross-section across both variants] */
// Defaults for a Bambu spool side hole: 2.5 mm at the mouth, 2.8 mm
// inside, 3 mm deep. The post slides through the 2.5 mm mouth, the
// barb pops into the 2.8 mm chamber and the mouth pinches behind it.
//
// Sizes are picked so every wall and gap is a clean multiple of the
// 0.4 mm extrusion width: slit = 0.8 mm (2 lines), post halves =
// (2.4 − 0.8) / 2 = 0.8 mm (2 lines), no awkward fractional lines.
// Print with Arachne / variable-line-width enabled if your slicer
// supports it (PrusaSlicer, OrcaSlicer, recent Cura).
clip_post_d     = 2.4;    // post diameter (passes the 2.5 mm mouth with 0.1 mm/side play)
clip_barb_d     = 2.8;    // barb base diameter (sits in the 2.8 mm chamber)
clip_spacing    = 4.5;    // centre-to-centre distance between the two clips
clip_slit_w     = 0.8;    // slit width through the post — gives the snap-fit flex

/* [Outside-variant clip] */
// Short clip — the barb only needs to clear the spool hole's 2.5 mm
// surface mouth, so the whole post + barb fits in well under 1 mm.
outside_clip_post_l = 0.6;  // straight post before the barb starts
outside_clip_barb_h = 0.6;  // cone height for the barb

/* [Inside-variant clip] */
// Long clip — the post passes through the full ~3 mm thickness of the
// spool side wall, with a tiny barb that pops out the other side and
// catches on the 2.5 mm mouth from the outside.
inside_clip_post_l  = 3.2;  // length of the straight post (≈ spool wall thickness)
inside_clip_barb_h  = 0.6;  // small barb height — minimal protrusion on the outer face

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

// ---- modules ----

// One snap-fit clip — straight post + conical barb at the tip + a slit
// down the middle so the two halves can flex inward to push the barb
// through the spool hole's narrower mouth. Origin at the base of the
// post (Z=0 sits on the disc's back face), post grows in +Z.
module _clip(post_l, barb_h) {
    difference() {
        union() {
            // Straight cylindrical post
            cylinder(d = clip_post_d, h = post_l);
            // Conical barb — wide where it meets the post, narrow at the tip
            translate([0, 0, post_l])
                cylinder(d1 = clip_barb_d, d2 = clip_post_d * 0.7,
                         h = barb_h);
        }
        // Slit cuts through the post + barb along the Y axis so the two
        // halves can compress inward to clear the 2.5 mm mouth.
        translate([-clip_slit_w / 2,
                   -clip_barb_d / 2 - 0.5,
                   -0.01])
            cube([clip_slit_w,
                  clip_barb_d + 1,
                  post_l + barb_h + 0.02]);
    }
}

// Full tag holder. Prints flat with the sticker recess facing the bed
// and the two clip posts standing up — no supports needed. After
// printing, peel off, drop the sticker into the recess, and clip onto
// the spool. `post_l` / `barb_h` pick which variant.
module tag_holder(post_l, barb_h) {
    difference() {
        union() {
            // Disc body with a tiny edge chamfer for a finished look.
            hull() {
                cylinder(d = disc_d - 2 * disc_chamfer, h = disc_t);
                cylinder(d = disc_d, h = disc_t - disc_chamfer);
            }
            // Two snap-fit posts on the back face (Z = disc_t).
            translate([-clip_spacing / 2, 0, disc_t]) _clip(post_l, barb_h);
            translate([ clip_spacing / 2, 0, disc_t]) _clip(post_l, barb_h);
        }
        // Sticker recess on the BOTTOM face (Z=0 face). When the part
        // is printed, the recess sits on the bed; flip the part after
        // printing and the recess faces you, ready for the sticker.
        translate([0, 0, -0.01])
            cylinder(d = tag_d + tag_clear, h = tag_recess_h + 0.01);
    }
}

// ---- output ----
if (render_target == "outside") {
    tag_holder(post_l = outside_clip_post_l, barb_h = outside_clip_barb_h);
} else if (render_target == "inside") {
    tag_holder(post_l = inside_clip_post_l,  barb_h = inside_clip_barb_h);
} else if (render_target == "all") {
    // Side-by-side with a small gap so the slicer can pick each up
    // for a separate plate if you only want to print one variant.
    translate([-disc_d / 2 - 5, 0, 0])
        tag_holder(post_l = outside_clip_post_l, barb_h = outside_clip_barb_h);
    translate([ disc_d / 2 + 5, 0, 0])
        tag_holder(post_l = inside_clip_post_l,  barb_h = inside_clip_barb_h);
}

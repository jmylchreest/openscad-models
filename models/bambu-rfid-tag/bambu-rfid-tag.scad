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

/* [RFID sticker] */
tag_d           = 25.5;   // sticker diameter
tag_clear       = 0.5;    // recess sized = tag_d + tag_clear (per total)
tag_recess_h    = 0.4;    // recess depth (≈ sticker thickness)

/* [Disc — visible face on the outside of the spool] */
disc_d          = 30;     // overall disc diameter
disc_t          = 1.2;    // total disc thickness (thin)
disc_chamfer    = 0.4;    // small edge chamfer on the visible face (cosmetic)

/* [Clips — snap-fit posts that engage two adjacent spool holes] */
// Defaults for a Bambu spool side hole: 2.5 mm at the mouth, 2.8 mm
// inside, 3 mm deep. The post slides through the 2.5 mm mouth, the
// barb pops into the 2.8 mm chamber and the mouth pinches behind it.
clip_post_d     = 2.3;    // post diameter (passes the 2.5 mm mouth with 0.1 mm/side play)
clip_barb_d     = 2.7;    // barb base diameter (sits in the 2.8 mm chamber)
clip_post_l     = 2.4;    // straight post length before the barb starts
clip_barb_h     = 0.6;    // cone height for the barb
clip_spacing    = 4.5;    // centre-to-centre distance between the two clips
clip_slit_w     = 0.8;    // slit width through the post — gives the snap-fit flex

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

// ---- modules ----

// One snap-fit clip — straight post + conical barb at the tip + a slit
// down the middle so the two halves can flex inward to push the barb
// through the spool hole's narrower mouth. Origin at the base of the
// post (Z=0 sits on the disc's back face), post grows in +Z.
module _clip() {
    difference() {
        union() {
            // Straight cylindrical post
            cylinder(d = clip_post_d, h = clip_post_l);
            // Conical barb — wide where it meets the post, narrow at the tip
            translate([0, 0, clip_post_l])
                cylinder(d1 = clip_barb_d, d2 = clip_post_d * 0.7,
                         h = clip_barb_h);
        }
        // Slit cuts through the post + barb along the Y axis so the two
        // halves can compress inward to clear the 2.5 mm mouth.
        translate([-clip_slit_w / 2,
                   -clip_barb_d / 2 - 0.5,
                   -0.01])
            cube([clip_slit_w,
                  clip_barb_d + 1,
                  clip_post_l + clip_barb_h + 0.02]);
    }
}

// Full tag holder. Prints flat with the sticker recess facing the bed
// and the two clip posts standing up — no supports needed. After
// printing, peel off, drop the sticker into the recess, and clip onto
// the spool.
module tag_holder() {
    difference() {
        union() {
            // Disc body with a tiny edge chamfer for a finished look.
            hull() {
                cylinder(d = disc_d - 2 * disc_chamfer, h = disc_t);
                cylinder(d = disc_d, h = disc_t - disc_chamfer);
            }
            // Two snap-fit posts on the back face (Z = disc_t).
            translate([-clip_spacing / 2, 0, disc_t]) _clip();
            translate([ clip_spacing / 2, 0, disc_t]) _clip();
        }
        // Sticker recess on the BOTTOM face (Z=0 face). When the part
        // is printed, the recess sits on the bed; flip the part after
        // printing and the recess faces you, ready for the sticker.
        translate([0, 0, -0.01])
            cylinder(d = tag_d + tag_clear, h = tag_recess_h + 0.01);
    }
}

tag_holder();

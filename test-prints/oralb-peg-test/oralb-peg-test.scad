// oralb-peg-test — minimum-material fit-check piece for the Oral-B
// body peg. Prints a single peg standing on a thin plate; push your
// brush onto it to confirm the slide-fit before committing the
// tolerance to oralb-caddy.scad's body_peg_tolerance.
//
// Print flat (plate on the bed, peg sticking up). No support needed.
//
// Author: John Mylchreest <jmylchreest@gmail.com>. MIT licensed.

// include<> (not use<>) so the ORALB_PEG_* constants are visible here
// for the plate-sizing calculation. The library has no top-level
// geometry so include is safe — nothing gets emitted by accident.
include <../../libraries/toothbrush-pegs/toothbrush-pegs.scad>

/* [Peg] */
// The peg's base shape and size are fixed by the library; tolerance,
// taper and chamfer are the per-print knobs. Re-print at different
// values if the brush is too loose, too tight, or hard to align.
peg_tolerance = 0.3;
peg_taper     = 2.0;   // total XY shrinkage from base to top of main body
peg_chamfer   = 0.5;   // extra per-side inset at the very top (insertion lead-in)
peg_chamfer_h = 0.5;   // vertical height of the chamfer (45° at 0.5/0.5)

/* [Plate] */
plate_t       = 1.5;
plate_padding = 4;     // extra material around the peg on each side

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

// ---- derived plate size ----
plate_w = ORALB_PEG_W_BACK + 2 * plate_padding;
plate_d = ORALB_PEG_LENGTH + 2 * plate_padding;

module test_piece() {
    union() {
        translate([0, 0, plate_t / 2])
            cube([plate_w, plate_d, plate_t], center = true);
        translate([0, 0, plate_t])
            oralb_body_peg(
                tolerance = peg_tolerance,
                taper     = peg_taper,
                chamfer   = peg_chamfer,
                chamfer_h = peg_chamfer_h
            );
    }
}

test_piece();

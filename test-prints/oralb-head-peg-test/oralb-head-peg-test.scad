// oralb-head-peg-test — minimum-material fit-check piece for the
// Oral-B replacement-head peg. Prints a single thin post standing on
// a small plate; slide a real head down over it to confirm the fit
// before committing the tolerance to oralb-caddy.scad's
// head_peg_tolerance (or to a Skadis dock, drawer insert, etc.).
//
// Print flat (plate on the bed, post sticking up). No support needed.
//
// Author: John Mylchreest <jmylchreest@gmail.com>. MIT licensed.

// include<> (not use<>) so the ORALB_HEAD_PEG_* constants are visible
// here for the plate-sizing calculation. The library has no top-level
// geometry so include is safe — nothing gets emitted by accident.
include <../../libraries/toothbrush-pegs/toothbrush-pegs.scad>

/* [Peg] */
// The peg's shape and size are fixed by the library — tolerance is the
// only per-print knob. Re-print at a different value if the head's too
// loose or too tight.
peg_tolerance = 0.3;

/* [Plate] */
plate_t       = 1.5;
plate_padding = 6;     // extra material around the peg on each side

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

// ---- derived plate size ----
plate_side = ORALB_HEAD_PEG_D + 2 * plate_padding;

module test_piece() {
    union() {
        translate([0, 0, plate_t / 2])
            cube([plate_side, plate_side, plate_t], center = true);
        translate([0, 0, plate_t])
            oralb_head_peg(tolerance = peg_tolerance);
    }
}

test_piece();

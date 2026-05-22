// oralb-peg-test — minimum-material test piece for the Oral-B body
// peg. Prints a row of pegs at increasing tolerance values on a thin
// plate; try inserting your brush onto each and pick the one that
// slides on snug without rattling and without needing force. Then
// use that tolerance in oralb-caddy.scad's body_peg_tolerance.
//
// Print flat (plate on the bed, pegs sticking up). One layer of brim
// + a couple of perimeters is plenty; the plate is just a handle for
// the test, not a structural part.
//
// Author: John Mylchreest <jmylchreest@gmail.com>. MIT licensed.

// include<> (not use<>) so the ORALB_PEG_* constants are visible here
// for the plate-sizing calculation. The library has no top-level
// geometry, so include is safe — nothing gets emitted by accident.
include <../../libraries/toothbrush-pegs/toothbrush-pegs.scad>

/* [Tolerances to test] */
// One peg per value, laid out left → right on the plate. Halve the
// step (e.g. [0.2, 0.3, 0.4, 0.5]) once you've narrowed in on the right
// range for your printer / filament.
tolerances    = [0.0, 0.2, 0.4, 0.6];

/* [Peg] */
peg_height    = 11;     // ≤ ORALB_PEG_DEPTH_MAX (12.5)
peg_taper     = 0.85;
peg_spacing   = 18;     // mm between peg centres

/* [Plate] */
plate_t       = 1.5;
plate_padding = 5;      // extra material around the row of pegs

/* [Tolerance labels (raised text on the plate)] */
label_size    = 4;
label_depth   = 0.4;
label_gap     = 3;      // distance between peg back edge and label

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

// ---- derived layout ----

// Plate is just big enough to hold the row of pegs + their labels.
plate_w = (len(tolerances) - 1) * peg_spacing + ORALB_PEG_D_BACK + 2 * plate_padding;
plate_d = ORALB_PEG_LENGTH + label_size + label_gap + 2 * plate_padding;

// Peg sits above the X axis on the plate; label below it.
peg_y    =  plate_d / 2 - plate_padding - ORALB_PEG_LENGTH / 2;
label_y  = -plate_d / 2 + plate_padding + label_size / 2;

module test_plate() {
    union() {
        translate([0, 0, plate_t / 2])
            cube([plate_w, plate_d, plate_t], center = true);

        for (i = [0 : len(tolerances) - 1]) {
            tol = tolerances[i];
            x   = (i - (len(tolerances) - 1) / 2) * peg_spacing;

            translate([x, peg_y, plate_t])
                oralb_body_peg(
                    height    = peg_height,
                    tolerance = tol,
                    taper     = peg_taper
                );

            translate([x, label_y, plate_t])
                linear_extrude(label_depth)
                    text(str(tol),
                         size   = label_size,
                         halign = "center",
                         valign = "center");
        }
    }
}

test_plate();

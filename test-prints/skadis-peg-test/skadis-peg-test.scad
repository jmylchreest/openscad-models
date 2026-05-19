// skadis-peg-test.scad — minimum-material peg-fit test. Small pads behind
// each peg, joined by thin triangulated struts. Prints fast and lets you
// verify peg geometry and grid alignment on a real Skadis board.
// Author: John Mylchreest <jmylchreest@gmail.com>

use <../../libraries/ikea-skadis/ikea-skadis.scad>

/* [Pegs] */
peg_cols          = 3;
peg_rows          = 3;
standoff_distance = 0;
peg_retainer      = false;

// Skip [col, row] indices for a non-uniform layout.
//   [[1, 1]]            drops the right-stagger peg of the middle row → 2-1-2 diamond
//   [[1, 0], [0, 2]]    corners-only
peg_skip          = [];

/* [Frame] */
frame_thickness  = 0.5;     // Y thickness of pads + struts
pad_w            = 4;       // pad X width
pad_h            = 15;      // pad Z height
pad_corner_r     = 2;
strut_w          = 3;       // strut cross-section
strut_adjacency  = 30;      // mm — connect pegs within this centre-to-centre distance

/* [Layout] */
print_orientation = true;   // pads flat on bed, pegs sticking up

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 48;

// ---- derived ----
pad_y = -standoff_distance - frame_thickness;

// Z offset from slot centre to anchor centre. `use<>` doesn't import lib
// vars, so hard-coded. = -SKADIS_SLOT_H + SKADIS_TAB_H for default Skadis.
anchor_z_offset = -10;

function _is_skipped(i, j) =
    len([for (s = peg_skip) if (s[0] == i && s[1] == j) 1]) > 0;

// Each peg's anchor centre in the modelling frame. Pads/struts hang off these.

peg_positions = [
    for (i = [0 : peg_cols - 1])
        for (j = [0 : peg_rows - 1])
            if (!_is_skipped(i, j))
                [skadis_peg_x(i, peg_cols, "center")
                     + skadis_row_stagger(j, true, 0),
                 0,
                 skadis_peg_z(j, peg_rows, "bottom") + anchor_z_offset]
];

function _dist_xz(a, b) =
    sqrt((a[0] - b[0]) * (a[0] - b[0]) + (a[2] - b[2]) * (a[2] - b[2]));

module _pad(pos_x, pos_z) {
    translate([pos_x - pad_w / 2, pad_y, pos_z - pad_h / 2])
        cube([pad_w, frame_thickness, pad_h]);
}

// Hull two endpoint cubes. Using cubes (not cylinders + rotate-extrude)
// avoids a CGAL pickup issue earlier revisions hit.
module _strut(a, b) {
    hull() {
        for (p = [a, b])
            translate([p[0] - strut_w / 2, pad_y, p[2] - strut_w / 2])
                cube([strut_w, frame_thickness, strut_w]);
    }
}

module test_frame() {
    union() {
        for (p = peg_positions)
            _pad(p[0], p[2]);

        // i < j filter (over the full Cartesian product) avoids the deprecated
        // reversed range that `j = [i+1 : len-1]` produces at i = len-1.
        for (i = [0 : len(peg_positions) - 1])
            for (j = [0 : len(peg_positions) - 1])
                if (i < j && _dist_xz(peg_positions[i], peg_positions[j]) <= strut_adjacency)
                    _strut(peg_positions[i], peg_positions[j]);

        skadis_peg_grid(
            cols = peg_cols, rows = peg_rows,
            anchor = "center", vanchor = "bottom",
            skip = peg_skip,
            standoff = standoff_distance,
            retainer = peg_retainer
        );
    }
}

if (print_orientation) {
    translate([0, 0, standoff_distance + frame_thickness])
        rotate([90, 0, 0])
            test_frame();
} else {
    test_frame();
}

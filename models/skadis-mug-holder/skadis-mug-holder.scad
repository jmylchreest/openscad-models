// Skadis mug holder — open-front container with a handle slot down the front
// and pegs on the back. Author: John Mylchreest <jmylchreest@gmail.com>.

use <../../libraries/container/container.scad>
use <../../libraries/ikea-skadis/ikea-skadis.scad>

/* [Output] */
render_target = "container";  // [container]

/* [Container] */
container_width   = 90;
container_height  = 40;
container_depth   = 90;
wall_thickness    = 2.5;
top_rim_thickness = 3.0;
corner_radius     = 5;

/* [Side panel style — left & right walls] */
side_style       = "solid";   // [solid, hex, grid]
side_solid_base  = 15;        // solid mm at bottom (non-solid styles only)
side_solid_top   = 15;        // solid mm at top    (non-solid styles only)
side_hex_cell    = 12;
side_hex_wall    = 1.6;

/* [Handle slot — front face] */
handle_slot_width   = 32;     // X span (mug handle width budget)
handle_slot_z_from  = 6;      // Z above floor where slot starts
handle_slot_z_to    = 80;     // Z where slot ends — overshoots into the open top
                              // so the handle can slide in from above
handle_slot_corner  = 4;

/* [Pegs] */
peg_cols          = 2;
peg_rows          = 2;
peg_anchor_edge   = "center";  // "left" | "right" | "center" — back-view edges
peg_x_from_anchor = undef;     // distance from anchor edge; undef = auto for "center"
peg_z_from_bottom = 18;
peg_retainer      = false;

/* [Standoff] */
standoff_distance = 0;

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

// ---- derived ----
container_origin = [-container_width / 2,
                    -standoff_distance - container_depth,
                    0];

// Same back-view → library anchor mapping as the main container model.
_lib_anchor   = peg_anchor_edge == "left"  ? "right"
              : peg_anchor_edge == "right" ? "left"
              :                              "center";
// Auto-default peg_x_from_anchor so the grid is centred on the container
// width when "center", otherwise positions the leading peg per the user.
_default_x_from_anchor = (container_width - (peg_cols - 1) * 40) / 2;
_x_from_anchor = peg_x_from_anchor == undef ? _default_x_from_anchor : peg_x_from_anchor;
leading_peg_x = peg_anchor_edge == "left"  ?  container_width / 2 - _x_from_anchor
              : peg_anchor_edge == "right" ? -container_width / 2 + _x_from_anchor
              :                               0;

function _side_layers() =
    side_style == "solid"
        ? [["solid", 0, container_height]]
        : [["solid", 0, side_solid_base],
           [side_style, side_solid_base, container_height - side_solid_top,
            [side_hex_cell, side_hex_wall, 2]],
           ["solid", container_height - side_solid_top, container_height]];

faces_spec = side_style == "solid" ? [] :
    [["left",  _side_layers()],
     ["right", _side_layers()]];

cuts_spec = [["front", "slot",
              [0, handle_slot_width, handle_slot_z_from, handle_slot_z_to,
               handle_slot_corner]]];

module mug_holder() {
    union() {
        translate(container_origin)
            container(width = container_width,
                      depth = container_depth,
                      height = container_height,
                      wall = wall_thickness,
                      corner_r = corner_radius,
                      rim_thickness = top_rim_thickness,
                      faces = faces_spec,
                      cuts = cuts_spec);

        translate([leading_peg_x, 0, peg_z_from_bottom])
            skadis_peg_grid(cols = peg_cols, rows = peg_rows,
                            anchor = _lib_anchor, vanchor = "bottom",
                            standoff = standoff_distance,
                            retainer = peg_retainer);
    }
}

mug_holder();

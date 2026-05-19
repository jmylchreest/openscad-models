// Parametric IKEA SKÅDIS container. `render_target` switches between the
// shell and the inserts that drop into it; both read the same top-level
// dimensions so they stay in sync.

use <../../libraries/container/container.scad>
use <../../libraries/ikea-skadis/ikea-skadis.scad>

/* [Output] */
// `all` outputs container + every insert side-by-side on the X axis. Import
// the resulting 3MF into your slicer and use "split to objects" / "arrange"
// to assign each piece to a print plate.
render_target = "all";  // [container, insert_pens, insert_usb, insert_compartments, all]

/* [Container — outer dimensions] */
container_width   = 100;
container_height  = 90;
container_depth   = 100;
wall_thickness    = 2.0;
top_rim_thickness = 2.4;
corner_radius     = 4;

/* [Face styles] */
// Each face is independently "solid", "hex", or "grid"; hex/grid params shared.
left_style       = "hex";      // [solid, hex, grid]
right_style      = "hex";      // [solid, hex, grid]
front_style      = "hex";    // [solid, hex, grid]
back_style       = "solid";    // [solid, hex, grid] — keep solid: pegs attach here
side_solid_base  = 30;         // mm of solid wall at the bottom
side_solid_top   = 5;         // mm of solid wall at the top
side_hex_cell    = 3;          // hex cell flat-to-flat
side_hex_wall    = 0.3;        // wall between hex cells

/* [Pegs] */
peg_cols          = 2;
peg_rows          = 3;
// `peg_anchor_edge` names refer to BACK-VIEW (the mounting perspective).
// Pegs grow AWAY from the anchor edge.
//   "left"   anchored at back-view LEFT,  pegs grow rightward
//   "right"  anchored at back-view RIGHT, pegs grow leftward
//   "center" centred
peg_anchor_edge   = "left";
peg_x_from_anchor = 17;        // distance from anchor edge to leading peg
peg_z_from_bottom = 25;
peg_retainer      = true;

// Optional explicit peg layout. Each row is one row of the grid TOP-to-BOTTOM
// so it reads like an ASCII picture. 1 = peg, 0 = hidden. `undef` = uniform
// peg_cols × peg_rows grid.
//   pegs = [[1, 1], [1, 0], [1, 1]];   // 2-1-2 diamond, middle peg on LEFT
//   pegs = [[1, 1, 1, 1],              // 4-2-4 hourglass
//           [0, 1, 1, 0],
//           [1, 1, 1, 1]];
pegs = [
    [0,1,1],
    [0,0,0],
    [0,1,1]
    ];

/* [Standoff] */
standoff_distance     = 11;
// Flare the parent-side end of the standoff into a bracket shape. Each
// number is extra Z above the top / below the bottom of the standoff on
// the container side. 0/0 = rectangular block (default).
standoff_top_ext      = 5;
standoff_bot_ext      = 6;

/* [Preview] */
show_pegboard_preview = true;  // translucent slab behind the container, $preview only

/* [Inserts — used when render_target = insert_* / all] */
insert_height          = side_solid_base;
insert_clearance       = 0.4;
insert_base_thickness  = 2.0;
insert_cell_wall       = 1.2;

// Per-insert overrides (all of these can be set independently per insert):
//   *_width / *_depth   undef = fill container interior, else mm
//   *_corner_r          single number → all four corners
//                       [fl, fr, bl, br] → per-corner radii (0 = sharp)
//   *_finger_slot       "none" | "back" | "front" | "both"
//                       (boolean true = "back", false = "none")
//   *_grab_tab          "none" | "back" | "front" | "both" — vertical
//                       finger handle protruding above the insert top
//   *_cell_spacing      mm gap between cells (undef = use insert_cell_wall)
//   *_cell_offset       [dx, dy] to nudge the cell grid off-centre

// Grab-tab geometry (shared by all inserts). `frame > 0` makes it a closed
// hoop (handle you can put a finger through); `frame = 0` = solid fin.
// `w = undef` defaults to 50% of the insert width.
insert_grab_tab_w     = undef;
insert_grab_tab_h     = 4;
insert_grab_tab_t     = 3;
insert_grab_tab_frame = 1;
insert_grab_tab_r     = corner_radius;

// Pens — round holes for pens / dowels.
insert_pens_cells        = [1, 6, "round", 12];
insert_pens_width        = 18;
insert_pens_depth        = undef;
insert_pens_corner_r     = [corner_radius, 0, corner_radius, 0];        // single OR [fl,fr,bl,br]
insert_pens_finger_slot  = "none";
insert_pens_grab_tab     = "back";
insert_pens_cell_spacing = 2;
insert_pens_cell_offset  = [-1, 0];

// Compartments — rectangular cells for parts / small items.
insert_compartments_cells        = [1, 1, "rect", 25, container_depth - 10, corner_radius];
insert_compartments_width        = 30;
insert_compartments_depth        = undef;
insert_compartments_corner_r     = [0, corner_radius, 0, corner_radius];
insert_compartments_finger_slot  = "none";
insert_compartments_grab_tab     = "back";
insert_compartments_cell_spacing = 2;
insert_compartments_cell_offset  = [-1, -1];

// USB insert — pocket per cell, mix of USB-A and USB-C as you like.
// Rows are top-to-bottom (ASCII picture of the insert from above).
//   "a" = USB-A pocket (12 × 4.5 mm, small rounded corners)
//   "c" = USB-C pocket (8.25 × 2.4 mm, racetrack)
//   ""  = no pocket (solid)
insert_usb_layout = [
    ["a"],
    ["a"],
    ["a"],
    ["a"],
    ["a"],
    ["c"],
    ["c"],
    ["c"]
];
insert_usb_width          = 20;
insert_usb_depth          = undef;
insert_usb_corner_r       = [0, 0, 0, 0];      // single OR [fl,fr,bl,br]
insert_usb_finger_slot    = "none";
insert_usb_grab_tab       = "back";
insert_usb_rotate_pockets = false;               // true → pockets long-axis along Y
insert_usb_pocket_spacing = 6;               // mm gap between pockets (undef = insert_cell_wall)
insert_usb_grid_offset    = [-3, 2];              // [dx, dy] to nudge the pocket grid
usb_pocket_depth          = 12;                  // blind pocket depth from the top
usb_pocket_clearance      = 0.35;                // added to each pocket dimension

// X spacing between objects in "all" layout.
all_layout_spacing = 30;

/* [Quality] */
$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;
$fn = 64;

// ---- derived ----
// Place the container in world Y so its back-outer-face sits at Y=−standoff
// (pegboard is always at Y=0), and floor at Z=0.
container_origin = [-container_width / 2,
                    -standoff_distance - container_depth,
                    0];

// Back-view edge → library grid anchor (which uses modelling-frame X):
//   back-view LEFT  = modelling +X → library "right"
//   back-view RIGHT = modelling -X → library "left"
_lib_anchor   = peg_anchor_edge == "left"  ? "right"
              : peg_anchor_edge == "right" ? "left"
              :                              "center";
leading_peg_x = peg_anchor_edge == "left"  ?  container_width / 2 - peg_x_from_anchor
              : peg_anchor_edge == "right" ? -container_width / 2 + peg_x_from_anchor
              :                               0;

// `pegs` matrix → skip list. The matrix is TOP-to-BOTTOM but the grid is
// vanchor="bottom", so we flip the row index when building the skip list.
_use_pegs  = pegs != undef;
_grid_rows = _use_pegs ? len(pegs) : peg_rows;
_grid_cols = _use_pegs ? max([for (row = pegs) len(row)]) : peg_cols;
_peg_skip  = !_use_pegs ? [] : [
    for (j = [0 : _grid_rows - 1])
        for (i = [0 : _grid_cols - 1])
            let (row = pegs[_grid_rows - 1 - j])
                if (i >= len(row) || row[i] == 0)
                    [i, j]
];

// Build a layer stack for a given face style. Solid faces get a no-op entry
// (which the container library then ignores); textured faces get a sandwich
// with solid bands top/bottom and the pattern in the middle.
function _layers_for(style) =
    (style == "solid")
        ? [["solid", 0, container_height]]
        : (side_solid_base > 0 || side_solid_top > 0)
            ? [["solid", 0, side_solid_base],
               [style, side_solid_base, container_height - side_solid_top,
                [side_hex_cell, side_hex_wall, 2]],
               ["solid", container_height - side_solid_top, container_height]]
            : [[style, 0, container_height, [side_hex_cell, side_hex_wall, 2]]];

// Map back-view face names to the library's local-frame names. The container
// is mounted with its open top facing the user, so looking at the BACK of
// the container (mounting perspective) flips both axes:
//   user "back"  (pegboard side) = lib "front"
//   user "front" (user-facing)   = lib "back"
//   user "left"  (back-view)     = lib "right"
//   user "right" (back-view)     = lib "left"
faces_spec = [
    if (left_style  != "solid") ["right", _layers_for(left_style)],
    if (right_style != "solid") ["left",  _layers_for(right_style)],
    if (front_style != "solid") ["back",  _layers_for(front_style)],
    if (back_style  != "solid") ["front", _layers_for(back_style)],
];

module skadis_container_assembly() {
    union() {
        translate(container_origin)
            container(width = container_width,
                      depth = container_depth,
                      height = container_height,
                      wall = wall_thickness,
                      corner_r = corner_radius,
                      rim_thickness = top_rim_thickness,
                      faces = faces_spec);

        // Pegs are placed in world coords (their origin = slot centre at Y=0).
        // Each peg's standoff block bridges back in -Y to the container wall.
        translate([leading_peg_x, 0, peg_z_from_bottom])
            skadis_peg_grid(cols = _grid_cols, rows = _grid_rows,
                            anchor = _lib_anchor, vanchor = "bottom",
                            skip = _peg_skip,
                            standoff = standoff_distance,
                            standoff_top_ext = standoff_top_ext,
                            standoff_bot_ext = standoff_bot_ext,
                            retainer = peg_retainer);
    }
}

// USB pocket dimensions (mm), matched to a real USB-A / USB-C plug.
// Source: models/usb-a-to-c-storage-adapter — values empirically confirmed.
USB_A_W = 12.0;   USB_A_H = 4.5;   USB_A_R = 0.8;
USB_C_W = 8.25;   USB_C_H = 2.4;   /* USB_C_R = USB_C_H / 2 (racetrack) */

// `corner_r` accepts either a single number (uniform corners) or a 4-list
// [fl, fr, bl, br] for per-corner radii. This helper dispatches to the right
// container-lib param.
module make_insert(cells_spec, w, d, corner_r, finger_slot, cell_spacing, cell_offset, grab_tab) {
    use_list = is_list(corner_r);
    insert(container_width = container_width,
           container_depth = container_depth,
           container_wall  = wall_thickness,
           width            = w,
           depth            = d,
           height           = insert_height,
           clearance        = insert_clearance,
           cells            = cells_spec,
           base_thickness   = insert_base_thickness,
           cell_wall        = insert_cell_wall,
           cell_spacing     = cell_spacing,
           cell_offset      = cell_offset,
           corner_r         = use_list ? 0 : corner_r,
           corner_radii     = use_list ? corner_r : undef,
           finger_slot_side = finger_slot == true  ? "back"
                            : finger_slot == false ? "none"
                            :                        finger_slot,
           grab_tab_side    = grab_tab == true  ? "back"
                            : grab_tab == false ? "none"
                            : grab_tab == undef ? "none"
                            :                     grab_tab,
           grab_tab_w       = insert_grab_tab_w,
           grab_tab_h       = insert_grab_tab_h,
           grab_tab_t       = insert_grab_tab_t,
           grab_tab_frame   = insert_grab_tab_frame,
           grab_tab_r       = insert_grab_tab_r);
}

// USB insert. Solid block sized to the container interior (or to `w` × `d`
// if overridden); subtracts a blind pocket per cell of `insert_usb_layout`
// using real USB-A/USB-C geometry. Cells are USB-A footprint (the larger of
// the two) so USB-A and USB-C pockets share the same grid spacing.
//   corner_r       single OR [fl,fr,bl,br] (0 = sharp)
//   finger_slot    "none"/"back"/"front"/"both"  (or bool)
//   rotate_pockets true → pockets rotated 90° (long axis along Y)
//   pocket_spacing extra gap between pockets (undef = insert_cell_wall)
//   grid_offset    [dx, dy] to nudge the pocket grid off-centre
module make_usb_insert(layout, w, d, corner_r, finger_slot, rotate_pockets,
                       pocket_spacing, grid_offset, grab_tab) {
    rows  = len(layout);
    cols  = max([for (row = layout) len(row)]);

    gap     = pocket_spacing == undef ? insert_cell_wall : pocket_spacing;
    base_pw = USB_A_W + 2 * usb_pocket_clearance;     // pocket footprint X (unrotated)
    base_ph = USB_A_H + 2 * usb_pocket_clearance;     // pocket footprint Y (unrotated)
    cell_w  = (rotate_pockets ? base_ph : base_pw) + gap;
    cell_d  = (rotate_pockets ? base_pw : base_ph) + gap;

    full_w  = container_interior_w(container_width, wall_thickness) - 2 * insert_clearance;
    full_d  = container_interior_d(container_depth, wall_thickness) - 2 * insert_clearance;
    inner_w = w == undef ? full_w : w;
    inner_d = d == undef ? full_d : d;

    // Cell grid origin — centred + nudged.
    grid_w  = cols * cell_w - gap;
    grid_d  = rows * cell_d - gap;
    ox      = grid_offset[0];
    oy      = grid_offset[1];
    x0      = -grid_w / 2 + cell_w / 2 + ox;
    y0      =  grid_d / 2 - cell_d / 2 + oy;

    use_list = is_list(corner_r);
    radii    = use_list ? corner_r : [corner_r, corner_r, corner_r, corner_r];

    slot_side = finger_slot == true  ? "back"
              : finger_slot == false ? "none"
              :                        finger_slot;

    tab_side = grab_tab == true  ? "back"
             : grab_tab == false ? "none"
             : grab_tab == undef ? "none"
             :                     grab_tab;

    union() {
    difference() {
        linear_extrude(height = insert_height)
            rounded_rect_2d_per_corner(inner_w, inner_d, radii);

        for (r = [0 : rows - 1])
            for (c = [0 : len(layout[r]) - 1]) {
                kind = layout[r][c];
                if (kind == "a" || kind == "c") {
                    pw = (kind == "a" ? USB_A_W : USB_C_W) + 2 * usb_pocket_clearance;
                    ph = (kind == "a" ? USB_A_H : USB_C_H) + 2 * usb_pocket_clearance;
                    translate([x0 + c * cell_w,
                               y0 - r * cell_d,
                               insert_height - usb_pocket_depth])
                        linear_extrude(height = usb_pocket_depth + 1)
                            rotate([0, 0, rotate_pockets ? 90 : 0])
                                if (kind == "a")
                                    // Small rounded corners — offset trick is fine.
                                    offset(r = USB_A_R) offset(r = -USB_A_R)
                                        square([pw, ph], center = true);
                                else
                                    // Racetrack — hull of two end circles. Avoids
                                    // the offset-twice degeneracy at r = h/2.
                                    hull() {
                                        translate([-pw/2 + ph/2, 0]) circle(r = ph/2);
                                        translate([ pw/2 - ph/2, 0]) circle(r = ph/2);
                                    }
                }
            }

        // Finger slot — same corner-sliver guard as the container lib insert.
        if (slot_side != "none") {
            fs_w     = 30;
            fs_d     = 12;
            back_r   = max(radii[2], radii[3]);
            front_r  = max(radii[0], radii[1]);
            slot_wb  = (fs_w / 2 > inner_w / 2 - back_r  - 0.01) ? inner_w + 0.02 : fs_w;
            slot_wf  = (fs_w / 2 > inner_w / 2 - front_r - 0.01) ? inner_w + 0.02 : fs_w;
            slot_nyd = insert_base_thickness + insert_cell_wall + 1;
            slot_zmid = insert_height - fs_d / 2 + 0.005;
            if (slot_side == "back" || slot_side == "both")
                translate([0, inner_d / 2 + 0.01, slot_zmid])
                    rotate([90, 0, 0])
                        linear_extrude(height = slot_nyd)
                            square([slot_wb, fs_d + 0.01], center = true);
            if (slot_side == "front" || slot_side == "both")
                translate([0, -inner_d / 2 - 0.01, slot_zmid])
                    rotate([-90, 0, 0])
                        linear_extrude(height = slot_nyd)
                            square([slot_wf, fs_d + 0.01], center = true);
        }
    }

    // Grab tab — rounded hoop above the insert top when frame > 0.
    tab_w_eff   = insert_grab_tab_w == undef ? inner_w * 0.5 : insert_grab_tab_w;
    tab_inner_w = tab_w_eff          - 2 * insert_grab_tab_frame;
    tab_inner_h = insert_grab_tab_h  - 2 * insert_grab_tab_frame;
    tab_inner_r = max(0.1, insert_grab_tab_r - insert_grab_tab_frame);
    if (tab_side == "back" || tab_side == "both")
        translate([0, inner_d / 2 - insert_grab_tab_t / 2,
                   insert_height + insert_grab_tab_h / 2])
            rotate([90, 0, 0])
                linear_extrude(height = insert_grab_tab_t, center = true)
                    difference() {
                        rect_top_rounded_2d(tab_w_eff, insert_grab_tab_h, insert_grab_tab_r);
                        if (insert_grab_tab_frame > 0 && tab_inner_w > 0 && tab_inner_h > 0)
                            rect_top_rounded_2d(tab_inner_w, tab_inner_h, tab_inner_r);
                    }
    if (tab_side == "front" || tab_side == "both")
        translate([0, -inner_d / 2 + insert_grab_tab_t / 2,
                   insert_height + insert_grab_tab_h / 2])
            rotate([90, 0, 0])
                linear_extrude(height = insert_grab_tab_t, center = true)
                    difference() {
                        rect_top_rounded_2d(tab_w_eff, insert_grab_tab_h, insert_grab_tab_r);
                        if (insert_grab_tab_frame > 0 && tab_inner_w > 0 && tab_inner_h > 0)
                            rect_top_rounded_2d(tab_inner_w, tab_inner_h, tab_inner_r);
                    }
    }
}

// Lay out container + every insert along +X, separated so the slicer can
// split / arrange them onto separate plates.
// Effective insert width (mm) — overrides win, otherwise full container interior.
_full_insert_w = container_interior_w(container_width, wall_thickness)
                  - 2 * insert_clearance;
_pens_w = insert_pens_width          == undef ? _full_insert_w : insert_pens_width;
_usb_w  = insert_usb_width           == undef ? _full_insert_w : insert_usb_width;
_comp_w = insert_compartments_width  == undef ? _full_insert_w : insert_compartments_width;

module _do_insert_pens() {
    make_insert(insert_pens_cells,
                insert_pens_width, insert_pens_depth,
                insert_pens_corner_r,
                insert_pens_finger_slot,
                insert_pens_cell_spacing,
                insert_pens_cell_offset,
                insert_pens_grab_tab);
}
module _do_insert_compartments() {
    make_insert(insert_compartments_cells,
                insert_compartments_width, insert_compartments_depth,
                insert_compartments_corner_r,
                insert_compartments_finger_slot,
                insert_compartments_cell_spacing,
                insert_compartments_cell_offset,
                insert_compartments_grab_tab);
}
module _do_insert_usb() {
    make_usb_insert(insert_usb_layout,
                    insert_usb_width, insert_usb_depth,
                    insert_usb_corner_r,
                    insert_usb_finger_slot,
                    insert_usb_rotate_pockets,
                    insert_usb_pocket_spacing,
                    insert_usb_grid_offset,
                    insert_usb_grab_tab);
}

module render_all() {
    skadis_container_assembly();

    // Lay out inserts along +X past the container's right edge, each spaced
    // by its own half-width so they don't overlap regardless of size.
    sp     = all_layout_spacing;
    x_pens = container_width / 2 + sp + _pens_w / 2;
    x_usb  = x_pens + _pens_w / 2 + sp + _usb_w / 2;
    x_comp = x_usb  + _usb_w  / 2 + sp + _comp_w / 2;

    translate([x_pens, 0, 0]) _do_insert_pens();
    translate([x_usb,  0, 0]) _do_insert_usb();
    translate([x_comp, 0, 0]) _do_insert_compartments();
}

// ---- output ----
if (render_target == "container") {
    skadis_container_assembly();
} else if (render_target == "insert_pens") {
    _do_insert_pens();
} else if (render_target == "insert_usb") {
    _do_insert_usb();
} else if (render_target == "insert_compartments") {
    _do_insert_compartments();
} else if (render_target == "all") {
    render_all();
}

// Pegboard preview anchored on the leading peg so the slot grid lines up
// with the actual pegs. Preview-only, never enters the STL.
if (show_pegboard_preview && $preview && render_target == "container") {
    translate([0, 0.01, 0])
        skadis_pegboard_preview(width = max(container_width + 80, 200),
                                height = max(container_height + 60, 200),
                                anchor_x = leading_peg_x,
                                anchor_z = peg_z_from_bottom);
}

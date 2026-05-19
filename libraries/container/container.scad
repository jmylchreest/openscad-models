// container.scad — parametric box with per-face layered styles + cuts.
// Author: John Mylchreest <jmylchreest@gmail.com>. MIT licensed.
//
// Container frame: origin at back-left-bottom; +X width, +Y depth, +Z height.
// Faces named "back" (Y=0), "front" (Y=depth), "left" (X=0), "right" (X=W),
// "bottom" (Z=0), "top" (Z=H). Used as string keys in the `faces` / `cuts`
// args.
//
// `insert(container_width, container_depth, container_wall, ...)` returns a
// tray sized to drop into a container of those outer dimensions — share the
// same top-level vars and the two stay in sync without a spec object.

$fa = $preview ? $fa : 1;
$fs = $preview ? $fs : 0.2;

function container_interior_w(w, wall) = w - 2 * wall;
function container_interior_d(d, wall) = d - 2 * wall;
function container_interior_h(h, wall, open_top = true, closed_bottom = true) =
    h - (open_top ? 0 : wall) - (closed_bottom ? wall : 0);

module rounded_rect_2d(w, h, r = 0) {
    rr = min(r, min(w, h) / 2 - 0.001);
    if (rr <= 0) square([w, h], center = true);
    else offset(r = rr) offset(r = -rr) square([w, h], center = true);
}

// Rect centred at origin with square bottom corners and rounded top corners.
// Used for the grab-tab hoop so the bottom edge sits flat on the insert wall.
module rect_top_rounded_2d(w, h, r = 0) {
    rr = min(r, min(w, h) / 2 - 0.001);
    if (rr <= 0) square([w, h], center = true);
    else hull() {
        translate([-w/2, -h/2]) square([w, 0.001]);
        translate([-w/2 + rr,  h/2 - rr]) circle(r = rr);
        translate([ w/2 - rr,  h/2 - rr]) circle(r = rr);
    }
}

// corner_radii = [front-left, front-right, back-left, back-right]. A 0 leaves
// that corner sharp — useful when two inserts butt against each other and
// the shared edges need to be flat.
module rounded_rect_2d_per_corner(w, d, corner_radii = [2, 2, 2, 2]) {
    eps  = 0.001;
    r_fl = max(corner_radii[0], eps);
    r_fr = max(corner_radii[1], eps);
    r_bl = max(corner_radii[2], eps);
    r_br = max(corner_radii[3], eps);
    // Hull four corner discs (or tiny squares for sharp corners), each
    // inset by its radius so the hull reproduces the rectangle.
    hull() {
        translate([-w/2 + r_fl, -d/2 + r_fl])
            if (corner_radii[0] > 0) circle(r = r_fl); else square(2 * eps, center = true);
        translate([ w/2 - r_fr, -d/2 + r_fr])
            if (corner_radii[1] > 0) circle(r = r_fr); else square(2 * eps, center = true);
        translate([-w/2 + r_bl,  d/2 - r_bl])
            if (corner_radii[2] > 0) circle(r = r_bl); else square(2 * eps, center = true);
        translate([ w/2 - r_br,  d/2 - r_br])
            if (corner_radii[3] > 0) circle(r = r_br); else square(2 * eps, center = true);
    }
}

// Honeycomb grid clipped to a [w × h] rectangle (centred at origin).
//   cell_size = flat-to-flat diameter of each hex hole
//   wall_t    = thickness of material between adjacent hexes (approximate)
//   margin    = extra solid margin around the perforated region
module hex_grid_2d(w, h, cell_size = 8, wall_t = 1.2, margin = 0) {
    if (cell_size > 0 && w - 2 * margin > 0 && h - 2 * margin > 0) {
        pitch_x = cell_size + wall_t;
        pitch_y = pitch_x * sqrt(3) / 2;
        n_cols  = ceil(w / pitch_x / 2) + 1;
        n_rows  = ceil(h / pitch_y / 2) + 1;

        intersection() {
            square([w - 2 * margin, h - 2 * margin], center = true);
            for (row = [-n_rows : n_rows]) {
                offset_x = ((row % 2) + 2) % 2 == 0 ? 0 : pitch_x / 2;
                for (col = [-n_cols : n_cols])
                    translate([col * pitch_x + offset_x, row * pitch_y])
                        rotate([0, 0, 30])
                            circle(d = cell_size, $fn = 6);
            }
        }
    }
}

// Rectangular slot (centred at origin) — for cuts like a mug-handle slot.
module slot_2d(slot_w, slot_h, corner_r = 2) {
    rounded_rect_2d(slot_w, slot_h, corner_r);
}

// Grid of round holes, clipped to [w × h] (centred at origin).
module hole_grid_2d(w, h, hole_d = 5, pitch = 8) {
    if (hole_d > 0 && pitch > 0 && w > 0 && h > 0) {
        n_cols = floor((w - hole_d) / pitch) + 1;
        n_rows = floor((h - hole_d) / pitch) + 1;
        x0 = -(n_cols - 1) * pitch / 2;
        y0 = -(n_rows - 1) * pitch / 2;
        for (col = [0 : n_cols - 1])
            for (row = [0 : n_rows - 1])
                translate([x0 + col * pitch, y0 + row * pitch])
                    circle(d = hole_d);
    }
}

// Pick the right 2D pattern for a face band, centred at origin.
module pattern_2d(style, w, h, params = []) {
    if (style == "hex") {
        cs   = (len(params) > 0 && params[0] != undef) ? params[0] : 8;
        wt   = (len(params) > 1 && params[1] != undef) ? params[1] : 1.2;
        marg = (len(params) > 2 && params[2] != undef) ? params[2] : 1.0;
        hex_grid_2d(w, h, cs, wt, marg);
    } else if (style == "slot") {
        sw   = (len(params) > 0 && params[0] != undef) ? params[0] : min(w, h) * 0.4;
        sh   = (len(params) > 1 && params[1] != undef) ? params[1] : h * 0.8;
        cr   = (len(params) > 2 && params[2] != undef) ? params[2] : 2;
        slot_2d(sw, sh, cr);
    } else if (style == "grid") {
        hd   = (len(params) > 0 && params[0] != undef) ? params[0] : 5;
        ptc  = (len(params) > 1 && params[1] != undef) ? params[1] : 8;
        hole_grid_2d(w, h, hd, ptc);
    }
    // style == "solid" → no cutout (no-op)
}

// Extrude the child 2D pattern through the wall on the named face, centred
// on the band's mid-Z. Patterns are authored in the XY plane and rotated
// into place per face.
module _place_on_face(face, w, d, h, wall, z_from, z_to) {
    band_z_mid = (z_from + z_to) / 2;

    // For back/front: rotate([-90,0,0]) maps the 2D extrude direction (+Z)
    // onto +Y so the pattern sinks INTO the wall. The earlier +90 rotation
    // put it outside, where the difference() did nothing.
    if (face == "back") {
        translate([w / 2, -0.01, band_z_mid])
            rotate([-90, 0, 0])
                linear_extrude(height = wall + 0.02, center = false)
                    children();
    } else if (face == "front") {
        translate([w / 2, d + 0.01, band_z_mid])
            rotate([-90, 0, 0])
                mirror([0, 0, 1])
                    linear_extrude(height = wall + 0.02, center = false)
                        children();
    } else if (face == "left") {
        // Pattern lies in the YZ plane; centred at (*, d/2, band_z_mid).
        translate([-0.01, d / 2, band_z_mid])
            rotate([0, 90, 0])
                rotate([0, 0, 90])
                    linear_extrude(height = wall + 0.02, center = false)
                        children();
    } else if (face == "right") {
        translate([w + 0.01, d / 2, band_z_mid])
            rotate([0, 90, 0])
                rotate([0, 0, 90])
                    mirror([0, 0, 1])
                        linear_extrude(height = wall + 0.02, center = false)
                            children();
    } else if (face == "bottom") {
        // Pattern lies in the XY plane; centred at (w/2, d/2, *).
        translate([w / 2, d / 2, -0.01])
            linear_extrude(height = wall + 0.02, center = false)
                children();
    } else if (face == "top") {
        translate([w / 2, d / 2, h - wall - 0.01])
            linear_extrude(height = wall + 0.02, center = false)
                children();
    }
}

// Place a styled band on a face. `params` interpretation depends on `style`.
module face_band(face, w, d, h, wall, style, z_from, z_to, params) {
    band_w = (face == "back" || face == "front") ? w
           : (face == "left" || face == "right") ? d
           : w;
    band_h = (face == "bottom" || face == "top") ? d : (z_to - z_from);

    _place_on_face(face, w, d, h, wall, z_from, z_to)
        pattern_2d(style, band_w, band_h, params);
}

// Subtractive op on a face. cut_type = "slot" | "hex" | "grid".
//   slot         params = [cx, width, z_from, z_to, corner_r]
//   hex / grid   params = [z_from, z_to, style_params]
module face_cut(face, w, d, h, wall, cut_type, params) {
    if (cut_type == "slot") {
        cx = (len(params) > 0 && params[0] != undef) ? params[0] : 0;
        sw = (len(params) > 1 && params[1] != undef) ? params[1] : 30;
        zf = (len(params) > 2 && params[2] != undef) ? params[2] : h * 0.1;
        zt = (len(params) > 3 && params[3] != undef) ? params[3] : h - h * 0.1;
        cr = (len(params) > 4 && params[4] != undef) ? params[4] : 2;

        _place_on_face(face, w, d, h, wall, zf, zt)
            translate([cx, 0]) slot_2d(sw, zt - zf, cr);
    } else {
        zf = (len(params) > 0 && params[0] != undef) ? params[0] : 0;
        zt = (len(params) > 1 && params[1] != undef) ? params[1] : h;
        style_params = (len(params) > 2 && params[2] != undef) ? params[2] : [];
        face_band(face, w, d, h, wall, cut_type, zf, zt, style_params);
    }
}

module rounded_box(x0, x1, y0, y1, z0, z1, r) {
    dx = x1 - x0;
    dy = y1 - y0;
    rr = min(r, min(dx, dy) / 2 - 0.001);
    translate([x0, y0, z0])
        linear_extrude(height = z1 - z0)
            offset(r = max(rr, 0)) offset(r = -max(rr, 0))
                square([dx, dy], center = false);
}

module container(
    width,
    depth,
    height,
    wall          = 2.0,
    corner_r      = 4.0,
    open_top      = true,
    closed_bottom = true,
    rim_thickness = 0,
    faces         = [],
    cuts          = []
) {
    wall_b = closed_bottom ? wall : 0;
    inner_w = width  - 2 * wall;
    inner_d = depth  - 2 * wall;
    inner_h = height - wall_b - (open_top ? 0 : wall);
    inner_r = max(0.1, corner_r - wall);

    difference() {
        union() {
            // Solid outer shell with rounded vertical edges.
            rounded_box(0, width, 0, depth, 0, height, corner_r);

            // Optional thicker rim around the open top.
            if (open_top && rim_thickness > wall) {
                rim_h = rim_thickness;
                difference() {
                    translate([0, 0, height - rim_h])
                        rounded_box(0, width, 0, depth, 0, rim_h, corner_r);
                    translate([wall, wall, height - rim_h - 0.1])
                        rounded_box(0, inner_w, 0, inner_d, 0, rim_h + 0.2, inner_r);
                }
            }
        }

        // Interior cavity.
        translate([wall, wall, wall_b])
            rounded_box(0, inner_w, 0, inner_d,
                        0, inner_h + (open_top ? 1 : 0),
                        inner_r);

        // Per-face layered styles.
        for (face_cfg = faces) {
            face_name = face_cfg[0];
            layers    = face_cfg[1];
            for (layer = layers) {
                style       = layer[0];
                z_from      = (len(layer) > 1 && layer[1] != undef) ? layer[1] : 0;
                z_to        = (len(layer) > 2 && layer[2] != undef) ? layer[2] : height;
                lp          = (len(layer) > 3 && layer[3] != undef) ? layer[3] : [];
                if (style != "solid")
                    face_band(face_name, width, depth, height, wall,
                              style, z_from, z_to, lp);
            }
        }

        // Cuts.
        for (cut = cuts) {
            face_name = cut[0];
            cut_type  = cut[1];
            cut_params = (len(cut) > 2 && cut[2] != undef) ? cut[2] : [];
            face_cut(face_name, width, depth, height, wall, cut_type, cut_params);
        }
    }
}

// Insert sized to drop into a container.
//
//   cells = [cols, rows, type, p1, p2, p3]
//     type = "round" → p1 = diameter
//     type = "rect"  → p1 = cell_x, p2 = cell_y, p3 = corner_r
//
// Defaults to filling the container interior minus `clearance`. Override
// `width`/`depth` for multiple inserts in one container; `pos_x`/`pos_y`
// offsets from the interior centre.
//
// `corner_radii = [fl, fr, bl, br]` overrides `corner_r` per-corner; use 0
// to keep a corner sharp where two inserts share an edge.
//
// `cell_depth` < (height - base_thickness) makes shallow pockets.
//
// `finger_slot_side` = "none" | "back" | "front" | "both"; the legacy
// `finger_slot = true` is shorthand for "back".
//
// `grab_tab_side` = "none" | "back" | "front" | "both" — handle protruding
// above the insert top on the named edge. `_w` X width, `_h` extra Z above
// the insert top, `_t` Y thickness, `_frame` = frame wall around an inner
// void (so the tab becomes a hoop / closed loop you can put a finger
// through). `_frame = 0` keeps it as a solid fin.
module insert(
    container_width,
    container_depth,
    container_wall    = 2.0,
    width             = undef,
    depth             = undef,
    height            = 30,
    pos_x             = 0,
    pos_y             = 0,
    clearance         = 0.4,
    cells             = [4, 2, "round", 12],
    base_thickness    = 2.0,
    cell_depth        = undef,
    cell_wall         = 1.2,
    cell_spacing      = undef,            // pitch gap between cells (defaults to cell_wall)
    cell_offset       = [0, 0],           // [dx, dy] — shift cell grid from insert centre
    corner_r          = 2,
    corner_radii      = undef,
    finger_slot       = false,
    finger_slot_side  = undef,
    finger_slot_w     = 30,
    finger_slot_d     = 12,
    grab_tab_side     = "none",
    grab_tab_w        = undef,       // undef → 50% of insert width
    grab_tab_h        = 8,
    grab_tab_t        = 3,
    grab_tab_frame    = 2,
    grab_tab_r        = 2
) {
    inner_w = container_interior_w(container_width, container_wall) - 2 * clearance;
    inner_d = container_interior_d(container_depth, container_wall) - 2 * clearance;
    ins_w   = width  == undef ? inner_w : width;
    ins_d   = depth  == undef ? inner_d : depth;
    radii   = corner_radii == undef ? [corner_r, corner_r, corner_r, corner_r] : corner_radii;

    // cell_z_low = Z of the cell pocket floor. Defaults to base_thickness
    // (open pocket all the way to the top).
    depth_eff  = cell_depth == undef ? height - base_thickness : cell_depth;
    cell_z_low = height - depth_eff;

    slot_side = finger_slot_side != undef ? finger_slot_side
              : finger_slot                ? "back"
              :                              "none";

    cols    = cells[0];
    rows    = cells[1];
    type    = cells[2];
    cell_w  = (type == "round" || type == "rect") ? cells[3] : 10;
    cell_h  =  type == "round" ? cells[3]
            :  type == "rect"  ? cells[4]
            :                    10;
    cell_cr =  type == "rect" && len(cells) > 5 && cells[5] != undef ? cells[5]
            :  type == "rect"                                        ? 1.2
            :                                                          0;
    gap     = cell_spacing == undef ? cell_wall : cell_spacing;
    pitch_x = cell_w + gap;
    pitch_y = cell_h + gap;
    grid_w  = cols * pitch_x - gap;
    grid_d  = rows * pitch_y - gap;
    ox      = cell_offset[0];
    oy      = cell_offset[1];

    translate([pos_x, pos_y, 0])
    union() {
    difference() {
        linear_extrude(height = height)
            rounded_rect_2d_per_corner(ins_w, ins_d, radii);

        for (col = [0 : cols - 1])
            for (row = [0 : rows - 1])
                translate([-grid_w / 2 + pitch_x / 2 + col * pitch_x + ox,
                           -grid_d / 2 + pitch_y / 2 + row * pitch_y + oy,
                           cell_z_low])
                    linear_extrude(height = depth_eff + 1)
                        if (type == "round") circle(d = cell_w);
                        else rounded_rect_2d(cell_w, cell_h, cell_cr);

        // Finger slot: notch on the back-top (or front-top) edge.
        // `finger_slot_d` = Z depth of the notch from the top of the insert.
        // If the slot's side edges would land inside the rounded corner zone
        // they leave a thin curved sliver hanging from the top — detect that
        // and widen the slot to clip the corner curl too.
        slot_nyd  = base_thickness + cell_wall + 1;       // Y depth into wall
        slot_zmid = height - finger_slot_d / 2 + 0.005;   // centre Z
        back_r    = max(radii[2], radii[3]);
        front_r   = max(radii[0], radii[1]);
        slot_w_back  = (finger_slot_w / 2 > ins_w / 2 - back_r  - 0.01) ? ins_w + 0.02 : finger_slot_w;
        slot_w_front = (finger_slot_w / 2 > ins_w / 2 - front_r - 0.01) ? ins_w + 0.02 : finger_slot_w;
        if (slot_side == "back" || slot_side == "both")
            translate([0, ins_d / 2 + 0.01, slot_zmid])
                rotate([90, 0, 0])
                    linear_extrude(height = slot_nyd)
                        square([slot_w_back, finger_slot_d + 0.01],
                               center = true);
        if (slot_side == "front" || slot_side == "both")
            translate([0, -ins_d / 2 - 0.01, slot_zmid])
                rotate([-90, 0, 0])
                    linear_extrude(height = slot_nyd)
                        square([slot_w_front, finger_slot_d + 0.01],
                               center = true);
    }

    // Grab tab — handle protruding above the insert top. With
    // `grab_tab_frame > 0` it's a closed hoop (rectangular ring with rounded
    // corners you can put a finger through, in the Y direction). With
    // `grab_tab_frame == 0` it's a solid fin.
    tab_w_eff   = grab_tab_w == undef ? ins_w * 0.5 : grab_tab_w;
    tab_inner_w = tab_w_eff   - 2 * grab_tab_frame;
    tab_inner_h = grab_tab_h  - 2 * grab_tab_frame;
    tab_inner_r = max(0.1, grab_tab_r - grab_tab_frame);
    if (grab_tab_side == "back" || grab_tab_side == "both")
        translate([0, ins_d / 2 - grab_tab_t / 2, height + grab_tab_h / 2])
            rotate([90, 0, 0])
                linear_extrude(height = grab_tab_t, center = true)
                    difference() {
                        rect_top_rounded_2d(tab_w_eff, grab_tab_h, grab_tab_r);
                        if (grab_tab_frame > 0 && tab_inner_w > 0 && tab_inner_h > 0)
                            rect_top_rounded_2d(tab_inner_w, tab_inner_h, tab_inner_r);
                    }
    if (grab_tab_side == "front" || grab_tab_side == "both")
        translate([0, -ins_d / 2 + grab_tab_t / 2, height + grab_tab_h / 2])
            rotate([90, 0, 0])
                linear_extrude(height = grab_tab_t, center = true)
                    difference() {
                        rect_top_rounded_2d(tab_w_eff, grab_tab_h, grab_tab_r);
                        if (grab_tab_frame > 0 && tab_inner_w > 0 && tab_inner_h > 0)
                            rect_top_rounded_2d(tab_inner_w, tab_inner_h, tab_inner_r);
                    }
    }
}

// Demo — only when this file is opened directly.
if ($preview) {
    color("SteelBlue") container(
        width = 90, depth = 75, height = 115,
        wall = 2, corner_r = 4,
        rim_thickness = 2.4,
        faces = [
            ["left",  [["solid", 0, 20],
                       ["hex",   20, 95, [10, 1.4, 2]],
                       ["solid", 95, 115]]],
            ["right", [["solid", 0, 20],
                       ["hex",   20, 95, [10, 1.4, 2]],
                       ["solid", 95, 115]]],
        ],
        cuts = []
    );

    // Pen insert rendered well clear of the container so both are visible.
    // (Container body occupies X=0..90, Y=0..75; insert is centred about its
    // own origin so we translate it past the container's right edge.)
    color("LightCoral") translate([160, 37.5, 0])
        insert(container_width = 90, container_depth = 75, container_wall = 2,
               height = 30, cells = [4, 2, "round", 12],
               finger_slot = true);
}

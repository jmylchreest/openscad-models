// USB-A hole → USB-C drive storage adapter
// Solid block sized like a USB-A plug with a USB-C shaped pocket inside.
// Friction-fit into a USB-A storage slot to hold a USB-C drive.

/* [USB-A outer shell] */
usb_a_width        = 12.0;   // nominal USB-A long dim
usb_a_height       = 4.5;    // nominal USB-A short dim
block_length       = 12.7;   // total block length
outer_clearance    = 0.25;   // subtracted from outer dims for fit
outer_corner_r     = 0.8;

/* [USB-C inner pocket] */
usb_c_width        = 8.25;    // nominal USB-C long dim
usb_c_height       = 2.4;    // nominal USB-C short dim
pocket_clearance   = 0.35;   // added to pocket dims for fit

/* [Pocket depth] */
through_hole       = true;   // false = blind pocket
blind_pocket_depth = 7.8;    // used when through_hole = false
blind_back_wall    = 1.2;

/* [Quality] */
$fn                = 96;

/* [Layout] */
print_orientation  = true;   // true = stand upright on build plate

// ---- derived ----
outer_w         = usb_a_width  - outer_clearance;
outer_h         = usb_a_height - outer_clearance;
pocket_w        = usb_c_width  + pocket_clearance;
pocket_h        = usb_c_height + pocket_clearance;
pocket_corner_r = pocket_h / 2;  // racetrack matches USB-C shape

module rounded_rect(w, h, r) {
    r_safe = min(r, min(w, h) / 2 - 0.001);
    offset(r = r_safe) offset(r = -r_safe) square([w, h], center = true);
}

module adapter() {
    difference() {
        linear_extrude(height = block_length)
            rounded_rect(outer_w, outer_h, outer_corner_r);

        pocket_bottom_z = through_hole ? -0.1 : blind_back_wall;
        pocket_top_z    = block_length + 0.1;
        translate([0, 0, pocket_bottom_z])
            linear_extrude(height = pocket_top_z - pocket_bottom_z)
                rounded_rect(pocket_w, pocket_h, pocket_corner_r);
    }
}

if (print_orientation) adapter();
else rotate([90, 0, 0]) adapter();

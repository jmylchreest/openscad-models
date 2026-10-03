// PETG washing-line prop replacement. All dimensions in mm. No libraries needed.
// Flat mode prints sideways on one common face; normal mode needs plug supports.
// Solid geometry is not a load rating: validate the print on the actual pole.

/* [Output] */
part = "complete"; // [complete,fit_test]
print_orientation = true;
// Common bed face, three ribbed faces, and a flat-bottomed insertion tip.
flat_print_face = false;

/* [Fit test plier grip] */
// Solid block where the hoop would be; rises above shoulder in print orientation.
grip_width = 10;
grip_length = 15;
// EXTRA height above the shoulder's upper printed face.
grip_extra_height = 2;

/* [Square pole and plug] */
// Internal width across flats (not diagonal or outside width).
pole_inside = 17;
// TOTAL width reduction: 0.20 gives a 16.80 mm core in a 17 mm bore.
fit_clearance = 0.20;
plug_depth = 45;
plug_corner_radius = 1.0;
tip_length = 3;
// Reduction on EACH side of the insertion tip.
tip_chamfer = 0.8;

/* [Friction ribs] */
// Crush ribs on three faces in flat mode, four otherwise; zero disables them.
rib_count = 5;
rib_height = 0.20;
rib_width = 1.8;
// Fraction of each flat covered, leaving corners clear.
rib_face_fraction = 0.65;
rib_end_margin = 5;

/* [Shoulder and reinforcement] */
// Must extend beyond the OUTSIDE of the metal pole.
shoulder_width = 25;
shoulder_height = 5;
head_thickness = 20;
neck_width = 22;

/* [Line hoop] */
// Clear opening dimensions before cutting the side entry slot.
opening_width = 28;
opening_height = 25;
opening_corner_radius = 4;
hoop_wall = 8;
// Solid material between shoulder top and bottom of line opening.
seat_height = 12;
// Vertical clearance of horizontal slot in upper right arm; 0 closes hoop.
entry_gap = 5;
// Entry centre as fraction of opening height above its bottom.
entry_position = 0.72;

/* [Quality] */
$fn = 64;

/* [Hidden] */
eps = 0.02;
core = pole_inside - fit_clearance;
rib_span = core + 2 * rib_height;
opening_bottom = shoulder_height + seat_height;
entry_y = opening_bottom + opening_height * entry_position;
print_thickness = max(head_thickness, rib_count > 0 ? rib_span : core);
head_bottom = flat_print_face ? -core/2 : -head_thickness/2;
bed_lift = flat_print_face ? core/2 : print_thickness/2;

assert(part == "complete" || part == "fit_test", "Unknown part");
assert(grip_width > 0 && grip_width <= shoulder_width && grip_length > 0 && grip_extra_height >= 0,
       "Invalid fit-test grip dimensions");
assert(pole_inside > 0 && core > 0 && fit_clearance >= 0, "Invalid bore/clearance");
assert(plug_corner_radius > 0 && plug_corner_radius < core/2, "Invalid corner radius");
assert(tip_chamfer > 0 && tip_chamfer < core/2 && tip_length > 0 && tip_length < plug_depth,
       "Invalid tip dimensions");
assert(rib_count >= 0 && rib_count == floor(rib_count) && rib_height >= 0 && rib_width > 0,
       "Invalid ribs");
assert(rib_face_fraction > 0 && rib_face_fraction <= (core-2*plug_corner_radius)/core,
       "Ribs must stay on the flat faces");
assert(!flat_print_face || core*rib_face_fraction > 2*rib_height,
       "Ribs too tall for bevelled ends");
assert(rib_end_margin >= tip_length && plug_depth > 2*rib_end_margin+rib_width,
       "Plug too short for rib margins");
assert(rib_count <= 1 || (plug_depth-2*rib_end_margin-rib_width)/(rib_count-1) > rib_width,
       "Ribs overlap: reduce count/width or increase plug depth");
assert(shoulder_width > rib_span && shoulder_height > 0 && head_thickness > rib_span,
       "Shoulder must project beyond plug/ribs on all faces");
assert(neck_width >= core && neck_width <= shoulder_width, "Invalid neck width");
assert(hoop_wall > 0 && seat_height >= hoop_wall && head_thickness > 0,
       "Invalid wall/seat thickness");
assert(opening_corner_radius > 0 && opening_width > 2*opening_corner_radius &&
       opening_height > 2*opening_corner_radius, "Invalid hoop opening");
assert(entry_gap >= 0 && entry_y-entry_gap/2 > opening_bottom+opening_corner_radius &&
       entry_y+entry_gap/2 < opening_bottom+opening_height-opening_corner_radius,
       "Gap must remain within upper side of opening; reduce gap or move it");

echo(core_width=core, rib_peak_width=rib_count > 0 ? rib_span : core,
     rib_peak_thickness=core+(rib_count > 0 ? (flat_print_face ? 1 : 2)*rib_height : 0),
     rib_interference_per_side=rib_count > 0 ? rib_height-fit_clearance/2 : -fit_clearance/2);

module rounded_square(size, radius) {
    offset(r=radius) square([size-2*radius, size-2*radius], center=true);
}

// Coordinates: X across hoop, Y along pole, Z through hoop.
module plug_section(y, size, radius) {
    translate([0,y,0]) rotate([90,0,0])
        linear_extrude(height=eps)
            if (flat_print_face)
                // Bottom remains at the bed even at the narrower tip.
                // Lower corners are 45-degree bevels, upper corners rounded.
                hull() {
                    polygon([[-size/2+radius,-core/2], [size/2-radius,-core/2],
                             [size/2,-core/2+radius], [-size/2,-core/2+radius]]);
                    for (x=[-size/2+radius,size/2-radius])
                        translate([x,size/2-radius]) circle(r=radius);
                }
            else rounded_square(size,radius);
}

module plug() {
    // Full-depth solid core with a tapered insertion tip.
    hull() {
        plug_section(0,core,plug_corner_radius);
        plug_section(-plug_depth+tip_length,core,plug_corner_radius);
    }
    hull() {
        plug_section(-plug_depth+tip_length+eps,core,plug_corner_radius);
        plug_section(-plug_depth+eps,core-2*tip_chamfer,
                     min(plug_corner_radius,(core-2*tip_chamfer)/4));
    }
    if (rib_count > 0 && rib_height > 0)
        for (i=[0:rib_count-1]) {
            pos = rib_count == 1 ? plug_depth/2 :
                  rib_end_margin+rib_width/2+i*(plug_depth-2*rib_end_margin-rib_width)/(rib_count-1);
            for (angle=flat_print_face ? [0,90,270] : [0,90,180,270]) rotate([0,angle,0])
                translate([0,-pos,0])
                    if (flat_print_face)
                        // Bevel both ends 45 degrees so side ribs grow from the core.
                        hull() {
                            translate([-core*rib_face_fraction/2,-rib_width/2,core/2-eps])
                                cube([core*rib_face_fraction,rib_width,eps]);
                            translate([-(core*rib_face_fraction-2*rib_height)/2,-eps/2,core/2+rib_height-eps])
                                cube([core*rib_face_fraction-2*rib_height,eps,eps]);
                        }
                    else
                    // Triangular crush bead, embedded slightly in the core.
                    rotate([0,90,0]) linear_extrude(height=core*rib_face_fraction,center=true)
                        polygon([[-core/2+eps,-rib_width/2],
                                 [-core/2-rib_height,0],
                                 [-core/2+eps,rib_width/2]]);
        }
}

module opening() {
    r=opening_corner_radius;
    hull() {
        translate([-opening_width/2+r,opening_bottom+r]) circle(r=r);
        translate([ opening_width/2-r,opening_bottom+r]) circle(r=r);
        translate([0,opening_bottom+opening_height-r]) circle(r=r);
    }
}

module shoulder() {
    translate([-shoulder_width/2,0,head_bottom])
        cube([shoulder_width,shoulder_height,head_thickness]);
}

module head() {
    translate([0,0,head_bottom]) linear_extrude(height=head_thickness)
        difference() {
            union() {
                offset(r=hoop_wall) opening();
                // Broad tapered connection overlapping both shoulder and lower hoop.
                hull() {
                    translate([-neck_width/2,0]) square([neck_width,shoulder_height]);
                    translate([-(opening_width+hoop_wall)/2,opening_bottom-hoop_wall])
                        square([opening_width+hoop_wall,hoop_wall]);
                }
            }
            opening();
            if (entry_gap > 0)
                translate([0,entry_y-entry_gap/2])
                    square([opening_width+2*hoop_wall,entry_gap]);
        }
}

module model() {
    union() {
        plug();
        shoulder();
        if (part == "complete") head();
        else
            // Full-thickness base overlaps shoulder; flat bed-facing underside.
            translate([-grip_width/2,shoulder_height-eps,head_bottom])
                cube([grip_width,grip_length+eps,head_thickness+grip_extra_height]);
    }
}

if (print_orientation)
    translate([0,0,bed_lift]) model();
else
    rotate([90,0,0]) model();

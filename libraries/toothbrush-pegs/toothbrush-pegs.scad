// toothbrush-pegs — peg shapes that mate with the recess on the base
// of common electric-toothbrush handles. Pull yours apart, measure the
// recess Ø at each end + the back-arc-to-front-arc length, set a
// tolerance, and adjust if the fit is too loose or too tight.
//
// Conventions:
//   * Peg origin = centre of the long axis, on the BASE face (z = 0).
//   * Long axis along world Y; the WIDER "back" end is at +Y and the
//     NARROWER "front" end at −Y. Brushes are not symmetric, so the
//     peg isn't either — the asymmetric cross-section rotationally
//     keys the brush to a fixed orientation.
//   * Peg grows in +Z; `height` is the peg's vertical extent.
//
// Add modules here per brush family (Sonicare, Quip, etc.) as you
// measure them. Keep the parameter names symmetric across families
// so callers can swap the module name and pass the same arguments.
//
// Author: John Mylchreest <jmylchreest@gmail.com>. MIT licensed.

// Oral-B (Type 3766-class) handle base peg dimensions. The recess is a
// rounded rectangle that's wider at the charging-side end than at the
// bristle-side end, with small radius corners — NOT the smooth teardrop
// a `hull(2 circles)` would give. Geometry is FIXED — only `tolerance`
// is exposed below — because the brush's recess never changes between
// handles. Edit these constants if your handle disagrees; the test
// piece picks up the new sizes automatically.
ORALB_PEG_W_BACK    = 9.0;   // width at the back (charging-side) end
ORALB_PEG_W_FRONT   = 8.4;   // width at the front (bristle-side) end
ORALB_PEG_LENGTH    = 9.7;   // back end → front end along the long axis
ORALB_PEG_CORNER_R  = 3.0;   // rounding radius applied at every corner
ORALB_PEG_HEIGHT    = 7.0;   // vertical peg height (≤ ~12.5 mm recess depth)
ORALB_PEG_DEPTH_MAX = 12.5;  // brush's recess depth — keep ORALB_PEG_HEIGHT under this

// Oral-B replacement-head peg dimensions. The head's hollow shaft slides
// down over a thin vertical post; the post fills the shaft to keep the
// head upright.
ORALB_HEAD_PEG_D = 4.0;      // post diameter (head shaft ≈ 5 mm Ø)
ORALB_HEAD_PEG_H = 25;       // post height — long enough to fill the shaft

// Trapezoid-with-rounded-corners — hull of four corner circles, one at
// each corner of an isoceles trapezoid (w_back wide at +Y, w_front wide
// at −Y, total length along Y). Corner radii are equal at all four
// corners; the side walls come out as the straight tangent lines
// between the back and front circles on each side (≈ 5–6° in from
// vertical for the default Oral-B numbers). Centered at the origin.
module asym_rounded_rect_2d(w_back, w_front, length, r) {
    rr = max(0.1, min(r, min(w_back, w_front, length) / 2 - 0.001));
    hull() {
        translate([-w_back  / 2 + rr,  length / 2 - rr]) circle(r = rr);
        translate([+w_back  / 2 - rr,  length / 2 - rr]) circle(r = rr);
        translate([-w_front / 2 + rr, -length / 2 + rr]) circle(r = rr);
        translate([+w_front / 2 - rr, -length / 2 + rr]) circle(r = rr);
    }
}

// Oral-B brush body peg. The base cross-section comes from the
// constants above and the tolerance; on top of that:
//   * `taper` is the TOTAL XY shrinkage from the peg's base to the top
//     of its main (tapered) body — subtracted from each linear
//     dimension, half from the corner radius. 2 mm by default so the
//     top sits comfortably narrower than the recess opening.
//   * `chamfer` adds an extra bevel at the very top in `chamfer_h` of
//     vertical height, removing `chamfer` per side from the linear
//     dimensions. A 0.5 × 0.5 mm default gives a 45° lead-in for
//     easier insertion. Set `chamfer = 0` or `chamfer_h = 0` to skip.
// Long axis comes out along world Y with the wider "back" end at +Y.
module oralb_body_peg(
    tolerance = 0.3,
    taper     = 2.0,
    chamfer   = 0.5,
    chamfer_h = 0.5
) {
    wb = max(0.1, ORALB_PEG_W_BACK   - tolerance);
    wf = max(0.1, ORALB_PEG_W_FRONT  - tolerance);
    l  = max(0.1, ORALB_PEG_LENGTH   - tolerance);
    rr = max(0.1, ORALB_PEG_CORNER_R - tolerance / 2);
    h  = ORALB_PEG_HEIGHT;

    use_chamfer = chamfer > 0 && chamfer_h > 0;
    main_h = use_chamfer ? h - chamfer_h : h;

    // Top of the tapered main body (also bottom of the chamfer when
    // the chamfer is in use).
    wb_t = max(0.1, wb - taper);
    wf_t = max(0.1, wf - taper);
    l_t  = max(0.1, l  - taper);
    rr_t = max(0.1, rr - taper / 2);

    union() {
        // Tapered main body — hull from the full base up to the taper-top.
        hull() {
            linear_extrude(height = 0.01)
                asym_rounded_rect_2d(wb, wf, l, rr);
            translate([0, 0, main_h - 0.01])
                linear_extrude(height = 0.01)
                    asym_rounded_rect_2d(wb_t, wf_t, l_t, rr_t);
        }
        // Optional top chamfer — hull from taper-top up to a smaller
        // cross-section, giving a quick bevel at the very top edge.
        if (use_chamfer)
            translate([0, 0, main_h])
                hull() {
                    linear_extrude(height = 0.01)
                        asym_rounded_rect_2d(wb_t, wf_t, l_t, rr_t);
                    translate([0, 0, chamfer_h - 0.01])
                        linear_extrude(height = 0.01)
                            asym_rounded_rect_2d(
                                max(0.1, wb_t - 2 * chamfer),
                                max(0.1, wf_t - 2 * chamfer),
                                max(0.1, l_t  - 2 * chamfer),
                                max(0.1, rr_t - chamfer)
                            );
                }
    }
}

// Oral-B replacement-head peg. A thin vertical post that fills the
// head's hollow shaft from below. Tolerance shrinks the diameter
// (split evenly per side). Centred on the origin, growing in +Z.
module oralb_head_peg(tolerance = 0.3) {
    d = max(0.1, ORALB_HEAD_PEG_D - tolerance);
    cylinder(d = d, h = ORALB_HEAD_PEG_H);
}

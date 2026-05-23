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
ORALB_PEG_W_BACK    = 8.2;   // width at the back (charging-side) end
ORALB_PEG_W_FRONT   = 6.5;   // width at the front (bristle-side) end
ORALB_PEG_LENGTH    = 9.3;   // back end → front end along the long axis
ORALB_PEG_CORNER_R  = 4.0;   // rounding radius applied at every corner
ORALB_PEG_HEIGHT    = 5.0;   // vertical peg height (≤ ~12.5 mm recess depth)
ORALB_PEG_DEPTH_MAX = 12.5;  // brush's recess depth — keep ORALB_PEG_HEIGHT under this

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

// Oral-B brush body peg — straight extrusion of the trapezoidal
// rounded rectangle, no vertical taper. `tolerance` is the only knob:
// it's subtracted from the linear dimensions and from twice the corner
// radius (≈ even per-side clearance everywhere). The long axis comes
// out along world Y with the wider "back" end at +Y.
module oralb_body_peg(tolerance = 0.3) {
    wb = max(0.1, ORALB_PEG_W_BACK   - tolerance);
    wf = max(0.1, ORALB_PEG_W_FRONT  - tolerance);
    l  = max(0.1, ORALB_PEG_LENGTH   - tolerance);
    rr = max(0.1, ORALB_PEG_CORNER_R - tolerance / 2);
    linear_extrude(height = ORALB_PEG_HEIGHT)
        asym_rounded_rect_2d(wb, wf, l, rr);
}

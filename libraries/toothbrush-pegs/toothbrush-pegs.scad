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

// Oral-B (Type 3766-class) handle base peg dimensions. The geometry is
// FIXED — only `tolerance` is exposed on the module below — because the
// brush's recess never changes between handles and a known-good shape
// is more useful than a tunable one. If you find these are wrong for
// your handle, edit these constants and the test piece will pick up
// the new sizes automatically.
ORALB_PEG_D_BACK    = 7.1;   // wider arc Ø (charging-side end)
ORALB_PEG_D_FRONT   = 5.4;   // narrower arc Ø (bristle-side end)
ORALB_PEG_LENGTH    = 7.9;   // back arc edge → front arc edge along the long axis
ORALB_PEG_HEIGHT    = 7.5;   // vertical peg height (≤ ~12.5 mm recess depth)
ORALB_PEG_DEPTH_MAX = 12.5;  // brush's recess depth — keep ORALB_PEG_HEIGHT under this

// Asymmetric stadium: hull of two circles of different Ø joined by
// tangent lines. Centered along the long axis (X here); back circle on
// the −X side (wider), front on the +X side (narrower). Used by the
// peg module below — exposed in case you want the 2D footprint for a
// matching recess cut.
module asym_stadium_2d(d_back, d_front, length) {
    sep = length - (d_back + d_front) / 2;
    translate([-sep / 2, 0])
        hull() {
            circle(d = d_back);
            translate([sep, 0]) circle(d = d_front);
        }
}

// Oral-B brush body peg — straight extrusion of the asymmetric stadium,
// no vertical taper. `tolerance` is the only knob: it's subtracted from
// every XY dimension (split per side) so the peg slides into the recess
// without binding. The long axis comes out along world Y with the
// wider "back" end at +Y.
module oralb_body_peg(tolerance = 0.3) {
    d_back_t  = max(0.1, ORALB_PEG_D_BACK  - tolerance);
    d_front_t = max(0.1, ORALB_PEG_D_FRONT - tolerance);
    length_t  = max(d_back_t + d_front_t, ORALB_PEG_LENGTH - tolerance);
    rotate([0, 0, -90])  // map 2D X → world −Y so back lands at +Y
        linear_extrude(height = ORALB_PEG_HEIGHT)
            asym_stadium_2d(d_back_t, d_front_t, length_t);
}

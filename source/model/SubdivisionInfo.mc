import Toybox.Lang;

// Metadata for the supported subdivisions. The drawable mapping lives in the
// renderer (which owns resource loading); this module is the source of truth for
// which subdivisions exist and how they are labelled.
module SubdivisionInfo {

    function values() as Array<Number> {
        return [
            MetronomeConstants.SUB_QUARTER,
            MetronomeConstants.SUB_EIGHTH,
            MetronomeConstants.SUB_TRIPLET
        ];
    }

    function name(subdivision as Number) as String {
        if (subdivision == MetronomeConstants.SUB_EIGHTH)  { return "Eighth"; }
        if (subdivision == MetronomeConstants.SUB_TRIPLET) { return "Triplet"; }
        return "Quarter";
    }

    function isValid(subdivision as Number) as Boolean {
        return subdivision == MetronomeConstants.SUB_QUARTER
            || subdivision == MetronomeConstants.SUB_EIGHTH
            || subdivision == MetronomeConstants.SUB_TRIPLET;
    }
}

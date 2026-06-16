import Toybox.Lang;

// Contract that MetronomeEngine calls back on. The coordinator view implements
// these same method signatures; the engine holds the listener untyped so any
// object honoring this shape can be wired in (no UI/storage coupling here).
class MetronomeEngineListener {

    function initialize() {
    }

    // Fired on every on-beat. beatIndex is 0-based within the bar; isDownbeat is
    // true only on beat 0 when beatsPerBar > 1.
    function onMainBeat(beatIndex as Number, isDownbeat as Boolean) as Void {
    }

    // Fired on every subdivision tick that is not an on-beat.
    function onSubBeat() as Void {
    }
}

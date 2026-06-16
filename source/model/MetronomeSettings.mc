import Toybox.Lang;

// Typed, self-validating bag of every user-facing setting. Owns its own
// clamping rules and all display labels, plus the subdivision BPM-cap math.
class MetronomeSettings {

    public var bpm as Number = MetronomeConstants.DEFAULT_BPM;
    public var beatsPerBar as Number = MetronomeConstants.DEFAULT_BPB;
    public var subdivision as Number = MetronomeConstants.DEFAULT_SUBDIVISION;
    public var soundMode as Number = MetronomeConstants.DEFAULT_SOUND_MODE;
    public var vibrationEnabled as Boolean = MetronomeConstants.DEFAULT_VIBRATION;
    public var vibeStrength as Number = MetronomeConstants.DEFAULT_VIBE_STRENGTH;
    public var vibePulse as Number = MetronomeConstants.DEFAULT_VIBE_PULSE;
    public var timeMode as Number = MetronomeConstants.DEFAULT_TIME_MODE;

    function initialize() {
    }

    // Force every field into a legal range. Critically, bpm is clamped to the
    // effective max for the current subdivision so we never drive the hardware
    // faster than it can produce distinct ticks.
    function clamp() as Void {
        if (!SubdivisionInfo.isValid(subdivision)) {
            subdivision = MetronomeConstants.DEFAULT_SUBDIVISION;
        }

        if (beatsPerBar < MetronomeConstants.MIN_BPB) { beatsPerBar = MetronomeConstants.MIN_BPB; }
        if (beatsPerBar > MetronomeConstants.MAX_BPB) { beatsPerBar = MetronomeConstants.MAX_BPB; }

        if (!isValidSoundMode(soundMode)) {
            soundMode = MetronomeConstants.DEFAULT_SOUND_MODE;
        }

        if (timeMode < MetronomeConstants.TIME_OFF || timeMode > MetronomeConstants.TIME_ELAPSED) {
            timeMode = MetronomeConstants.DEFAULT_TIME_MODE;
        }

        if (vibeStrength < 0)   { vibeStrength = 0; }
        if (vibeStrength > 100) { vibeStrength = 100; }
        if (vibePulse < 0)      { vibePulse = 0; }

        var maxBpm = effectiveMaxBpm();
        if (bpm < MetronomeConstants.MIN_BPM) { bpm = MetronomeConstants.MIN_BPM; }
        if (bpm > maxBpm)                     { bpm = maxBpm; }
    }

    private function isValidSoundMode(mode as Number) as Boolean {
        return mode == MetronomeConstants.SOUND_OFF
            || mode == MetronomeConstants.SOUND_HIGH_BEEP
            || mode == MetronomeConstants.SOUND_CLICK
            || mode == MetronomeConstants.SOUND_BLOCK
            || mode == MetronomeConstants.SOUND_LOW_BEEP;
    }

    // --- BPM cap math -------------------------------------------------------

    // Longest feedback (sound OR vibration) that a single tick must produce,
    // given the current sound mode and vibration settings.
    function feedbackDurationMs() as Number {
        var soundDur = (soundMode > MetronomeConstants.SOUND_OFF)
            ? SoundModeInfo.maxDurationMs(soundMode)
            : 0;
        // Downbeats vibrate for vibePulse + 50ms; size the cap for the worst case.
        var vibeDur = vibrationEnabled ? (vibePulse + 50) : 0;
        return (soundDur > vibeDur) ? soundDur : vibeDur;
    }

    // Highest BPM that still leaves room for one full feedback pulse per tick at
    // the given subdivision. Higher subdivisions => lower cap.
    function maxBpmFor(sub as Number) as Number {
        var minTick = feedbackDurationMs() + MetronomeConstants.SUBDIVISION_GUARD_MS;
        if (minTick < 1) { minTick = 1; }

        var maxBpm = 60000 / (sub * minTick);  // integer division
        if (maxBpm > MetronomeConstants.MAX_BPM) { maxBpm = MetronomeConstants.MAX_BPM; }
        if (maxBpm < MetronomeConstants.MIN_BPM) { maxBpm = MetronomeConstants.MIN_BPM; }

        // Snap down onto the BPM step grid so the cap is always reachable by +/-.
        maxBpm = maxBpm - (maxBpm % MetronomeConstants.BPM_STEP);
        return maxBpm;
    }

    function effectiveMaxBpm() as Number {
        return maxBpmFor(subdivision);
    }

    // --- Display labels -----------------------------------------------------

    function getSoundModeName() as String {
        return SoundModeInfo.name(soundMode);
    }

    function getSubdivisionName() as String {
        return SubdivisionInfo.name(subdivision);
    }

    function getTimeModeName() as String {
        if (timeMode == MetronomeConstants.TIME_OFF)     { return "Off"; }
        if (timeMode == MetronomeConstants.TIME_ELAPSED) { return "Elapsed"; }
        return "Clock";
    }

    function getTempoLabel() as String {
        if (bpm < 40)  { return "Grave"; }
        if (bpm < 60)  { return "Largo"; }
        if (bpm < 66)  { return "Larghetto"; }
        if (bpm < 76)  { return "Adagio"; }
        if (bpm < 90)  { return "Andante"; }
        if (bpm < 105) { return "Moderato"; }
        if (bpm < 115) { return "Allegretto"; }
        if (bpm < 130) { return "Allegro"; }
        if (bpm < 168) { return "Vivace"; }
        if (bpm < 200) { return "Presto"; }
        return "Prestissimo";
    }
}

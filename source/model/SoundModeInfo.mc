import Toybox.Lang;
import Toybox.Attention;

// Tone profile tables for every sound mode, keyed by beat tier.
// This is pure data + helpers; actually playing the tone lives in BeatFeedback.
module SoundModeInfo {

    function name(mode as Number) as String {
        if (mode == MetronomeConstants.SOUND_OFF)       { return "Off"; }
        if (mode == MetronomeConstants.SOUND_CLICK)     { return "Click"; }
        if (mode == MetronomeConstants.SOUND_BLOCK)     { return "Block"; }
        if (mode == MetronomeConstants.SOUND_LOW_BEEP)  { return "Low Beep"; }
        return "High Beep";
    }

    // Longest tone (in ms) this mode can emit on a single tick. Used to size the
    // BPM cap: a tick can never be shorter than the sound it has to produce.
    function maxDurationMs(mode as Number) as Number {
        if (mode == MetronomeConstants.SOUND_OFF)    { return 0; }
        if (mode == MetronomeConstants.SOUND_CLICK)  { return 20; }
        if (mode == MetronomeConstants.SOUND_BLOCK)  { return 50; }  // 12 + 26 + 12
        return 170;  // High/Low beep downbeat
    }

    // Returns an Array of Attention.ToneProfile for the given mode + event tier,
    // or null when nothing should sound.
    function toneProfile(mode as Number, event as Number) as Array<Attention.ToneProfile>? {
        if (mode == MetronomeConstants.SOUND_OFF) {
            return null;
        }

        var isDown = (event == MetronomeConstants.EVENT_DOWNBEAT);
        var isSub  = (event == MetronomeConstants.EVENT_SUBBEAT);

        if (mode == MetronomeConstants.SOUND_HIGH_BEEP) {
            if (isSub)  { return [new Attention.ToneProfile(2000, 40)]; }
            if (isDown) { return [new Attention.ToneProfile(3000, 170)]; }
            return [new Attention.ToneProfile(2200, 70)];
        }

        if (mode == MetronomeConstants.SOUND_LOW_BEEP) {
            if (isSub)  { return [new Attention.ToneProfile(700, 40)]; }
            if (isDown) { return [new Attention.ToneProfile(1200, 170)]; }
            return [new Attention.ToneProfile(800, 70)];
        }

        if (mode == MetronomeConstants.SOUND_CLICK) {
            if (isSub)  { return [new Attention.ToneProfile(3200, 8)]; }
            if (isDown) { return [new Attention.ToneProfile(3800, 20)]; }
            return [new Attention.ToneProfile(3400, 12)];
        }

        // SOUND_BLOCK — faked "wood knock": a short dip-and-return pitch shape that
        // reads as a rounded percussive "tok" within the piezo's reproducible band.
        if (isSub) {
            return [new Attention.ToneProfile(300, 8)];
        }
        if (isDown) {
            return [
                new Attention.ToneProfile(600, 12),
                new Attention.ToneProfile(0, 26),
                new Attention.ToneProfile(600, 12)
            ];
        }
        return [
            new Attention.ToneProfile(300, 12),
            new Attention.ToneProfile(0, 26),
            new Attention.ToneProfile(300, 12)
        ];
    }
}

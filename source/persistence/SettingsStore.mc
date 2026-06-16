import Toybox.Lang;
import Toybox.Application;

// Single place that knows how settings map to Application.Storage. Reads are
// defensive: bad/corrupt values fall back to defaults and are clamped on load.
module SettingsStore {

    function load() as MetronomeSettings {
        var s = new MetronomeSettings();

        var bpm = Application.Storage.getValue(MetronomeConstants.KEY_BPM);
        if (bpm != null && bpm instanceof Number) { s.bpm = bpm; }

        var sound = Application.Storage.getValue(MetronomeConstants.KEY_SOUND);
        if (sound != null && sound instanceof Number) { s.soundMode = sound; }

        var vibe = Application.Storage.getValue(MetronomeConstants.KEY_VIBRATION);
        if (vibe != null && vibe instanceof Boolean) { s.vibrationEnabled = vibe; }

        var bpb = Application.Storage.getValue(MetronomeConstants.KEY_BPB);
        if (bpb != null && bpb instanceof Number) { s.beatsPerBar = bpb; }

        var vs = Application.Storage.getValue(MetronomeConstants.KEY_VIBE_STRENGTH);
        if (vs != null && vs instanceof Number) { s.vibeStrength = vs; }

        var vp = Application.Storage.getValue(MetronomeConstants.KEY_VIBE_PULSE);
        if (vp != null && vp instanceof Number) { s.vibePulse = vp; }

        var tm = Application.Storage.getValue(MetronomeConstants.KEY_TIME_MODE);
        if (tm != null && tm instanceof Number) { s.timeMode = tm; }

        var sub = Application.Storage.getValue(MetronomeConstants.KEY_SUBDIVISION);
        if (sub != null && sub instanceof Number) { s.subdivision = sub; }

        s.clamp();
        return s;
    }

    function save(s as MetronomeSettings) as Void {
        Application.Storage.setValue(MetronomeConstants.KEY_VERSION, MetronomeConstants.SETTINGS_VERSION);
        Application.Storage.setValue(MetronomeConstants.KEY_BPM, s.bpm);
        Application.Storage.setValue(MetronomeConstants.KEY_SOUND, s.soundMode);
        Application.Storage.setValue(MetronomeConstants.KEY_VIBRATION, s.vibrationEnabled);
        Application.Storage.setValue(MetronomeConstants.KEY_BPB, s.beatsPerBar);
        Application.Storage.setValue(MetronomeConstants.KEY_VIBE_STRENGTH, s.vibeStrength);
        Application.Storage.setValue(MetronomeConstants.KEY_VIBE_PULSE, s.vibePulse);
        Application.Storage.setValue(MetronomeConstants.KEY_TIME_MODE, s.timeMode);
        Application.Storage.setValue(MetronomeConstants.KEY_SUBDIVISION, s.subdivision);
    }
}

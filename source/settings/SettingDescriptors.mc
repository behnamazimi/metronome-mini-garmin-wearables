import Toybox.Lang;

// Single registry describing every list-style setting: its option labels/values,
// how to read its current display label, and how to apply a chosen value. Adding
// a new option setting means one more branch here instead of a new delegate.
module SettingDescriptors {

    // Build the OptionMenu config ({:title, :labels, :values, :current}) for a
    // setting id, reading current state from the view's settings.
    function config(id as Symbol, view as MetronomeMiniView) as Dictionary {
        var s = view.getSettings();

        if (id == :sound) {
            return {
                :title => "Sound",
                :labels => ["Off", "High Beep", "Low Beep", "Click", "Block"],
                :values => [
                    MetronomeConstants.SOUND_OFF,
                    MetronomeConstants.SOUND_HIGH_BEEP,
                    MetronomeConstants.SOUND_LOW_BEEP,
                    MetronomeConstants.SOUND_CLICK,
                    MetronomeConstants.SOUND_BLOCK
                ],
                :current => s.soundMode
            };
        }

        if (id == :vibeStrength) {
            return {
                :title => "Vibe Strength",
                :labels => ["50%", "75%", "100%"],
                :values => [50, 75, 100],
                :current => s.vibeStrength
            };
        }

        if (id == :vibePulse) {
            return {
                :title => "Vibe Pulse",
                :labels => ["50ms", "80ms", "100ms"],
                :values => [50, 80, 100],
                :current => s.vibePulse
            };
        }

        if (id == :beatsPerBar) {
            var bpbLabels = [];
            var bpbValues = [];
            for (var i = MetronomeConstants.MIN_BPB; i <= MetronomeConstants.MAX_BPB; i++) {
                bpbLabels.add(i.toString());
                bpbValues.add(i);
            }
            return {
                :title => "Beats/Bar",
                :labels => bpbLabels,
                :values => bpbValues,
                :current => s.beatsPerBar
            };
        }

        if (id == :subdivision) {
            // Each subdivision shows its hardware BPM cap, which shrinks as the
            // subdivision count rises (more ticks per beat => less time each).
            var subs = SubdivisionInfo.values();
            var subLabels = [];
            var subValues = [];
            for (var i = 0; i < subs.size(); i++) {
                var sub = subs[i];
                subLabels.add(SubdivisionInfo.name(sub) + "  ≤" + s.maxBpmFor(sub).toString());
                subValues.add(sub);
            }
            return {
                :title => "Subdivision",
                :labels => subLabels,
                :values => subValues,
                :current => s.subdivision
            };
        }

        if (id == :timeMode) {
            return {
                :title => "Time Display",
                :labels => ["Off", "Clock", "Elapsed"],
                :values => [
                    MetronomeConstants.TIME_OFF,
                    MetronomeConstants.TIME_CLOCK,
                    MetronomeConstants.TIME_ELAPSED
                ],
                :current => s.timeMode
            };
        }

        return {};
    }

    function apply(id as Symbol, view as MetronomeMiniView, value as Number) as Void {
        if (id == :sound) {
            view.setSoundMode(value);
        } else if (id == :vibeStrength) {
            view.setVibeStrength(value);
        } else if (id == :vibePulse) {
            view.setVibePulse(value);
        } else if (id == :beatsPerBar) {
            view.setBeatsPerBar(value);
        } else if (id == :subdivision) {
            view.setSubdivision(value);
        } else if (id == :timeMode) {
            view.setTimeMode(value);
        }
    }

    function subLabel(id as Symbol, view as MetronomeMiniView) as String {
        var s = view.getSettings();
        if (id == :sound)        { return s.getSoundModeName(); }
        if (id == :vibeStrength) { return s.vibeStrength.toString() + "%"; }
        if (id == :vibePulse)    { return s.vibePulse.toString() + "ms"; }
        if (id == :beatsPerBar)  { return s.beatsPerBar.toString(); }
        if (id == :subdivision)  { return s.getSubdivisionName(); }
        if (id == :timeMode)     { return s.getTimeModeName(); }
        return "";
    }
}

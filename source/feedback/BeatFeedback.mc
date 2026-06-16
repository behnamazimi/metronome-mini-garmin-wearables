import Toybox.Lang;
import Toybox.Attention;

// Owns all Attention API access: vibration + tone, differentiated per beat tier.
// Capability-checked so it degrades gracefully on devices without tones/vibe.
class BeatFeedback {

    private var _settings as MetronomeSettings;

    function initialize(settings as MetronomeSettings) {
        _settings = settings;
    }

    function play(event as Number) as Void {
        playVibration(event);
        playSound(event);
    }

    private function playVibration(event as Number) as Void {
        if (!_settings.vibrationEnabled || !(Attention has :vibrate)) {
            return;
        }

        var strength;
        var pulse;
        if (event == MetronomeConstants.EVENT_DOWNBEAT) {
            strength = 100;
            pulse = _settings.vibePulse + 50;
        } else if (event == MetronomeConstants.EVENT_SUBBEAT) {
            strength = _settings.vibeStrength / 2;
            if (strength < 25) { strength = 25; }
            pulse = _settings.vibePulse / 2;
            if (pulse < 20) { pulse = 20; }
        } else {
            strength = _settings.vibeStrength;
            pulse = _settings.vibePulse;
        }

        Attention.vibrate([new Attention.VibeProfile(strength, pulse)]);
    }

    private function playSound(event as Number) as Void {
        if (_settings.soundMode == MetronomeConstants.SOUND_OFF) {
            return;
        }

        if (Attention has :ToneProfile) {
            var profile = SoundModeInfo.toneProfile(_settings.soundMode, event);
            if (profile != null) {
                Attention.playTone({:toneProfile => profile});
            }
        } else if (Attention has :playTone) {
            // No custom tone support: only mark on-beats so subdivisions don't
            // spam a loud generic beep.
            if (event != MetronomeConstants.EVENT_SUBBEAT) {
                Attention.playTone(Attention.TONE_LOUD_BEEP);
            }
        }
    }
}

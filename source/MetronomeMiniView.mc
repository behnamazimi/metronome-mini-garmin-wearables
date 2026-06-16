import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.System;
import Toybox.Attention;

// Thin coordinator. Wires the layers together, implements the engine listener,
// and exposes a narrow action API to the delegate + settings menus. No timer,
// audio, storage, or layout math lives here directly.
class MetronomeMiniView extends WatchUi.View {

    private var _settings as MetronomeSettings;
    private var _engine as MetronomeEngine;
    private var _feedback as BeatFeedback;
    private var _renderer as MainScreenRenderer;

    private var _screenWidth as Number = 0;
    private var _screenHeight as Number = 0;

    // Transient beat-flash state driven by engine callbacks.
    private var _showBeat as Boolean = false;
    private var _isDownbeat as Boolean = false;
    private var _isSubBeat as Boolean = false;
    private var _displayBeat as Number = 0;
    private var _flashTimer as Timer.Timer?;

    private var _wasRunning as Boolean = false;
    private var _startTimeMs as Number = 0;

    function initialize() {
        View.initialize();
        _settings = SettingsStore.load();
        _engine = new MetronomeEngine(self);
        _feedback = new BeatFeedback(_settings);
        _renderer = new MainScreenRenderer();
        initScreenDimensions();
    }

    private function initScreenDimensions() as Void {
        var settings = System.getDeviceSettings();
        _screenWidth = settings.screenWidth;
        _screenHeight = settings.screenHeight;
    }

    function onLayout(dc as Graphics.Dc) as Void {
        _screenWidth = dc.getWidth();
        _screenHeight = dc.getHeight();
    }

    function onShow() as Void {
    }

    function onHide() as Void {
        // Leaving the screen: never leave a timer or buzz running.
        _engine.stop();
        cancelFlash();
    }

    // Called from the app's onStop so timers/audio can't leak on exit.
    function onAppStop() as Void {
        _engine.stop();
        cancelFlash();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var layout = new LayoutMetrics(dc);
        _screenWidth = layout.width;
        _screenHeight = layout.height;
        _renderer.draw(dc, layout, buildSnapshot());
    }

    private function buildSnapshot() as Dictionary {
        return {
            :bpm => _settings.bpm,
            :tempoLabel => _settings.getTempoLabel(),
            :isRunning => _engine.isRunning(),
            :showBeat => _showBeat,
            :isDownbeat => _isDownbeat,
            :isSubBeat => _isSubBeat,
            :displayBeat => _displayBeat,
            :beatsPerBar => _settings.beatsPerBar,
            :subdivision => _settings.subdivision,
            :timeStr => buildTimeStr()
        };
    }

    private function buildTimeStr() as String? {
        if (_settings.timeMode == MetronomeConstants.TIME_OFF) {
            return null;
        }
        if (_settings.timeMode == MetronomeConstants.TIME_CLOCK) {
            var clockInfo = System.getClockTime();
            var minStr = clockInfo.min < 10 ? "0" + clockInfo.min.toString() : clockInfo.min.toString();
            return clockInfo.hour.toString() + ":" + minStr;
        }
        // Elapsed
        if (!_engine.isRunning()) {
            return "0:00";
        }
        var elapsedMs = System.getTimer() - _startTimeMs;
        var totalSecs = (elapsedMs / 1000).toNumber();
        var mins = totalSecs / 60;
        var secs = totalSecs % 60;
        var secsStr = secs < 10 ? "0" + secs.toString() : secs.toString();
        return mins.toString() + ":" + secsStr;
    }

    // --- MetronomeEngineListener implementation -----------------------------

    function onMainBeat(beatIndex as Number, isDownbeat as Boolean) as Void {
        _displayBeat = beatIndex + 1;
        _isDownbeat = isDownbeat;
        _isSubBeat = false;
        _feedback.play(isDownbeat ? MetronomeConstants.EVENT_DOWNBEAT : MetronomeConstants.EVENT_MAINBEAT);
        flash();
    }

    function onSubBeat() as Void {
        _isDownbeat = false;
        _isSubBeat = true;
        _feedback.play(MetronomeConstants.EVENT_SUBBEAT);
        flash();
    }

    private function flash() as Void {
        _showBeat = true;
        WatchUi.requestUpdate();
        cancelFlash();
        _flashTimer = new Timer.Timer();
        _flashTimer.start(method(:clearBeat), MetronomeConstants.BEAT_FLASH_MS, false);
    }

    private function cancelFlash() as Void {
        if (_flashTimer != null) {
            _flashTimer.stop();
            _flashTimer = null;
        }
    }

    function clearBeat() as Void {
        _showBeat = false;
        WatchUi.requestUpdate();
    }

    // --- Public actions (delegate / menus) ----------------------------------

    function toggleMetronome() as Void {
        if (_engine.isRunning()) {
            stopRun();
        } else {
            startRun();
        }
        WatchUi.requestUpdate();
    }

    private function startRun() as Void {
        _startTimeMs = System.getTimer();
        _engine.start(_settings);
    }

    private function stopRun() as Void {
        _engine.stop();
        _displayBeat = 0;
        _isDownbeat = false;
        _isSubBeat = false;
        _showBeat = false;
        cancelFlash();
    }

    function pauseForSettings() as Void {
        _wasRunning = _engine.isRunning();
        if (_wasRunning) {
            stopRun();
            WatchUi.requestUpdate();
        }
    }

    function resumeFromSettings() as Void {
        if (_wasRunning) {
            startRun();
            WatchUi.requestUpdate();
        }
        _wasRunning = false;
    }

    function increaseBpm() as Void {
        var maxBpm = _settings.effectiveMaxBpm();
        if (_settings.bpm < maxBpm) {
            _settings.bpm += MetronomeConstants.BPM_STEP;
            applySettingChange();
        }
    }

    function decreaseBpm() as Void {
        if (_settings.bpm > MetronomeConstants.MIN_BPM) {
            _settings.bpm -= MetronomeConstants.BPM_STEP;
            applySettingChange();
        }
    }

    function setSoundMode(value as Number) as Void {
        _settings.soundMode = value;
        applySettingChange();
    }

    function setBeatsPerBar(value as Number) as Void {
        _settings.beatsPerBar = value;
        applySettingChange();
    }

    function setSubdivision(value as Number) as Void {
        _settings.subdivision = value;
        applySettingChange();
    }

    function setVibeStrength(value as Number) as Void {
        _settings.vibeStrength = value;
        applySettingChange();
    }

    function setVibePulse(value as Number) as Void {
        _settings.vibePulse = value;
        applySettingChange();
    }

    function setTimeMode(value as Number) as Void {
        _settings.timeMode = value;
        applySettingChange();
    }

    function toggleVibration() as Void {
        _settings.vibrationEnabled = !_settings.vibrationEnabled;
        applySettingChange();
    }

    // Re-validate (cap may have shifted), persist, and retime a live run.
    private function applySettingChange() as Void {
        _settings.clamp();
        SettingsStore.save(_settings);
        if (_engine.isRunning()) {
            _engine.restart(_settings);
        }
        WatchUi.requestUpdate();
    }

    // --- Accessors ----------------------------------------------------------

    function getSettings() as MetronomeSettings {
        return _settings;
    }

    function isRunning() as Boolean {
        return _engine.isRunning();
    }

    function isSoundSupported() as Boolean {
        return Attention has :playTone;
    }

    function getScreenWidth() as Number {
        return _screenWidth;
    }

    function getScreenHeight() as Number {
        return _screenHeight;
    }

    function getTapZoneWidth() as Number {
        return LayoutMetrics.tapZoneWidth(_screenWidth);
    }
}

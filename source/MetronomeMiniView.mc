import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Attention;
import Toybox.Application;
import Toybox.System;

class MetronomeMiniView extends WatchUi.View {

    private var _isRunning as Boolean = false;
    private var _wasRunning as Boolean = false;
    private var _timer as Timer.Timer?;
    private var _beatTimer as Timer.Timer?;
    private var _showBeat as Boolean = false;
    private var _isDownbeat as Boolean = false;
    private var _bpm as Number = 60;
    private var _beatsPerBar as Number = 1;
    private var _currentBeat as Number = 0;
    private var _displayBeat as Number = 0;
    private var _screenHeight as Number = 0;
    private var _screenWidth as Number = 0;
    private var _soundMode as Number = 1;
    private var _vibrationEnabled as Boolean = true;
    private var _vibeStrength as Number = 75;
    private var _vibePulse as Number = 50;
    private var _timeMode as Number = 1;       // 0=Off, 1=Current time, 2=Elapsed time
    private var _metronomeStartTime as Number = 0;
    private var _hasTouchScreen as Boolean = false;
    private var _usesSpeakerTones as Boolean? = null;

    private const MIN_BPM = 30;
    private const MAX_BPM = 250;
    private const BPM_STEP = 2;

    function initialize() {
        View.initialize();
        loadSettings();
        initScreenDimensions();
    }

    private function initScreenDimensions() as Void {
        var settings = System.getDeviceSettings();
        _screenWidth = settings.screenWidth;
        _screenHeight = settings.screenHeight;
        _hasTouchScreen = settings.isTouchScreen;
    }

    function onLayout(dc as Dc) as Void {
        _screenWidth = dc.getWidth();
        _screenHeight = dc.getHeight();
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        _screenWidth = dc.getWidth();
        _screenHeight = dc.getHeight();
        var centerX = _screenWidth / 2;
        var centerY = _screenHeight / 2;

        // Proportional sizes based on screen
        var sideZoneWidth = (_screenWidth * 22) / 100;  // 22% of width for side tap zones
        var buttonZoneRadius = (_screenHeight * 28) / 100;  // 28% for side button visual
        var buttonRadius = (_screenWidth * 10) / 100;  // 10% of width
        var iconSize = (_screenWidth * 5) / 100;  // 5% of width
        var playIconSize = (_screenWidth * 4) / 100;  // 4% of width

        // Layout positions
        var bpmY = centerY - (_screenHeight * 5) / 100;
        var tempoY = bpmY - (_screenHeight * 16) / 100;
        var labelY = centerY + (_screenHeight * 12) / 100;
        var buttonY = _screenHeight - (_screenHeight * 15) / 100;
        var bpbY = (_screenHeight * 10) / 100;

        // Background
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Beat flash - ring around edge (white on downbeat, gray on regular beat)
        if (_showBeat && _isRunning) {
            var flashColor = _isDownbeat ? Graphics.COLOR_WHITE : 0x888888;
            dc.setColor(flashColor, Graphics.COLOR_TRANSPARENT);
            var penWidth = (_screenWidth * 4) / 100;
            if (penWidth < 4) { penWidth = 4; }
            dc.setPenWidth(penWidth);
            dc.drawCircle(centerX, centerY, (_screenWidth / 2) - penWidth);
            dc.setPenWidth(1);
        }

        // Draw - and + button zones only on touch-capable devices
        if (_hasTouchScreen) {
            dc.setColor(0x161616, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(0, centerY, buttonZoneRadius);
            dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
            dc.drawText(sideZoneWidth / 2 + 4, centerY, Graphics.FONT_NUMBER_MILD, "-", 
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

            dc.setColor(0x161616, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(_screenWidth, centerY, buttonZoneRadius);
            dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_screenWidth - (sideZoneWidth / 2) - 4, centerY, Graphics.FONT_NUMBER_MILD, "+", 
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // BPM value - large, prominent, centered vertically
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, bpmY, Graphics.FONT_NUMBER_HOT, _bpm.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Tempo label above BPM number
        dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, tempoY, Graphics.FONT_XTINY, getTempoLabel(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Sub-label: time display when active, otherwise "BPM"
        var subLabel;
        if (_timeMode == 1) {
            var clockInfo = System.getClockTime();
            var minStr = clockInfo.min < 10 ? "0" + clockInfo.min.toString() : clockInfo.min.toString();
            subLabel = clockInfo.hour.toString() + ":" + minStr;
        } else if (_timeMode == 2) {
            if (_isRunning) {
                var elapsedMs = System.getTimer() - _metronomeStartTime;
                var totalSecs = (elapsedMs / 1000).toNumber();
                var mins = totalSecs / 60;
                var secs = totalSecs % 60;
                var secsStr = secs < 10 ? "0" + secs.toString() : secs.toString();
                subLabel = mins.toString() + ":" + secsStr;
            } else {
                subLabel = "0:00";
            }
        } else {
            subLabel = "BPM";
        }
        dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, labelY, Graphics.FONT_TINY, subLabel,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Beat counter / beats-per-bar indicator — only shown when a time signature is active
        if (_beatsPerBar > 1) {
            dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
            var bpbText;
            if (_isRunning && _displayBeat > 0) {
                bpbText = _displayBeat.toString() + " / " + _beatsPerBar.toString();
            } else {
                bpbText = _beatsPerBar.toString() + " BPB";
            }
            dc.drawText(centerX, bpbY, Graphics.FONT_TINY, bpbText,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        // Start/Stop button at bottom
        
        if (_isRunning) {
            dc.setColor(0xCC0000, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(centerX, buttonY, buttonRadius);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(centerX - iconSize/2, buttonY - iconSize/2, iconSize, iconSize);
        } else {
            dc.setColor(0x00AA00, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(centerX, buttonY, buttonRadius);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            var px = playIconSize;
            var py = (playIconSize * 5) / 4;
            dc.fillPolygon([
                [centerX - px, buttonY - py],
                [centerX - px, buttonY + py],
                [centerX + px + (px / 2), buttonY]
            ]);
        }
    }

    function onHide() as Void {
    }

    function toggleMetronome() as Void {
        if (_isRunning) {
            stopMetronome();
        } else {
            startMetronome();
        }
        WatchUi.requestUpdate();
    }

    function pauseForSettings() as Void {
        _wasRunning = _isRunning;
        if (_isRunning) {
            stopMetronome();
            WatchUi.requestUpdate();
        }
    }

    function resumeFromSettings() as Void {
        if (_wasRunning) {
            startMetronome();
            WatchUi.requestUpdate();
        }
        _wasRunning = false;
    }

    function increaseBpm() as Void {
        if (_bpm < MAX_BPM) {
            _bpm += BPM_STEP;
            if (_bpm > MAX_BPM) { _bpm = MAX_BPM; }
            saveSettings();
            if (_isRunning) {
                restartTimer();
            }
            WatchUi.requestUpdate();
        }
    }

    function decreaseBpm() as Void {
        if (_bpm > MIN_BPM) {
            _bpm -= BPM_STEP;
            if (_bpm < MIN_BPM) { _bpm = MIN_BPM; }
            saveSettings();
            if (_isRunning) {
                restartTimer();
            }
            WatchUi.requestUpdate();
        }
    }

    function isRunning() as Boolean {
        return _isRunning;
    }

    function getScreenWidth() as Number {
        return _screenWidth;
    }

    function getScreenHeight() as Number {
        return _screenHeight;
    }

    function getTapZoneWidth() as Number {
        return (_screenWidth * 22) / 100;
    }

    private function getTempoLabel() as String {
        if (_bpm < 40)  { return "Grave"; }
        if (_bpm < 60)  { return "Largo"; }
        if (_bpm < 66)  { return "Larghetto"; }
        if (_bpm < 76)  { return "Adagio"; }
        if (_bpm < 90)  { return "Andante"; }
        if (_bpm < 105) { return "Moderato"; }
        if (_bpm < 115) { return "Allegretto"; }
        if (_bpm < 130) { return "Allegro"; }
        if (_bpm < 168) { return "Vivace"; }
        if (_bpm < 200) { return "Presto"; }
        return "Prestissimo";
    }

    private function startMetronome() as Void {
        _isRunning = true;
        _metronomeStartTime = System.getTimer();
        startTimer();
        triggerBeat();
    }

    private function stopMetronome() as Void {
        _isRunning = false;
        _currentBeat = 0;
        _displayBeat = 0;
        _isDownbeat = false;
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
        if (_beatTimer != null) {
            _beatTimer.stop();
            _beatTimer = null;
        }
        _showBeat = false;
    }

    private function startTimer() as Void {
        var interval = (60000 / _bpm).toNumber();
        _timer = new Timer.Timer();
        _timer.start(method(:onTick), interval, true);
    }

    private function restartTimer() as Void {
        if (_timer != null) {
            _timer.stop();
        }
        startTimer();
    }

    function onTick() as Void {
        triggerBeat();
    }

    private function triggerBeat() as Void {
        _isDownbeat = (_beatsPerBar > 1) && (_currentBeat == 0);
        _displayBeat = _currentBeat + 1;
        _currentBeat = (_currentBeat + 1) % _beatsPerBar;
        doVibrate(_isDownbeat);
        _showBeat = true;
        WatchUi.requestUpdate();
        
        // Clear beat visual after 80ms
        if (_beatTimer != null) {
            _beatTimer.stop();
        }
        _beatTimer = new Timer.Timer();
        _beatTimer.start(method(:clearBeat), 80, false);
    }

    function clearBeat() as Void {
        _showBeat = false;
        WatchUi.requestUpdate();
    }

    private function doVibrate(isDownbeat as Boolean) as Void {
        playBeatVibration(isDownbeat);
        playBeatSound(isDownbeat);
    }

    private function playBeatVibration(isDownbeat as Boolean) as Void {
        if (!_vibrationEnabled || !(Attention has :vibrate)) {
            return;
        }
        var deviceSettings = System.getDeviceSettings();
        if (deviceSettings has :vibrateOn && !deviceSettings.vibrateOn) {
            return;
        }
        var strength = isDownbeat ? 100 : _vibeStrength;
        var pulse    = isDownbeat ? _vibePulse + 50 : _vibePulse;
        Attention.vibrate([new Attention.VibeProfile(strength, pulse)]);
    }

    private function playBeatSound(isDownbeat as Boolean) as Void {
        if (!isSoundEnabled() || !(Attention has :playTone)) {
            return;
        }
        var deviceSettings = System.getDeviceSettings();
        if (deviceSettings has :tonesOn && !deviceSettings.tonesOn) {
            return;
        }
        if (usesSpeakerTones()) {
            playPredefinedBeatSound();
        } else if (Attention has :ToneProfile) {
            playCustomBeatSound(isDownbeat);
        } else {
            Attention.playTone(Attention.TONE_LOUD_BEEP);
        }
    }

    // Speaker-based watches (Venu 3, Fenix 8, etc.) report ToneProfile support but
    // only play Garmin's predefined tones — custom profiles fail silently on device.
    function usesSpeakerTones() as Boolean {
        if (_usesSpeakerTones != null) {
            return _usesSpeakerTones as Boolean;
        }
        _usesSpeakerTones = isSpeakerHardwarePart(getHardwarePartNumber());
        return _usesSpeakerTones as Boolean;
    }

    function hasSoundModeOptions() as Boolean {
        return isSoundSupported() && !usesSpeakerTones();
    }

    private function getHardwarePartNumber() as String {
        var deviceSettings = System.getDeviceSettings();
        if (!(deviceSettings has :partNumber)) {
            return "";
        }
        var partNumber = deviceSettings.partNumber;
        var firstDash = partNumber.find("-");
        if (firstDash == null) {
            return partNumber;
        }
        var remainder = partNumber.substring(firstDash + 1, partNumber.length());
        var secondDash = remainder.find("-");
        if (secondDash == null) {
            return remainder;
        }
        return remainder.substring(0, secondDash);
    }

    private function isSpeakerHardwarePart(hardwarePart as String) as Boolean {
        var speakerParts = [
            "B3851", "B4017", // Venu 2 Plus
            "B4260", "B4261", // Venu 3 / 3S
            "B4643", "B4644", // Venu 4
            "B4603",          // Venu X1
            "B4532", "B4533", "B4534", "B4536", "B4631", // fēnix 8
            "B3943", "B3944", "B4312", "B4313", "B4314", // epix Gen 2 / Pro
            "B4426",          // vívoactive 5
            "B4315", "B4565", // Forerunner 965 / 970
            "B4586", "B4587", "B4678", // Instinct 3 AMOLED / Crossover AMOLED
        ];
        for (var i = 0; i < speakerParts.size(); i++) {
            if (hardwarePart.equals(speakerParts[i])) {
                return true;
            }
        }
        return false;
    }

    private function playPredefinedBeatSound() as Void {
        Attention.playTone(Attention.TONE_LOUD_BEEP);
    }

    private function playCustomBeatSound(isDownbeat as Boolean) as Void {
        if (_soundMode == 1) {
            // High Beep — moderate high tone; downbeat is higher but not sharp
            var freq = isDownbeat ? 3000 : 2200;
            var dur  = isDownbeat ? 170  : 70;
            Attention.playTone({:toneProfile => [new Attention.ToneProfile(freq, dur)]});
        } else if (_soundMode == 4) {
            // Low Beep — lower-pitched tone; downbeat lifts slightly for accent
            var freq = isDownbeat ? 1200 : 800;
            var dur  = isDownbeat ? 170  : 70;
            Attention.playTone({:toneProfile => [new Attention.ToneProfile(freq, dur)]});
        } else if (_soundMode == 2) {
            // Click — sharp high tick (clave/UI click); no sustain
            var freq = isDownbeat ? 3800 : 3400;
            var dur  = isDownbeat ? 20   : 12;
            Attention.playTone({:toneProfile => [new Attention.ToneProfile(freq, dur)]});
        } else {
            // Block — "wood"/mallet knock. The beeper is a piezo (~4 kHz
            // resonance) that can't reproduce low woody fundamentals, so a
            // real wood tone is impossible. Instead we fake the gesture of a
            // struck wooden bar with a short dip-and-return pitch shape
            // (down then back up). This reads as a rounded percussive "tok" —
            // distinct from the flat Beep and the sharp high Click. All tones
            // stay in the piezo's reproducible band.
            if (isDownbeat) {
                Attention.playTone({:toneProfile => [
                    new Attention.ToneProfile(600, 12),
                    new Attention.ToneProfile(0, 26),
                    new Attention.ToneProfile(600, 12),
                ]});
            } else {
                Attention.playTone({:toneProfile => [
                    new Attention.ToneProfile(300, 12),
                    new Attention.ToneProfile(0, 26),
                    new Attention.ToneProfile(300, 12),
                ]});
            }
        }
    }

    function isSoundEnabled() as Boolean {
        return _soundMode > 0;
    }

    function getSoundMode() as Number {
        return _soundMode;
    }

    function getSoundModeName() as String {
        if (_soundMode == 0) { return "Off"; }
        if (_soundMode == 2) { return "Click"; }
        if (_soundMode == 3) { return "Block"; }
        if (_soundMode == 4) { return "Low Beep"; }
        return "High Beep";
    }

    function setSoundMode(n as Number) as Void {
        if (usesSpeakerTones() && n > 0) {
            n = 1;
        }
        _soundMode = n;
        saveSettings();
    }

    function toggleSound() as Void {
        _soundMode = _soundMode > 0 ? 0 : 1;
        saveSettings();
    }

    function isVibrationEnabled() as Boolean {
        return _vibrationEnabled;
    }

    function getBeatsPerBar() as Number {
        return _beatsPerBar;
    }

    function setBeatsPerBar(n as Number) as Void {
        _beatsPerBar = n;
        _currentBeat = 0;
        _isDownbeat = false;
        saveSettings();
    }

    function isSoundSupported() as Boolean {
        return Attention has :playTone;
    }

    function toggleVibration() as Void {
        _vibrationEnabled = !_vibrationEnabled;
        saveSettings();
    }

    function getVibeStrength() as Number {
        return _vibeStrength;
    }

    function setVibeStrength(n as Number) as Void {
        _vibeStrength = n;
        saveSettings();
    }

    function getVibePulse() as Number {
        return _vibePulse;
    }

    function setVibePulse(n as Number) as Void {
        _vibePulse = n;
        saveSettings();
    }

    function getTimeMode() as Number {
        return _timeMode;
    }

    function getTimeModeName() as String {
        if (_timeMode == 0) { return "Off"; }
        if (_timeMode == 2) { return "Elapsed"; }
        return "Clock";
    }

    function setTimeMode(n as Number) as Void {
        _timeMode = n;
        saveSettings();
    }

    private function loadSettings() as Void {
        var stored = Application.Storage.getValue("bpm");
        if (stored != null && stored instanceof Number) {
            _bpm = stored as Number;
            if (_bpm < MIN_BPM) { _bpm = MIN_BPM; }
            if (_bpm > MAX_BPM) { _bpm = MAX_BPM; }
        }
        var sound = Application.Storage.getValue("soundMode");
        if (sound != null && sound instanceof Number) {
            _soundMode = sound as Number;
            if (usesSpeakerTones() && _soundMode > 0) {
                _soundMode = 1;
            }
        }
        var vibe = Application.Storage.getValue("vibration");
        if (vibe != null && vibe instanceof Boolean) {
            _vibrationEnabled = vibe as Boolean;
        }
        var bpb = Application.Storage.getValue("beatsPerBar");
        if (bpb != null && bpb instanceof Number) {
            _beatsPerBar = bpb as Number;
            if (_beatsPerBar < 1) { _beatsPerBar = 1; }
            if (_beatsPerBar > 16) { _beatsPerBar = 16; }
        }
        var vs = Application.Storage.getValue("vibeStrength");
        if (vs != null && vs instanceof Number) {
            _vibeStrength = vs as Number;
        }
        var vp = Application.Storage.getValue("vibePulse");
        if (vp != null && vp instanceof Number) {
            _vibePulse = vp as Number;
        }
        var tm = Application.Storage.getValue("timeMode");
        if (tm != null && tm instanceof Number) {
            _timeMode = tm as Number;
        }
    }

    private function saveSettings() as Void {
        Application.Storage.setValue("bpm", _bpm);
        Application.Storage.setValue("soundMode", _soundMode);
        Application.Storage.setValue("vibration", _vibrationEnabled);
        Application.Storage.setValue("beatsPerBar", _beatsPerBar);
        Application.Storage.setValue("vibeStrength", _vibeStrength);
        Application.Storage.setValue("vibePulse", _vibePulse);
        Application.Storage.setValue("timeMode", _timeMode);
    }

}

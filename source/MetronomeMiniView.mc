import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Attention;
import Toybox.Application;
import Toybox.System;

class MetronomeMiniView extends WatchUi.View {

    private var _isRunning as Boolean = false;
    private var _timer as Timer.Timer?;
    private var _beatTimer as Timer.Timer?;
    private var _showBeat as Boolean = false;
    private var _bpm as Number = 60;
    private var _screenHeight as Number = 0;
    private var _screenWidth as Number = 0;
    private var _soundEnabled as Boolean = true;
    private var _vibrationEnabled as Boolean = true;
    
    private const MIN_BPM = 40;
    private const MAX_BPM = 208;
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

        // Background
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Beat flash - ring around edge
        if (_showBeat && _isRunning) {
            dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
            var penWidth = (_screenWidth * 4) / 100;
            if (penWidth < 4) { penWidth = 4; }
            dc.setPenWidth(penWidth);
            dc.drawCircle(centerX, centerY, (_screenWidth / 2) - penWidth);
            dc.setPenWidth(1);
        }

        // Draw - button zone on LEFT
        dc.setColor(0x222222, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(0, centerY, buttonZoneRadius);
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(sideZoneWidth / 2 + 4, centerY, Graphics.FONT_NUMBER_MILD, "-", 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw + button zone on RIGHT
        dc.setColor(0x222222, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_screenWidth, centerY, buttonZoneRadius);
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_screenWidth - (sideZoneWidth / 2) - 4, centerY, Graphics.FONT_NUMBER_MILD, "+", 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // BPM value - large, prominent, centered vertically
        var bpmY = centerY - (_screenHeight * 10) / 100;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, bpmY, Graphics.FONT_NUMBER_HOT, _bpm.toString(), 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // "BPM" label
        var labelY = centerY + (_screenHeight * 8) / 100;
        dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, labelY, Graphics.FONT_TINY, "BPM", 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Start/Stop button at bottom
        var buttonY = _screenHeight - (_screenHeight * 18) / 100;
        
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

    private function startMetronome() as Void {
        _isRunning = true;
        startTimer();
        triggerBeat();
    }

    private function stopMetronome() as Void {
        _isRunning = false;
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
        doVibrate();
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

    private function doVibrate() as Void {
        if (_vibrationEnabled && Attention has :vibrate) {
            var vibeData = [new Attention.VibeProfile(50, 50)];
            Attention.vibrate(vibeData);
        }
        if (_soundEnabled) {
            if (Attention has :ToneProfile) {
                var toneProfile = [new Attention.ToneProfile(2500, 100)];
                Attention.playTone({:toneProfile => toneProfile});
            } else if (Attention has :playTone) {
                Attention.playTone(Attention.TONE_LOUD_BEEP);
            }
        }
    }

    function isSoundEnabled() as Boolean {
        return _soundEnabled;
    }

    function isVibrationEnabled() as Boolean {
        return _vibrationEnabled;
    }

    function isSoundSupported() as Boolean {
        return Attention has :playTone;
    }

    function toggleSound() as Void {
        _soundEnabled = !_soundEnabled;
        saveSettings();
    }

    function toggleVibration() as Void {
        _vibrationEnabled = !_vibrationEnabled;
        saveSettings();
    }

    private function loadSettings() as Void {
        var stored = Application.Storage.getValue("bpm");
        if (stored != null && stored instanceof Number) {
            _bpm = stored as Number;
            if (_bpm < MIN_BPM) { _bpm = MIN_BPM; }
            if (_bpm > MAX_BPM) { _bpm = MAX_BPM; }
        }
        var sound = Application.Storage.getValue("sound");
        if (sound != null && sound instanceof Boolean) {
            _soundEnabled = sound as Boolean;
        }
        var vibe = Application.Storage.getValue("vibration");
        if (vibe != null && vibe instanceof Boolean) {
            _vibrationEnabled = vibe as Boolean;
        }
    }

    private function saveSettings() as Void {
        Application.Storage.setValue("bpm", _bpm);
        Application.Storage.setValue("sound", _soundEnabled);
        Application.Storage.setValue("vibration", _vibrationEnabled);
    }

}

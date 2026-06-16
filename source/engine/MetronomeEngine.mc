import Toybox.Lang;
import Toybox.Timer;

// Pure timing core. Runs one repeating timer at subdivision resolution
// (tickInterval = beatInterval / subdivision) and reports main vs sub beats to
// its listener. No UI, no audio, no storage.
class MetronomeEngine {

    private var _listener;
    private var _timer as Timer.Timer?;

    private var _running as Boolean = false;
    private var _bpm as Number = MetronomeConstants.DEFAULT_BPM;
    private var _beatsPerBar as Number = MetronomeConstants.DEFAULT_BPB;
    private var _subdivision as Number = MetronomeConstants.DEFAULT_SUBDIVISION;

    // 0-based tick within the bar: 0 .. (beatsPerBar * subdivision - 1)
    private var _tickIndex as Number = 0;

    function initialize(listener) {
        _listener = listener;
    }

    function isRunning() as Boolean {
        return _running;
    }

    // Begin from the top of the bar, firing the downbeat immediately (matches the
    // classic "first beat sounds the moment you press play" behavior).
    function start(settings as MetronomeSettings) as Void {
        applySettings(settings);
        _tickIndex = 0;
        _running = true;
        fireCurrent();
        startTimer();
    }

    function stop() as Void {
        _running = false;
        _tickIndex = 0;
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    // Pick up new tempo/meter/subdivision without interrupting the pulse feel.
    // Does not re-fire the current tick; just retimes the loop.
    function restart(settings as MetronomeSettings) as Void {
        if (!_running) {
            return;
        }
        applySettings(settings);
        _tickIndex = _tickIndex % totalTicks();
        startTimer();
    }

    private function applySettings(settings as MetronomeSettings) as Void {
        _bpm = settings.bpm;
        _beatsPerBar = settings.beatsPerBar;
        _subdivision = settings.subdivision;
    }

    private function totalTicks() as Number {
        return _beatsPerBar * _subdivision;
    }

    private function tickIntervalMs() as Number {
        var interval = 60000 / (_bpm * _subdivision);
        if (interval < 1) { interval = 1; }
        return interval;
    }

    private function startTimer() as Void {
        if (_timer != null) {
            _timer.stop();
        }
        _timer = new Timer.Timer();
        _timer.start(method(:onTick), tickIntervalMs(), true);
    }

    function onTick() as Void {
        _tickIndex = (_tickIndex + 1) % totalTicks();
        fireCurrent();
    }

    private function fireCurrent() as Void {
        if (_tickIndex % _subdivision == 0) {
            var beatIndex = _tickIndex / _subdivision;
            var isDownbeat = (_beatsPerBar > 1) && (beatIndex == 0);
            _listener.onMainBeat(beatIndex, isDownbeat);
        } else {
            _listener.onSubBeat();
        }
    }
}

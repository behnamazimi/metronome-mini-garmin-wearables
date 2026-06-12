import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class MetronomeMiniDelegate extends WatchUi.BehaviorDelegate {

    private var _view as MetronomeMiniView;

    function initialize(view as MetronomeMiniView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var screenWidth = _view.getScreenWidth();
        var tapZone = _view.getTapZoneWidth();
        
        // Tap left zone = decrease BPM
        if (x < tapZone) {
            _view.decreaseBpm();
            return true;
        }
        // Tap right zone = increase BPM
        if (x > screenWidth - tapZone) {
            _view.increaseBpm();
            return true;
        }
        // Tap center = toggle start/stop
        _view.toggleMetronome();
        return true;
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            _view.toggleMetronome();
            return true;
        }
        if (key == WatchUi.KEY_UP) {
            _view.decreaseBpm();
            return true;
        }
        if (key == WatchUi.KEY_DOWN) {
            _view.increaseBpm();
            return true;
        }
        return false;
    }

    function onNextPage() as Boolean {
        _view.decreaseBpm();
        return true;
    }

    function onPreviousPage() as Boolean {
        _view.increaseBpm();
        return true;
    }

    function onMenu() as Boolean {
        var menu = new SettingsMenu(_view);
        WatchUi.pushView(menu, new SettingsMenuDelegate(_view), WatchUi.SLIDE_UP);
        return true;
    }

}
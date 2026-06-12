import Toybox.Lang;
import Toybox.WatchUi;

class SettingsMenu extends WatchUi.Menu2 {

    private var _view as MetronomeMiniView;

    function initialize(view as MetronomeMiniView) {
        Menu2.initialize({:title => "Settings"});
        _view = view;
        
        if (_view.isSoundSupported()) {
            addItem(new WatchUi.ToggleMenuItem(
                "Sound", 
                {:enabled => "On", :disabled => "Off"}, 
                :sound, 
                _view.isSoundEnabled(), 
                {}
            ));
        }
        
        addItem(new WatchUi.ToggleMenuItem(
            "Vibration", 
            {:enabled => "On", :disabled => "Off"}, 
            :vibration, 
            _view.isVibrationEnabled(), 
            {}
        ));
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _view as MetronomeMiniView;

    function initialize(view as MetronomeMiniView) {
        Menu2InputDelegate.initialize();
        _view = view;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (id == :sound) {
            _view.toggleSound();
        } else if (id == :vibration) {
            _view.toggleVibration();
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

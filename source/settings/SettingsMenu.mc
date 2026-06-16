import Toybox.Lang;
import Toybox.WatchUi;

// Top-level settings list. Every list-style row carries its setting id as the
// MenuItem id so the delegate + registry can stay generic.
class SettingsMenu extends WatchUi.Menu2 {

    function initialize(view as MetronomeMiniView) {
        Menu2.initialize({:title => "Settings"});

        if (view.isSoundSupported()) {
            addItem(new WatchUi.MenuItem("Sound", SettingDescriptors.subLabel(:sound, view), :sound, {}));
        }

        addItem(new WatchUi.ToggleMenuItem(
            "Vibration",
            {:enabled => "On", :disabled => "Off"},
            :vibration,
            view.getSettings().vibrationEnabled,
            {}
        ));

        addItem(new WatchUi.MenuItem("Vibe Strength", SettingDescriptors.subLabel(:vibeStrength, view), :vibeStrength, {}));
        addItem(new WatchUi.MenuItem("Vibe Pulse", SettingDescriptors.subLabel(:vibePulse, view), :vibePulse, {}));
        addItem(new WatchUi.MenuItem("Beats/Bar", SettingDescriptors.subLabel(:beatsPerBar, view), :beatsPerBar, {}));
        addItem(new WatchUi.MenuItem("Subdivision", SettingDescriptors.subLabel(:subdivision, view), :subdivision, {}));
        addItem(new WatchUi.MenuItem("Time Display", SettingDescriptors.subLabel(:timeMode, view), :timeMode, {}));
    }

    // Refresh a row's sub-label after its value changed.
    function refreshItem(id as Symbol, view as MetronomeMiniView) as Void {
        var index = findItemById(id);
        if (index >= 0) {
            var item = getItem(index);
            if (item != null) {
                item.setSubLabel(SettingDescriptors.subLabel(id, view));
            }
        }
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _view as MetronomeMiniView;
    private var _menu as SettingsMenu;

    function initialize(view as MetronomeMiniView, menu as SettingsMenu) {
        Menu2InputDelegate.initialize();
        _view = view;
        _menu = menu;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as Symbol;

        if (id == :vibration) {
            _view.toggleVibration();
            return;
        }

        var cfg = SettingDescriptors.config(id, _view);
        var opts = new OptionMenu(cfg);
        WatchUi.pushView(opts, new OptionMenuDelegate(_view, _menu, id), WatchUi.SLIDE_LEFT);
    }

    function onBack() as Void {
        _view.resumeFromSettings();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

import Toybox.Lang;
import Toybox.WatchUi;

class SettingsMenu extends WatchUi.Menu2 {

    private var _beatsPerBarItem as WatchUi.MenuItem;
    private var _vibeStrengthItem as WatchUi.MenuItem;
    private var _vibePulseItem as WatchUi.MenuItem;

    function initialize(view as MetronomeMiniView) {
        Menu2.initialize({:title => "Settings"});

        if (view.isSoundSupported()) {
            addItem(new WatchUi.ToggleMenuItem(
                "Sound",
                {:enabled => "On", :disabled => "Off"},
                :sound,
                view.isSoundEnabled(),
                {}
            ));
        }

        addItem(new WatchUi.ToggleMenuItem(
            "Vibration",
            {:enabled => "On", :disabled => "Off"},
            :vibration,
            view.isVibrationEnabled(),
            {}
        ));

        _vibeStrengthItem = new WatchUi.MenuItem(
            "Vibe Strength",
            view.getVibeStrength().toString() + "%",
            :vibeStrength,
            {}
        );
        addItem(_vibeStrengthItem);

        _vibePulseItem = new WatchUi.MenuItem(
            "Vibe Pulse",
            view.getVibePulse().toString() + "ms",
            :vibePulse,
            {}
        );
        addItem(_vibePulseItem);

        _beatsPerBarItem = new WatchUi.MenuItem(
            "Beats/Bar",
            view.getBeatsPerBar().toString(),
            :beatsPerBar,
            {}
        );
        addItem(_beatsPerBarItem);
    }

    function getBeatsPerBarItem() as WatchUi.MenuItem {
        return _beatsPerBarItem;
    }

    function getVibeStrengthItem() as WatchUi.MenuItem {
        return _vibeStrengthItem;
    }

    function getVibePulseItem() as WatchUi.MenuItem {
        return _vibePulseItem;
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
        var id = item.getId();
        if (id == :sound) {
            _view.toggleSound();
        } else if (id == :vibration) {
            _view.toggleVibration();
        } else if (id == :vibeStrength) {
            var opts = new OptionMenu("Vibe Strength",
                ["50%", "75%", "100%"], [50, 75, 100],
                _view.getVibeStrength());
            WatchUi.pushView(opts, new OptionMenuDelegate(_view, _menu, :vibeStrength), WatchUi.SLIDE_LEFT);
        } else if (id == :vibePulse) {
            var opts = new OptionMenu("Vibe Pulse",
                ["50ms", "80ms", "100ms"], [50, 80, 100],
                _view.getVibePulse());
            WatchUi.pushView(opts, new OptionMenuDelegate(_view, _menu, :vibePulse), WatchUi.SLIDE_LEFT);
        } else if (id == :beatsPerBar) {
            var bpbMenu = new BeatsPerBarMenu(_view.getBeatsPerBar());
            WatchUi.pushView(bpbMenu, new BeatsPerBarMenuDelegate(_view, _menu), WatchUi.SLIDE_LEFT);
        }
    }

    function onBack() as Void {
        _view.resumeFromSettings();
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

// Reusable menu for a fixed list of labeled options
class OptionMenu extends WatchUi.Menu2 {

    function initialize(title as String, labels as Array, values as Array, currentValue as Number) {
        Menu2.initialize({:title => title});
        for (var i = 0; i < labels.size(); i++) {
            var subLabel = (values[i] == currentValue) ? "✓" : null;
            addItem(new WatchUi.MenuItem(labels[i] as String, subLabel, values[i] as Number, {}));
        }
    }
}

class OptionMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _view as MetronomeMiniView;
    private var _settingsMenu as SettingsMenu;
    private var _key as Symbol;

    function initialize(view as MetronomeMiniView, settingsMenu as SettingsMenu, key as Symbol) {
        Menu2InputDelegate.initialize();
        _view = view;
        _settingsMenu = settingsMenu;
        _key = key;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var value = item.getId() as Number;
        if (_key == :vibeStrength) {
            _view.setVibeStrength(value);
            _settingsMenu.getVibeStrengthItem().setSubLabel(value.toString() + "%");
        } else if (_key == :vibePulse) {
            _view.setVibePulse(value);
            _settingsMenu.getVibePulseItem().setSubLabel(value.toString() + "ms");
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

class BeatsPerBarMenu extends WatchUi.Menu2 {

    function initialize(currentValue as Number) {
        Menu2.initialize({:title => "Beats/Bar"});
        for (var i = 1; i <= 16; i++) {
            var subLabel = (i == currentValue) ? "✓" : null;
            addItem(new WatchUi.MenuItem(i.toString(), subLabel, i, {}));
        }
    }
}

class BeatsPerBarMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _view as MetronomeMiniView;
    private var _settingsMenu as SettingsMenu;

    function initialize(view as MetronomeMiniView, settingsMenu as SettingsMenu) {
        Menu2InputDelegate.initialize();
        _view = view;
        _settingsMenu = settingsMenu;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var value = item.getId() as Number;
        _view.setBeatsPerBar(value);
        _settingsMenu.getBeatsPerBarItem().setSubLabel(value.toString());
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

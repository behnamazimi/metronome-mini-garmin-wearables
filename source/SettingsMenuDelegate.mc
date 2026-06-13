import Toybox.Lang;
import Toybox.WatchUi;

class SettingsMenu extends WatchUi.Menu2 {

    private var _beatsPerBarItem as WatchUi.MenuItem;

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

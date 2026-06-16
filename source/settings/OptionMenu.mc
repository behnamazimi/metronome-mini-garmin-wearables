import Toybox.Lang;
import Toybox.WatchUi;

// Generic single-choice menu built from a SettingDescriptors config dictionary.
// The current value gets a check mark and initial focus.
class OptionMenu extends WatchUi.Menu2 {

    function initialize(cfg as Dictionary) {
        Menu2.initialize({:title => cfg[:title] as String});

        var labels = cfg[:labels] as Array<String>;
        var values = cfg[:values] as Array<Number>;
        var current = cfg[:current] as Number;

        var selectedIndex = 0;
        for (var i = 0; i < labels.size(); i++) {
            var sub = (values[i] == current) ? "✓" : null;
            addItem(new WatchUi.MenuItem(labels[i], sub, values[i], {}));
            if (values[i] == current) {
                selectedIndex = i;
            }
        }
        setFocus(selectedIndex);
    }
}

class OptionMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _view as MetronomeMiniView;
    private var _settingsMenu as SettingsMenu;
    private var _id as Symbol;

    function initialize(view as MetronomeMiniView, settingsMenu as SettingsMenu, id as Symbol) {
        Menu2InputDelegate.initialize();
        _view = view;
        _settingsMenu = settingsMenu;
        _id = id;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var value = item.getId() as Number;
        SettingDescriptors.apply(_id, _view, value);
        _settingsMenu.refreshItem(_id, _view);
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

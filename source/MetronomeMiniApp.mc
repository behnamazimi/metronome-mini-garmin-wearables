import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class MetronomeMiniApp extends Application.AppBase {

    private var _view as MetronomeMiniView?;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    // Stop the engine on exit so no timer/vibration/tone leaks out of the app.
    function onStop(state as Dictionary?) as Void {
        if (_view != null) {
            _view.onAppStop();
        }
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new MetronomeMiniView();
        _view = view;
        return [ view, new MetronomeMiniDelegate(view) ];
    }

}

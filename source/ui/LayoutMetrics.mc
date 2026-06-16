import Toybox.Lang;
import Toybox.Graphics;

// Single source of truth for every screen-relative position. Computed once per
// frame from the Dc. Also exposes the tap-zone width statically so the input
// delegate shares the exact same math (no more duplicated 22%).
class LayoutMetrics {

    public var width as Number;
    public var height as Number;
    public var centerX as Number;
    public var centerY as Number;

    public var sideZoneWidth as Number;
    public var buttonZoneRadius as Number;
    public var buttonRadius as Number;
    public var iconSize as Number;
    public var playIconSize as Number;

    public var bpmY as Number;
    public var tempoY as Number;
    public var labelY as Number;
    public var buttonY as Number;
    public var bpbY as Number;
    public var subdivisionIconY as Number;
    public var clockY as Number;

    function initialize(dc as Graphics.Dc) {
        width = dc.getWidth();
        height = dc.getHeight();
        centerX = width / 2;
        centerY = height / 2;

        sideZoneWidth = LayoutMetrics.tapZoneWidth(width);
        buttonZoneRadius = (height * 28) / 100;
        buttonRadius = (width * 10) / 100;
        iconSize = (width * 5) / 100;
        playIconSize = (width * 4) / 100;

        bpmY = centerY - (height * 10) / 100;
        tempoY = bpmY - (height * 16) / 100;
        labelY = centerY + (height * 8) / 100;
        buttonY = height - (height * 15) / 100;
        bpbY = (height * 10) / 100;
        // Subdivision note icon sits directly below the Beats/Bar label.
        subdivisionIconY = bpbY + (height * 5) / 100;
        clockY = labelY + (height * 11) / 100;
    }

    static function tapZoneWidth(width as Number) as Number {
        return (width * MetronomeConstants.TAP_ZONE_PCT) / 100;
    }
}

import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

// Pure drawing from a snapshot Dictionary. No timer/audio/state ownership.
// Caches the subdivision note bitmaps the first time each is needed.
class MainScreenRenderer {

    private var _iconCache as Dictionary<Number, WatchUi.BitmapResource> = {};

    function initialize() {
    }

    function draw(dc as Graphics.Dc, layout as LayoutMetrics, snapshot as Dictionary) as Void {
        var centerX = layout.centerX;
        var centerY = layout.centerY;

        // Background
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawBeatFlash(dc, layout, snapshot);
        drawSideButtons(dc, layout);
        drawBpm(dc, layout, snapshot);
        drawTime(dc, layout, snapshot);
        drawBeatsPerBar(dc, layout, snapshot);
        drawSubdivisionIcon(dc, layout, snapshot);
        drawStartStop(dc, layout, snapshot);
    }

    private function drawBeatFlash(dc as Graphics.Dc, layout as LayoutMetrics, snapshot as Dictionary) as Void {
        if (!(snapshot[:showBeat] as Boolean) || !(snapshot[:isRunning] as Boolean)) {
            return;
        }

        var flashColor;
        if (snapshot[:isDownbeat] as Boolean) {
            flashColor = Graphics.COLOR_WHITE;
        } else if (snapshot[:isSubBeat] as Boolean) {
            flashColor = 0x444444;  // subtle, dimmer ring for subdivision ticks
        } else {
            flashColor = 0x888888;
        }

        dc.setColor(flashColor, Graphics.COLOR_TRANSPARENT);
        var penWidth = (layout.width * 4) / 100;
        if (penWidth < 4) { penWidth = 4; }
        dc.setPenWidth(penWidth);
        dc.drawCircle(layout.centerX, layout.centerY, (layout.width / 2) - penWidth);
        dc.setPenWidth(1);
    }

    private function drawSideButtons(dc as Graphics.Dc, layout as LayoutMetrics) as Void {
        // "-" zone on the LEFT
        dc.setColor(0x161616, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(0, layout.centerY, layout.buttonZoneRadius);
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(layout.sideZoneWidth / 2 + 4, layout.centerY, Graphics.FONT_NUMBER_MILD, "-",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // "+" zone on the RIGHT
        dc.setColor(0x161616, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(layout.width, layout.centerY, layout.buttonZoneRadius);
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(layout.width - (layout.sideZoneWidth / 2) - 4, layout.centerY, Graphics.FONT_NUMBER_MILD, "+",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawBpm(dc as Graphics.Dc, layout as LayoutMetrics, snapshot as Dictionary) as Void {
        // BPM value
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(layout.centerX, layout.bpmY, Graphics.FONT_NUMBER_HOT, (snapshot[:bpm] as Number).toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Tempo label above the number
        dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
        dc.drawText(layout.centerX, layout.tempoY, Graphics.FONT_XTINY, snapshot[:tempoLabel] as String,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // "BPM" label below
        dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
        dc.drawText(layout.centerX, layout.labelY, Graphics.FONT_TINY, "BPM",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawTime(dc as Graphics.Dc, layout as LayoutMetrics, snapshot as Dictionary) as Void {
        var timeStr = snapshot[:timeStr];
        if (timeStr == null) {
            return;
        }
        dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
        dc.drawText(layout.centerX, layout.clockY, Graphics.FONT_XTINY, timeStr as String,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawBeatsPerBar(dc as Graphics.Dc, layout as LayoutMetrics, snapshot as Dictionary) as Void {
        var beatsPerBar = snapshot[:beatsPerBar] as Number;
        if (beatsPerBar <= 1) {
            return;
        }
        dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
        var bpbText;
        var displayBeat = snapshot[:displayBeat] as Number;
        if ((snapshot[:isRunning] as Boolean) && displayBeat > 0) {
            bpbText = displayBeat.toString() + " / " + beatsPerBar.toString();
        } else {
            bpbText = beatsPerBar.toString() + " BPB";
        }
        dc.drawText(layout.centerX, layout.bpbY, Graphics.FONT_TINY, bpbText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawSubdivisionIcon(dc as Graphics.Dc, layout as LayoutMetrics, snapshot as Dictionary) as Void {
        var subdivision = snapshot[:subdivision] as Number;
        var icon = iconFor(subdivision);
        if (icon == null) {
            return;
        }
        var x = layout.centerX - (icon.getWidth() / 2);
        dc.drawBitmap(x, layout.subdivisionIconY, icon);
    }

    private function iconFor(subdivision as Number) as WatchUi.BitmapResource? {
        if (subdivision <= MetronomeConstants.SUB_QUARTER) {
            return null;
        }
        if (_iconCache.hasKey(subdivision)) {
            return _iconCache.get(subdivision);
        }
        if (subdivision == MetronomeConstants.SUB_EIGHTH) {
            var bmp = WatchUi.loadResource(Rez.Drawables.note_eighth) as WatchUi.BitmapResource;
            _iconCache.put(subdivision, bmp);
            return bmp;
        }
        if (subdivision == MetronomeConstants.SUB_TRIPLET) {
            var bmp = WatchUi.loadResource(Rez.Drawables.note_triplet) as WatchUi.BitmapResource;
            _iconCache.put(subdivision, bmp);
            return bmp;
        }
        return null;
    }

    private function drawStartStop(dc as Graphics.Dc, layout as LayoutMetrics, snapshot as Dictionary) as Void {
        var centerX = layout.centerX;
        var buttonY = layout.buttonY;

        if (snapshot[:isRunning] as Boolean) {
            dc.setColor(0xCC0000, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(centerX, buttonY, layout.buttonRadius);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(centerX - layout.iconSize / 2, buttonY - layout.iconSize / 2,
                layout.iconSize, layout.iconSize);
        } else {
            dc.setColor(0x00AA00, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(centerX, buttonY, layout.buttonRadius);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            var px = layout.playIconSize;
            var py = (layout.playIconSize * 5) / 4;
            dc.fillPolygon([
                [centerX - px, buttonY - py],
                [centerX - px, buttonY + py],
                [centerX + px + (px / 2), buttonY]
            ]);
        }
    }
}

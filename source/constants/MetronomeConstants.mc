import Toybox.Lang;

// Central home for every magic number, id, and storage key in the app.
// Anything tunable lives here so the rest of the codebase stays declarative.
module MetronomeConstants {

    // --- Tempo ---
    const MIN_BPM as Number = 30;
    const MAX_BPM as Number = 250;
    const BPM_STEP as Number = 2;
    const DEFAULT_BPM as Number = 60;

    // --- Beats per bar ---
    const MIN_BPB as Number = 1;
    const MAX_BPB as Number = 16;
    const DEFAULT_BPB as Number = 1;

    // --- Subdivisions (ticks per beat) ---
    const SUB_QUARTER as Number = 1;
    const SUB_EIGHTH as Number = 2;
    const SUB_TRIPLET as Number = 3;
    const DEFAULT_SUBDIVISION as Number = SUB_QUARTER;

    // Guard time added on top of the longest feedback pulse so the hardware
    // (piezo beeper + vibration motor) has time to finish one tick before the
    // next one fires. This is what makes the effective BPM cap drop as the
    // subdivision count rises.
    const SUBDIVISION_GUARD_MS as Number = 25;

    // --- Beat flash ---
    const BEAT_FLASH_MS as Number = 80;

    // --- Sound modes ---
    const SOUND_OFF as Number = 0;
    const SOUND_HIGH_BEEP as Number = 1;
    const SOUND_CLICK as Number = 2;
    const SOUND_BLOCK as Number = 3;
    const SOUND_LOW_BEEP as Number = 4;
    const DEFAULT_SOUND_MODE as Number = SOUND_HIGH_BEEP;

    // --- Time display modes ---
    const TIME_OFF as Number = 0;
    const TIME_CLOCK as Number = 1;
    const TIME_ELAPSED as Number = 2;
    const DEFAULT_TIME_MODE as Number = TIME_CLOCK;

    // --- Vibration defaults ---
    const DEFAULT_VIBRATION as Boolean = true;
    const DEFAULT_VIBE_STRENGTH as Number = 75;
    const DEFAULT_VIBE_PULSE as Number = 50;

    // --- Beat event tiers ---
    const EVENT_DOWNBEAT as Number = 0;   // bar accent (beat 1 when BPB > 1)
    const EVENT_MAINBEAT as Number = 1;   // regular on-beat
    const EVENT_SUBBEAT as Number = 2;    // subdivision tick (lighter)

    // --- Layout ratios (percent of screen dimension) ---
    const TAP_ZONE_PCT as Number = 22;

    // --- Persistence ---
    const SETTINGS_VERSION as Number = 1;
    const KEY_VERSION as String = "settingsVersion";
    const KEY_BPM as String = "bpm";
    const KEY_SOUND as String = "soundMode";
    const KEY_VIBRATION as String = "vibration";
    const KEY_BPB as String = "beatsPerBar";
    const KEY_VIBE_STRENGTH as String = "vibeStrength";
    const KEY_VIBE_PULSE as String = "vibePulse";
    const KEY_TIME_MODE as String = "timeMode";
    const KEY_SUBDIVISION as String = "subdivision";
}

# Metronome Mini

A simple, minimal metronome app for Garmin wearables.

## Features

- Adjustable BPM (30–250) with live tempo label (Grave → Prestissimo)
- Visual beat flash — white ring on downbeat, gray on regular beats
- **Time signature** — configurable Beats/Bar (1–16) with accented downbeat
- **Sound effects** — Off / Beep / Click / Block, each with distinct downbeat accent
- **Vibration** — configurable strength (60/75/100%) and pulse length (50/80/100ms)

## Controls

- **Tap left zone**: Decrease BPM
- **Tap right zone**: Increase BPM
- **Tap center**: Start / Stop
- **Tap top-center** or **Menu button**: Open settings
- **UP / DOWN buttons**: Adjust BPM
- **ENTER / START button**: Start / Stop

## Settings

| Setting | Options |
|---|---|
| Sound | Off / Beep / Click / Block |
| Vibration | On / Off |
| Vibe Strength | 60% / 75% / 100% |
| Vibe Pulse | 50ms / 80ms / 100ms |
| Beats/Bar | 1–16 |

> Metronome pauses automatically while settings are open and resumes on exit.

## Supported Devices

- Forerunner 255 Music
- Forerunner 265 / 265S
- Vivoactive 4

## Development

### Prerequisites

- [Garmin Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
- Visual Studio Code with Monkey C extension

### Run on simulator

```bash
./run_on_sim.sh <product_name>
```

## License

MIT

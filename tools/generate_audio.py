"""Generate original, dependency-free chiptune music and UI/game SFX."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 22050
OUTPUT = Path(__file__).resolve().parents[1] / "assets" / "audio"
NOTE_NAMES = {"C": 0, "C#": 1, "D": 2, "D#": 3, "E": 4, "F": 5, "F#": 6, "G": 7, "G#": 8, "A": 9, "A#": 10, "B": 11}


def midi(name: str) -> int:
    note = name[:-1]
    octave = int(name[-1])
    return (octave + 1) * 12 + NOTE_NAMES[note]


def frequency(note: str) -> float:
    return 440.0 * (2.0 ** ((midi(note) - 69) / 12.0))


def oscillator(freq: float, phase: float, shape: str) -> float:
    cycle = phase % 1.0
    if shape == "square":
        return 1.0 if cycle < 0.5 else -1.0
    if shape == "pulse":
        return 1.0 if cycle < 0.28 else -1.0
    if shape == "triangle":
        return 1.0 - 4.0 * abs(cycle - 0.5)
    return math.sin(phase * math.tau)


def write_wav(path: Path, samples: list[float]) -> None:
    peak = max((abs(value) for value in samples), default=1.0)
    scale = 0.84 / peak if peak > 0.84 else 1.0
    pcm = bytearray()
    for sample in samples:
        value = int(max(-1.0, min(1.0, sample * scale)) * 32767)
        pcm.extend(struct.pack("<h", value))
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(SAMPLE_RATE)
        output.writeframes(pcm)


def note_samples(note: str, duration: float, shape: str, volume: float, decay: float = 0.0) -> list[float]:
    freq = frequency(note)
    count = round(duration * SAMPLE_RATE)
    attack = min(0.012, duration * 0.12)
    release = min(0.025, duration * 0.2)
    result = []
    for index in range(count):
        time = index / SAMPLE_RATE
        envelope = min(1.0, time / max(attack, 1e-5))
        envelope *= min(1.0, (duration - time) / max(release, 1e-5))
        envelope *= math.exp(-decay * time)
        result.append(oscillator(freq, time * freq, shape) * volume * envelope)
    return result


def append_note(track: list[float], note: str, duration: float, shape: str, volume: float, decay: float = 0.0) -> None:
    track.extend(note_samples(note, duration, shape, volume, decay))


def mix_note(track: list[float], offset: int, note: str, duration: float, shape: str, volume: float, decay: float = 0.0) -> None:
    samples = note_samples(note, duration, shape, volume, decay)
    end = min(len(track), offset + len(samples))
    for index in range(offset, end):
        track[index] += samples[index - offset]


def compose_loop(bpm: int, progressions: list[list[str]], melody: list[list[str]], bars: int) -> list[float]:
    beat = 60.0 / bpm
    track: list[float] = []
    beat_frames = round(beat * SAMPLE_RATE)
    for bar in range(bars):
        chord = progressions[bar % len(progressions)]
        phrase = melody[bar % len(melody)]
        for beat_index in range(4):
            beat_track = [0.0] * beat_frames
            root = chord[0]
            bass_note = root[:-1] + str(int(root[-1]) - 1)
            chord_note = chord[(beat_index % (len(chord) - 1)) + 1]
            next_note = phrase[(beat_index + 1) % len(phrase)]
            mix_note(beat_track, 0, bass_note, beat * 0.86, "triangle", 0.10, 0.18)
            mix_note(beat_track, 0, phrase[beat_index], beat * 0.36, "square", 0.15, 0.5)
            mix_note(beat_track, 0, chord_note, beat * 0.42, "pulse", 0.035, 0.9)
            mix_note(beat_track, round(beat_frames * 0.55), next_note, beat * 0.31, "square", 0.12, 0.5)
            mix_note(beat_track, round(beat_frames * 0.55), chord_note, beat * 0.34, "pulse", 0.03, 0.9)
            track.extend(beat_track)
    return track


def sfx_sequence(notes: list[tuple[str, float, str, float, float]]) -> list[float]:
    samples: list[float] = []
    for note, duration, shape, volume, decay in notes:
        append_note(samples, note, duration, shape, volume, decay)
    return samples


def noise_click(duration: float, volume: float, seed: int) -> list[float]:
    rng = random.Random(seed)
    count = round(duration * SAMPLE_RATE)
    return [rng.uniform(-1.0, 1.0) * volume * math.exp(-22.0 * index / SAMPLE_RATE) for index in range(count)]


def main() -> None:
    music_output = OUTPUT / "music"
    sfx_output = OUTPUT / "sfx"
    music_output.mkdir(parents=True, exist_ok=True)
    sfx_output.mkdir(parents=True, exist_ok=True)
    menu_chords = [["C4", "E4", "G4"], ["G3", "B3", "D4"], ["A3", "C4", "E4"], ["F3", "A3", "C4"]]
    menu_melody = [
        ["E5", "G5", "A5", "G5"], ["D5", "G5", "B5", "A5"],
        ["C5", "E5", "A5", "G5"], ["A4", "C5", "F5", "E5"],
    ]
    game_chords = [["D4", "F#4", "A4"], ["A3", "C#4", "E4"], ["B3", "D4", "F#4"], ["G3", "B3", "D4"]]
    game_melody = [
        ["A5", "F#5", "D5", "F#5"], ["E5", "C#5", "A4", "C#5"],
        ["F#5", "D5", "B4", "D5"], ["G5", "D5", "B4", "A4"],
    ]
    write_wav(music_output / "mus_menu.wav", compose_loop(112, menu_chords, menu_melody, 8))
    write_wav(music_output / "mus_gameplay.wav", compose_loop(132, game_chords, game_melody, 8))

    effects = {
        "sfx_shot.wav": sfx_sequence([("A5", 0.035, "square", 0.45, 18.0), ("E5", 0.06, "square", 0.24, 28.0)]) + noise_click(0.04, 0.19, 1),
        "sfx_hit.wav": sfx_sequence([("D5", 0.07, "triangle", 0.36, 1.0), ("F#5", 0.07, "triangle", 0.33, 1.0), ("A5", 0.12, "triangle", 0.3, 2.5)]),
        "sfx_miss.wav": sfx_sequence([("A4", 0.08, "triangle", 0.2, 2.0), ("E4", 0.12, "triangle", 0.15, 3.0)]),
        "sfx_escape.wav": sfx_sequence([("E5", 0.08, "square", 0.19, 4.0), ("A5", 0.12, "triangle", 0.2, 4.0)]),
        "sfx_reload.wav": noise_click(0.045, 0.3, 3) + sfx_sequence([("G4", 0.055, "square", 0.18, 15.0)]) + noise_click(0.035, 0.22, 4),
        "sfx_round_clear.wav": sfx_sequence([("D5", 0.09, "square", 0.22, 1.0), ("F#5", 0.09, "square", 0.24, 1.0), ("A5", 0.09, "square", 0.26, 1.0), ("D6", 0.28, "triangle", 0.28, 2.2)]),
        "sfx_game_over.wav": sfx_sequence([("A4", 0.18, "triangle", 0.25, 1.5), ("F4", 0.18, "triangle", 0.23, 1.5), ("D4", 0.34, "triangle", 0.2, 2.4)]),
        "sfx_button.wav": sfx_sequence([("E6", 0.045, "square", 0.12, 12.0)]),
    }
    for filename, samples in effects.items():
        write_wav(sfx_output / filename, samples)


if __name__ == "__main__":
    main()

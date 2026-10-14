pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Live audio devices and default output/input controls via Pipewire.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property var sinks: Pipewire.nodes.values.filter(n => !n.isStream && n.isSink && n.audio)
    readonly property var sources: Pipewire.nodes.values.filter(n => !n.isStream && !n.isSink && n.audio)
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real sourceVolume: source?.audio?.volume ?? 0
    readonly property bool sourceMuted: source?.audio?.muted ?? false

    function selectSink(node: PwNode): void {
        Pipewire.preferredDefaultAudioSink = node;
    }
    function selectSource(node: PwNode): void {
        Pipewire.preferredDefaultAudioSource = node;
    }
    function setSourceVolume(v: real): void {
        if (source?.audio) {
            source.audio.volume = Math.max(0, Math.min(1, v));
            source.audio.muted = v <= 0;
        }
    }
    function toggleSourceMute(): void {
        if (source?.audio)
            source.audio.muted = !source.audio.muted;
    }

    function setVolume(v: real): void {
        if (sink?.audio) {
            sink.audio.volume = Math.max(0, Math.min(1, v));
            sink.audio.muted = v <= 0;
        }
    }
    function changeVolume(delta: real): void {
        setVolume(root.volume + delta);
    }
    function toggleMute(): void {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    PwObjectTracker {
        objects: [root.sink, root.source, ...Pipewire.nodes.values.filter(n => !n.isStream)].filter(n => n)
    }
}

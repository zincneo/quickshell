pragma Singleton

import QtQuick
import Quickshell

// Live clock used across the shell.
Singleton {
    id: root

    readonly property date now: clock.date

    function fmt(format: string): string {
        return Qt.formatDateTime(clock.date, format);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}

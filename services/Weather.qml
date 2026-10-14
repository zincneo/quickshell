pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Current weather via wttr.in (Celsius). Shows city/country from the provider's
// location. For true device location (not IP), enable services.geoclue2 and set
// `coords` to "lat,lon"; the query then uses those coordinates.
Singleton {
    id: root

    property string coords: ""   // "lat,lon" to use a fixed location
    property string temp: "--"
    property string description: "Unavailable"
    property string city: ""
    property string country: ""
    property string icon: "cloud"

    readonly property string location: [city, country].filter(s => s.length > 0).join(", ")

    function reload(): void {
        proc.running = true;
    }

    function _iconFor(cond: string): string {
        const c = cond.toLowerCase();
        if (c.includes("thunder"))
            return "thunderstorm";
        if (c.includes("snow") || c.includes("sleet") || c.includes("blizzard"))
            return "weather_snowy";
        if (c.includes("rain") || c.includes("drizzle") || c.includes("shower"))
            return "rainy";
        if (c.includes("fog") || c.includes("mist") || c.includes("haze"))
            return "foggy";
        if (c.includes("overcast") || c.includes("cloud"))
            return "cloud";
        if (c.includes("sunny") || c.includes("clear"))
            return "clear_day";
        return "partly_cloudy_day";
    }

    Process {
        id: proc
        running: true
        command: ["sh", "-c", "curl -fsm 10 'wttr.in/" + root.coords + "?format=j1' || true"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text.trim())
                    return;
                try {
                    const j = JSON.parse(text);
                    const cc = j.current_condition[0];
                    root.temp = cc.temp_C + "\u00b0C";
                    root.description = cc.weatherDesc[0].value;
                    root.icon = root._iconFor(root.description);
                    const area = j.nearest_area[0];
                    root.city = area.areaName[0].value;
                    root.country = area.country[0].value;
                } catch (e) {
                    // keep previous values
                }
            }
        }
    }

    Timer {
        interval: 600000 // 10 min
        running: true
        repeat: true
        onTriggered: root.reload()
    }
}

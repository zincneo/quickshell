pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth as Bluez

// Use the same native BlueZ interface as the reference Bluetooth popout.
Singleton {
    id: root

    readonly property Bluez.BluetoothAdapter adapter: Bluez.Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool powered: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false
    readonly property bool blocked: adapter?.state === Bluez.BluetoothAdapterState.Blocked
    readonly property bool changingPower: adapter?.state === Bluez.BluetoothAdapterState.Enabling || adapter?.state === Bluez.BluetoothAdapterState.Disabling
    readonly property var devices: [...(adapter?.devices.values ?? [])].sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || (a.name || a.address).localeCompare(b.name || b.address))
    readonly property int connectedCount: devices.filter(d => d.connected).length
    readonly property string icon: !powered ? "bluetooth_disabled" : (connectedCount > 0 ? "bluetooth_connected" : "bluetooth")
    property bool ownsDiscovery: false
    property Bluez.BluetoothDevice pendingPair: null
    property string error: ""

    function setPowered(enabled: bool): void {
        if (!adapter || changingPower || blocked)
            return;
        error = "";
        if (!enabled)
            stopDiscovery();
        adapter.enabled = enabled;
    }

    function setDiscovering(enabled: bool): void {
        if (!adapter || !powered)
            return;
        error = "";
        ownsDiscovery = enabled;
        adapter.discovering = enabled;
    }

    function stopDiscovery(): void {
        if (ownsDiscovery && adapter)
            adapter.discovering = false;
        ownsDiscovery = false;
    }

    function toggleConnection(device: Bluez.BluetoothDevice): void {
        if (!powered || !device || device.pairing || device.state === Bluez.BluetoothDeviceState.Connecting || device.state === Bluez.BluetoothDeviceState.Disconnecting)
            return;
        error = "";
        if (device.connected) {
            device.connected = false;
        } else if (device.paired || device.bonded) {
            device.connected = true;
        } else if (!pendingPair) {
            pendingPair = device;
            device.pair();
        }
    }

    Connections {
        target: root.pendingPair
        function onPairedChanged(): void {
            const device = root.pendingPair;
            if (device?.paired) {
                pairResultTimer.stop();
                root.pendingPair = null;
                if (root.powered)
                    device.connected = true;
            }
        }
        function onPairingChanged(): void {
            // BlueZ may deliver the paired property just after the method reply.
            if (root.pendingPair && !root.pendingPair.pairing)
                pairResultTimer.restart();
        }
    }

    Timer {
        id: pairResultTimer
        interval: 250
        onTriggered: {
            if (root.pendingPair && !root.pendingPair.pairing && !root.pendingPair.paired) {
                root.error = "Pairing failed. Put the device in pairing mode and try again.";
                root.pendingPair = null;
            }
        }
    }
}

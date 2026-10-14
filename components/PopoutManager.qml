import QtQuick

// One panel owns the animation slot until its collapse has fully finished.
QtObject {
    id: root

    property var panels: []
    property Item currentPanel: null
    property Item pendingPanel: null
    property bool closing: false
    property bool blocked: false
    property bool updating: false

    onBlockedChanged: update(null)
    onPanelsChanged: update(null)

    function update(source): void {
        if (updating) {
            Qt.callLater(root.update, null);
            return;
        }
        updating = true;
        try {
            // Replace the queued request as the pointer moves between panels.
            // Hover changes on the outgoing panel never override that request.
            if (source && source !== currentPanel && source.requestedOpen)
                pendingPanel = source;
            else if (source === pendingPanel && source && !source.requestedOpen)
                pendingPanel = null;

            if (blocked) {
                pendingPanel = null;
                if (currentPanel) {
                    closing = true;
                    if (currentPanel.fullyClosed) {
                        currentPanel = null;
                        closing = false;
                    }
                }
                return;
            }

            if (currentPanel) {
                if (!closing && (!currentPanel.requestedOpen || (pendingPanel && pendingPanel !== currentPanel && pendingPanel.requestedOpen)))
                    closing = true;

                if (!closing || !currentPanel.fullyClosed)
                    return;

                currentPanel = null;
                closing = false;
            }

            const next = pendingPanel?.requestedOpen ? pendingPanel : panels.find(panel => panel && panel.requestedOpen);
            pendingPanel = null;
            if (next)
                currentPanel = next;
        } finally {
            updating = false;
        }
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// niri workspaces + windows via its JSON IPC event stream.
Singleton {
    id: root

    property var workspaces: []   // raw: {id, idx, name, output, isActive, isFocused}
    property var windows: []      // {id, appId, title, workspaceId, isFocused}
    property int focusedId: -1

    // Workspaces augmented with a live window count, sorted by output then idx.
    readonly property var wsList: workspaces.map(w => Object.assign({}, w, {
                count: windows.filter(x => x.workspaceId === w.id).length
            })).sort((a, b) => a.output === b.output ? a.idx - b.idx : String(a.output).localeCompare(String(b.output)))
    readonly property var focusedWindow: windows.find(w => w.isFocused) ?? null

    // Windows on a workspace in layout order (column, then tile); floating windows last.
    function windowsOn(wsId: int): var {
        return windows.filter(w => w.workspaceId === wsId).sort((a, b) => {
            if (!a.pos && !b.pos)
                return a.id - b.id;
            if (!a.pos)
                return 1;
            if (!b.pos)
                return -1;
            return a.pos[0] - b.pos[0] || a.pos[1] - b.pos[1];
        });
    }

    function switchTo(idx: int): void {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(idx)]);
    }

    function focusWindow(id: int): void {
        Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", String(id)]);
    }

    function _mapWs(list: var): var {
        return list.map(w => ({
                    id: w.id,
                    idx: w.idx,
                    name: w.name,
                    output: w.output,
                    isActive: w.is_active,
                    isFocused: w.is_focused
                }));
    }

    function _mapWin(w: var): var {
        return {
            id: w.id,
            appId: w.app_id ?? "",
            title: w.title ?? "",
            workspaceId: w.workspace_id ?? -1,
            isFocused: w.is_focused ?? false,
            pos: w.layout?.pos_in_scrolling_layout ?? null
        };
    }

    Process {
        running: true
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
            onRead: line => {
                if (!line.trim())
                    return;
                try {
                    const ev = JSON.parse(line);
                    if (ev.WorkspacesChanged) {
                        root.workspaces = root._mapWs(ev.WorkspacesChanged.workspaces);
                        const f = root.workspaces.find(w => w.isFocused);
                        if (f)
                            root.focusedId = f.id;
                    } else if (ev.WorkspaceActivated) {
                        const id = ev.WorkspaceActivated.id;
                        root.focusedId = id;
                        const out = root.workspaces.find(w => w.id === id)?.output;
                        root.workspaces = root.workspaces.map(w => Object.assign({}, w, {
                                    isFocused: w.id === id,
                                    isActive: w.output === out ? w.id === id : w.isActive
                                }));
                    } else if (ev.WindowsChanged) {
                        root.windows = ev.WindowsChanged.windows.map(root._mapWin);
                    } else if (ev.WindowOpenedOrChanged) {
                        const win = root._mapWin(ev.WindowOpenedOrChanged.window);
                        const rest = root.windows.filter(w => w.id !== win.id);
                        if (win.isFocused)
                            rest.forEach(w => w.isFocused = false);
                        root.windows = [...rest, win];
                    } else if (ev.WindowClosed) {
                        root.windows = root.windows.filter(w => w.id !== ev.WindowClosed.id);
                    } else if (ev.WindowFocusChanged) {
                        const id = ev.WindowFocusChanged.id;
                        root.windows = root.windows.map(w => Object.assign({}, w, {
                                    isFocused: w.id === id
                                }));
                    }
                } catch (e) {}
            }
        }
    }
}

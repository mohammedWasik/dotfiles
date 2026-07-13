#!/usr/bin/env python3
import json
import subprocess
import sys

try:
    # Get tree to find all windows and focused window
    tree = json.loads(subprocess.check_output(["i3-msg", "-t", "get_tree"]).decode())
    
    # Default emoji icon mapping (simple and universal)
    icons = {
        "google-chrome": "🌐",
        "chrome": "🌐",
        "google-chrome-stable": "🌐",
        "chromium": "🌐",
        "alacritty": "💻",
        "terminator": "💻",
        "gnome-terminal": "💻",
        "urxvt": "💻",
        "cursor": "📝",
        "code": "📝",
        "vscode": "📝",
        "firefox": "🦊",
        "thunar": "📁",
        "nautilus": "📁",
        "pcmanfm": "📁",
        "org.gnome.nautilus": "📁",
        "gedit": "📄",
        "kate": "📄",
        "pluma": "📄",
        "gimp": "🎨",
        "inkscape": "🎨",
        "libreoffice": "📊",
        "discord": "💬",
        "telegram": "📱",
        "slack": "💼",
        "spotify": "🎵",
        "vlc": "🎬",
        "mpv": "🎬",
    }
    
    def find_focused_window_id(node):
        """Find the ID of the focused window"""
        if "focused" in node and node.get("focused"):
            if "window_properties" in node:
                return node.get("id")
        if "nodes" in node:
            for child in node["nodes"]:
                result = find_focused_window_id(child)
                if result:
                    return result
        if "floating_nodes" in node:
            for child in node["floating_nodes"]:
                result = find_focused_window_id(child)
                if result:
                    return result
        return None
    
    def find_all_windows(node, focused_id=None):
        """Find all windows across all workspaces"""
        windows = []
        
        if "window_properties" in node:
            props = node["window_properties"]
            class_name = props.get("class", "").lower()
            if class_name:
                window_id = node.get("id")
                is_focused = (window_id == focused_id) if focused_id else False
                windows.append({
                    "class": class_name,
                    "id": window_id,
                    "focused": is_focused
                })
        
        # Recursively check children
        if "nodes" in node:
            for child in node["nodes"]:
                windows.extend(find_all_windows(child, focused_id))
        
        if "floating_nodes" in node:
            for child in node["floating_nodes"]:
                windows.extend(find_all_windows(child, focused_id))
        
        return windows
    
    # Find focused window ID
    focused_window_id = find_focused_window_id(tree)
    
    # Get all windows
    all_windows = find_all_windows(tree, focused_window_id)
    
    if not all_windows:
        print("")
        print("")
        sys.exit(0)
    
    # Build output: icons on top line, dots on bottom line
    icon_parts = []
    dot_parts = []
    
    for w in all_windows:
        class_name = w["class"]
        
        # Use default emoji icon
        icon = icons.get(class_name, "◻")
        
        icon_parts.append(icon)
        
        # Add dot if focused, space if not
        if w.get("focused"):
            dot_parts.append("●")
        else:
            dot_parts.append(" ")
    
    # Format as two lines with newline
    icon_line = " ".join(icon_parts)
    dot_line = " ".join(dot_parts)
    
    # Print both lines with newline separator
    output = f"{icon_line}\n{dot_line}\n"
    print(output)
    
except Exception as e:
    # Silent fail
    print("")
    print("")

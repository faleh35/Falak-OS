// Mac-like view.
// Top bar:  [menu] [global app menu] ......... [app grid] [tray] [clock]
// Dock:     floating, centered, transparent; icons magnify under the pointer
//           (Falak Dock). Falls back to the standard icon task manager.
// Window buttons go on the LEFT (set in layouts/defaults); minimizing uses the
// Magic Lamp effect (set by falak-appearance).

var LAUNCHERS = [
    "preferred://filemanager",
    "preferred://browser",
    "applications:org.kde.konsole.desktop",
    "applications:systemsettings.desktop"
];

var DOCK_WIDGET = "com.github.mattanis.macosdock";

function has(plugin) {
    return knownWidgetTypes.indexOf(plugin) !== -1;
}

function add(panel, plugin) {
    if (!has(plugin)) {
        print("Falak: widget not installed, skipping: " + plugin);
        return null;
    }
    return panel.addWidget(plugin);
}

function configure(widget, group, key, value) {
    if (!widget) {
        return;
    }
    widget.currentConfigGroup = group;
    widget.writeConfig(key, value);
}

function setWallpaper(name) {
    var desktops = desktopsForActivity(currentActivity());
    for (var i = 0; i < desktops.length; i++) {
        desktops[i].wallpaperPlugin = "org.kde.image";
        desktops[i].currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
        desktops[i].writeConfig("Image", "file:///usr/share/wallpapers/" + name + "/");
    }
}

// ---- Top bar ----
var topBar = new Panel;
topBar.location = "top";
topBar.height = Math.round(gridUnit * 1.6);
topBar.floating = false;
topBar.lengthMode = "fill";
topBar.hiding = "none";

var menu = add(topBar, "org.kde.plasma.kickoff");
configure(menu, ["General"], "icon", "falak-logo");

add(topBar, "org.kde.plasma.appmenu");
add(topBar, "org.kde.plasma.panelspacer");

// Full-screen app grid, like Launchpad.
var grid = add(topBar, "org.kde.plasma.kickerdash");
configure(grid, ["General"], "icon", "view-app-grid-symbolic");

add(topBar, "org.kde.plasma.systemtray");
add(topBar, "org.kde.plasma.digitalclock");

// ---- Dock ----
var dock = new Panel;
dock.location = "bottom";
dock.floating = true;
dock.alignment = "center";
dock.lengthMode = "fit";
dock.hiding = "dodgewindows";

if (has(DOCK_WIDGET)) {
    // Extra height gives the icons room to grow; the dock adjusts it itself.
    dock.height = Math.round(gridUnit * 5.5);
    var falakDock = dock.addWidget(DOCK_WIDGET);
    falakDock.currentConfigGroup = ["General"];
    falakDock.writeConfig("launchers", LAUNCHERS);
    falakDock.writeConfig("zoomEnabled", true);
    falakDock.writeConfig("zoomMultiplier", 1.7);
    falakDock.writeConfig("zoomBlastRadius", 2);
    falakDock.writeConfig("hoverElevation", 12);
    falakDock.writeConfig("zoomAnimationType", 0); // spring, like macOS
    falakDock.writeConfig("containerBackgroundType", 2); // translucent glass
    falakDock.writeConfig("autoAdjustPanelThickness", true);
} else {
    // Fallback: the standard dock without magnification.
    dock.height = 2 * Math.ceil(gridUnit * 3.2 / 2);
    var tasks = add(dock, "org.kde.plasma.icontasks");
    configure(tasks, ["General"], "launchers", LAUNCHERS);
    add(dock, "org.kde.plasma.marginsseparator");
    add(dock, "org.kde.plasma.trash");
}

setWallpaper("Falak");

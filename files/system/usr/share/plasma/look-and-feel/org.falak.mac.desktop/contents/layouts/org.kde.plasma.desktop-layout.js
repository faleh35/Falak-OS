// Mac-like view.
// Top bar:  [menu] [global app menu] ............ [tray] [clock]
// Dock:     floating, centered, fits its icons; moves away from windows.
// Window buttons go on the LEFT (set in layouts/defaults).

var LAUNCHERS = [
    "preferred://filemanager",
    "preferred://browser",
    "applications:org.kde.konsole.desktop",
    "applications:systemsettings.desktop"
];

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
add(topBar, "org.kde.plasma.systemtray");
add(topBar, "org.kde.plasma.digitalclock");

// ---- Dock ----
var dock = new Panel;
dock.location = "bottom";
dock.height = 2 * Math.ceil(gridUnit * 3.2 / 2);
dock.floating = true;
dock.alignment = "center";
dock.lengthMode = "fit";
dock.hiding = "dodgewindows";

// Full-screen app grid, like Launchpad.
var grid = add(dock, "org.kde.plasma.kickerdash");
configure(grid, ["General"], "icon", "view-app-grid-symbolic");

var tasks = add(dock, "org.kde.plasma.icontasks");
configure(tasks, ["General"], "launchers", LAUNCHERS);

add(dock, "org.kde.plasma.marginsseparator");
add(dock, "org.kde.plasma.trash");

setWallpaper("Falak");

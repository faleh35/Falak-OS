// Windows-like view.
// One full-width taskbar at the bottom, Start menu + apps centered:
//   ..... [Start] [pinned + open apps] ..... [tray] [clock] [show desktop]
// Window buttons on the RIGHT (set in layouts/defaults).

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

var taskbar = new Panel;
taskbar.location = "bottom";
taskbar.height = 2 * Math.ceil(gridUnit * 2.5 / 2);
taskbar.floating = false;
taskbar.lengthMode = "fill";
taskbar.hiding = "none";

// The two flexible spacers keep Start + apps in the middle.
add(taskbar, "org.kde.plasma.panelspacer");

var start = add(taskbar, "org.kde.plasma.kickoff");
configure(start, ["General"], "icon", "falak-logo");

var tasks = add(taskbar, "org.kde.plasma.icontasks");
configure(tasks, ["General"], "launchers", LAUNCHERS);

add(taskbar, "org.kde.plasma.panelspacer");
add(taskbar, "org.kde.plasma.systemtray");
add(taskbar, "org.kde.plasma.digitalclock");
add(taskbar, "org.kde.plasma.showdesktop");

setWallpaper("Falak");

// Falak view: Falak's own signature layout.
// One floating, centered "orbit bar" at the bottom:
//   [menu] [workspaces] [pinned + open apps] | [tray] [clock]

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

var bar = new Panel;
bar.location = "bottom";
bar.height = 2 * Math.ceil(gridUnit * 2.4 / 2);
bar.floating = true;
bar.alignment = "center";
bar.lengthMode = "fit";
bar.hiding = "none";

var menu = add(bar, "org.kde.plasma.kickoff");
configure(menu, ["General"], "icon", "falak-logo");

add(bar, "org.kde.plasma.pager");

var tasks = add(bar, "org.kde.plasma.icontasks");
configure(tasks, ["General"], "launchers", LAUNCHERS);

add(bar, "org.kde.plasma.marginsseparator");
add(bar, "org.kde.plasma.systemtray");
add(bar, "org.kde.plasma.digitalclock");

setWallpaper("Falak");

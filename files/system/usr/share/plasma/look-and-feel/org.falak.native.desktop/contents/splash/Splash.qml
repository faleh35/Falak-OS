/*
 * FalakOS loading screen (KSplash), shown between login and the desktop.
 * A planet with a moon on its orbit, the FalakOS name, the tagline, and a
 * thin progress line that fills as Plasma starts.
 *
 * Only QtQuick is used, so it keeps working across Plasma updates.
 * SPDX-License-Identifier: Apache-2.0
 */

import QtQuick

Rectangle {
    id: root
    color: "#0A0E26"

    // Set by KSplash as Plasma starts up (1 ... 6).
    property int stage: 0

    readonly property bool arabic: Qt.locale().name.substring(0, 2) === "ar"
    readonly property real progress: Math.min(Math.max(stage, 1) / 6, 1)
    readonly property real unit: Math.max(Math.min(width, height) / 1080, 0.5)

    // Wallpaper, dimmed so the logo stands out.
    Image {
        anchors.fill: parent
        source: "file:///usr/share/wallpapers/Falak/contents/images_dark/3840x2160.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: false
        sourceSize.width: 1920
        sourceSize.height: 1080
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.04, 0.05, 0.15, 0.88) }
            GradientStop { position: 1.0; color: Qt.rgba(0.09, 0.06, 0.22, 0.94) }
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0

        // ---- the orbit: a moon travels around the planet ----
        Item {
            id: orbitBox
            width: 300 * root.unit
            height: 300 * root.unit
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -70 * root.unit
            rotation: -25

            property real angle: 0
            readonly property real rx: width / 2 - 8 * root.unit
            readonly property real ry: rx * 0.34

            NumberAnimation on angle {
                from: 0
                to: Math.PI * 2
                duration: 2600
                loops: Animation.Infinite
                running: true
            }

            // Orbit ring.
            Canvas {
                id: ring
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.strokeStyle = "rgba(245, 185, 66, 0.55)";
                    ctx.lineWidth = Math.max(2, 3 * root.unit);
                    ctx.beginPath();
                    ctx.ellipse(width / 2 - orbitBox.rx, height / 2 - orbitBox.ry,
                                orbitBox.rx * 2, orbitBox.ry * 2);
                    ctx.stroke();
                }
                onWidthChanged: requestPaint()
            }

            // Moon behind the planet (top half of the orbit).
            Rectangle {
                id: moonBack
                visible: Math.sin(orbitBox.angle) < 0
                width: 18 * root.unit
                height: width
                radius: width / 2
                color: "#F5B942"
                x: orbitBox.width / 2 + orbitBox.rx * Math.cos(orbitBox.angle) - width / 2
                y: orbitBox.height / 2 + orbitBox.ry * Math.sin(orbitBox.angle) - height / 2
                opacity: 0.75
            }

            // Planet (from the FalakOS logo colors).
            Rectangle {
                id: planet
                width: 128 * root.unit
                height: width
                radius: width / 2
                anchors.centerIn: parent
                rotation: 25
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#3EE0C8" }
                    GradientStop { position: 1.0; color: "#1D3B8F" }
                }
                // Soft highlight.
                Rectangle {
                    width: parent.width * 0.42
                    height: width
                    radius: width / 2
                    x: parent.width * 0.16
                    y: parent.height * 0.12
                    color: Qt.rgba(1, 1, 1, 0.16)
                }
            }

            // Moon in front of the planet (bottom half of the orbit).
            Rectangle {
                visible: !moonBack.visible
                width: moonBack.width
                height: width
                radius: width / 2
                color: "#F5B942"
                x: orbitBox.width / 2 + orbitBox.rx * Math.cos(orbitBox.angle) - width / 2
                y: orbitBox.height / 2 + orbitBox.ry * Math.sin(orbitBox.angle) - height / 2
            }
        }

        // ---- name and tagline ----
        Column {
            anchors.top: orbitBox.bottom
            anchors.topMargin: -30 * root.unit
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12 * root.unit

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "FalakOS"
                color: "#F2F4FF"
                font.family: "Inter"
                font.pixelSize: 54 * root.unit
                font.weight: Font.DemiBold
                font.letterSpacing: 1
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.arabic ? "كُلٌّ فِي فَلَكٍ يَسْبَحُونَ" : "All in an orbit are swimming."
                color: "#F5B942"
                font.family: root.arabic ? "Amiri" : "Inter"
                font.pixelSize: (root.arabic ? 30 : 22) * root.unit
                font.italic: !root.arabic
            }

            Item { width: 1; height: 26 * root.unit }

            // Progress line.
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 220 * root.unit
                height: 4 * root.unit
                radius: height / 2
                color: Qt.rgba(1, 1, 1, 0.14)

                Rectangle {
                    height: parent.height
                    radius: height / 2
                    width: parent.width * root.progress
                    color: "#3EE0C8"
                    Behavior on width {
                        NumberAnimation { duration: 450; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }

    // Fade in as soon as the splash appears, and out at the end.
    OpacityAnimator {
        id: fadeIn
        target: content
        from: 0
        to: 1
        duration: 700
        easing.type: Easing.OutQuad
        running: true
    }

    OpacityAnimator {
        id: fadeOut
        target: content
        from: 1
        to: 0
        duration: 400
        easing.type: Easing.InQuad
        running: false
    }

    onStageChanged: {
        if (stage >= 6) {
            fadeOut.running = true;
        }
    }
}

/************************************************************************************
 * Copyright (C) 2015 Aleix Pol Gonzalez <aleixpol@blue-systems.com>                *
 *                                                                                  *
 * This program is free software; you can redistribute it and/or                    *
 * modify it under the terms of the GNU General Public License                      *
 * as published by the Free Software Foundation; either version 2                   *
 * of the License, or (at your option) any later version.                           *
 *                                                                                  *
 * This program is distributed in the hope that it will be useful,                  *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of                   *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                    *
 * GNU General Public License for more details.                                     *
 *                                                                                  *
 * You should have received a copy of the GNU General Public License                *
 * along with this program; if not, write to the Free Software                      *
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA   *
 ************************************************************************************/

import QtQuick 2.5
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import KamosoQtGStreamer 1.0
import org.kde.kirigami 2.9 as Kirigami
import org.kde.kamoso 3.0

Kirigami.ApplicationWindow
{
    id: root
    visible: true
    title: i18n("Kamoso")
    pageStack.globalToolBar.toolbarActionAlignment: Qt.AlignCenter
    minimumWidth: 320
    minimumHeight: 240 + pageStack.globalToolBar.height
    Component.onCompleted: {
        width = 700
        height = width*3/4
    }

    function awesomeAnimation(path) {
//         tada.x = visor.x
//         tada.y = 0
//         tada.width = visor.width
//         tada.height = visor.height
        tada.source = "file://"+path
        tada.state = "go"
        tada.state = "done"
//         tada.visible = true

    }

    Connections {
        target: webcam
        function onError(error) { showPassiveNotification(error) }
    }

    Image {
        id: tada
        z: 10
        width: 10
        height: 10
        fillMode: Image.PreserveAspectFit

        states: [
            State { name: "go"
                PropertyChanges { target: tada; x: visor.x }
                PropertyChanges { target: tada; y: visor.y }
                PropertyChanges { target: tada; width: visor.width }
                PropertyChanges { target: tada; height: visor.height }
            },
            State { name: "done"
                PropertyChanges { target: tada; x: root.width }
                PropertyChanges { target: tada; y: root.height }
                PropertyChanges { target: tada; width: Kirigami.Units.gridUnit }
                PropertyChanges { target: tada; height: Kirigami.Units.gridUnit }
            }
        ]
        transitions: [
            Transition {
                from: "go"; to: "done"
                    NumberAnimation { target: tada
                                properties: "width,height"; duration: 700; easing.type: Easing.InCubic }
                    NumberAnimation { target: tada
                                properties: "x,y"; duration: 700; easing.type: Easing.InCubic }
            }
        ]
    }

    Mode {
        id: photoMode
        mimes: "image/jpeg"
        checkable: false
        iconName: "camera-photo-symbolic"
        text: i18n("Take a Picture")
        nameFilter: "picture_*"

        onTriggered: {
            whites.showAll()
            webcam.takePhoto()
        }

        Connections {
            target: webcam
            function onPhotoTaken(path) { awesomeAnimation(path) }
        }
    }

    Binding {
        target: webcam
        property: "mirrored"
        value: config.mirrored
    }

    Mode {
        id: burstMode
        mimes: "image/jpeg"
        checkable: true
        iconName: checked ? "media-playback-stop" : "burst"
        text: checked? i18n("End Burst") : i18n("Capture a Burst")
        property int photosTaken: 0
        modeInfo:  photosTaken > 0 ? i18np("1 photo taken", "%1 photos taken", photosTaken) : ""
        nameFilter: "picture_*"
        enabled: !videoMode.checked
        onCheckedChanged: if (checked) {
            photosTaken = 0
        }

        readonly property var smth: Timer {
            id: burstTimer
            running: burstMode.checked
            interval: 2500
            repeat: true
            onTriggered: {
                webcam.takePhoto()
                burstMode.photosTaken++;
            }
        }
    }
    Mode {
        id: videoMode
        mimes: "video/x-matroska"
        checkable: true
        iconName: checked ? "media-playback-stop" : "camera-video-symbolic"
        text: checked? i18n("Stop Recording") : i18n("Record a Video")
        modeInfo: webcam.recordingTime
        nameFilter: "video_*"
        enabled: !burstMode.checked

        onCheckedChanged: {
            webcam.isRecording = checked;
        }
    }

    contextDrawer: Kirigami.OverlayDrawer {
        edge: Qt.RightEdge
        drawerOpen: false
        handleVisible: true
        handleClosedIcon.source: "configure"
        modal: true

        leftPadding: 0
        topPadding: 0
        rightPadding: 0
        bottomPadding: 0

        contentItem: ImagesView {
            implicitWidth: Kirigami.Units.gridUnit * 20
            mimeFilter: root.pageStack.currentItem.actions.main.mimes
            nameFilter: root.pageStack.currentItem.actions.main.nameFilter
        }
    }

    globalDrawer: Kirigami.OverlayDrawer {
        edge: Qt.LeftEdge
        drawerOpen: false
        handleVisible: true
        handleClosedIcon.source: "special-effects-symbolic"
        handleOpenIcon.source: "view-left-close"
        modal: true
        width: Kirigami.Units.gridUnit * 20

        leftPadding: Kirigami.Units.smallSpacing
        topPadding: Kirigami.Units.smallSpacing
        rightPadding: Kirigami.Units.smallSpacing
        bottomPadding: Kirigami.Units.smallSpacing

        contentItem: Config {
            id: configView

            QQC2.ScrollBar.vertical: QQC2.ScrollBar {}

            header: QQC2.Control {
                height: effectsGalleryHeading.height + Kirigami.Units.largeSpacing
                Kirigami.Heading {
                    id: effectsGalleryHeading
                    level: 1
                    color: Kirigami.Theme.textColor
                    elide: Text.ElideRight
                    text: i18n("Effects Gallery")
                }
            }
        }
    }

    Shortcut {
        sequence: "Return"
        onActivated: visor.actions.main.triggered(null)
    }

    pageStack.initialPage: Kirigami.Page {
        id: visor
        bottomPadding: 0
        topPadding: 0
        rightPadding: 0
        leftPadding: 0

        actions {
            left: videoMode
            main: photoMode
            right: burstMode
        }

        Rectangle {
            anchors.fill: parent
            color: "black"
            z: -1
        }

        VideoItem {
            surface: videoSurface1
            anchors.fill: parent
        }

        Text {
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                margins: 20
            }

            text: videoMode.checked ? videoMode.modeInfo : burstMode.checked ? burstMode.modeInfo : ""
            color: "white"
            styleColor: "black"
            font.pointSize: 20

            style: Text.Outline
        }
    }
}

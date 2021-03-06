/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0

Item {
    id: delegate
    scale: PathView.itemScale
    opacity: PathView.itemOpacity

    z: PathView.z
    property var current: model.current
    property int deleteDialogOpenedAtIndex: mainView.deleteDialogOpenedAtIndex
    property int delegateIndex: index

    onDeleteDialogOpenedAtIndexChanged: {
        // if necessary close this ActivityDelegate's deleteDialog if a deleteDialog from another ActivityDelegate has been opened.
        if (deleteDialogOpenedAtIndex != index && deleteButtonParent.confirmationDialog != null) {
            deleteButtonParent.confirmationDialog.scale = 0
            deleteButtonParent.confirmationDialog.destroy()
            deleteButtonParent.confirmationDialog = null

            // restore this ActivityDelegate's opacity to the value before this ActivityDelegate's deleteDialog had been opened.
            deleteButton.checked = false
        }
    }

    onCurrentChanged: {
        //avoid to restart the timer if the current index is already correct
        if (current  && highlightTimer.pendingIndex != index) {
            highlightTimer.pendingIndex = index
            console.log(highlightTimer.pendingIndex)
            highlightTimer.running = true
        }
    }
    Component.onCompleted: {
        if (current == "true") {
            highlightTimer.pendingIndex = index
            highlightTimer.running = true
        }
    }

    width: mainView.delegateWidth
    height: mainView.delegateHeight

    transform: Translate {
        x: delegate.PathView.itemXTranslate
        y: delegate.PathView.itemYTranslate
    }

    PlasmaCore.FrameSvgItem {
        id: activityBorder
        imagePath: "widgets/media-delegate"
        prefix: model.current == true ? "picture-selected" : "picture"

        anchors.fill:parent
        anchors.rightMargin: 100

        Image {
            id: wallpaperThumbnail
            anchors {
                fill: parent
                leftMargin: parent.margins.left
                topMargin: parent.margins.top
                rightMargin: parent.margins.right
                bottomMargin: parent.margins.bottom
            }

            //Check if the background is actually an image instead of a color
            source: model.background[0] != "#" ? model.background  : ""

            Image {
                anchors.fill: parent

                source: "plasmapackage:/images/emptyactivity.png"
                visible: String(wallpaperThumbnail.source).length == 0
                onVisibleChanged: {
                    if (!visible) {
                        destroy()
                    }
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                height: activityName.height * 2
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: Qt.rgba(0, 0, 0, 0.6)
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.rgba(0, 0, 0, 0)
                    }
                }
            }
            PlasmaComponents.Label {
                id: activityName
                anchors {
                    top: parent.top
                    left: parent.left
                    leftMargin: 10
                    topMargin: 10
                }

                text: (String(model.name).length <= 18) ? model.name:String(model.name).substr(0,18) + "..."
                color: "white"
                style: Text.Raised
                renderType: Text.QtRendering
                font.pointSize: theme.defaultFont.pointSize * 2
                font.weight: Font.Light
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            activitiesSource.setCurrentActivity(model.id, function() {})
        }
    }

    Row {
        anchors {
            bottom: activityBorder.bottom
            left: activityBorder.left
            bottomMargin: activityBorder.margins.bottom + 13
            leftMargin: activityBorder.margins.left
        }
        spacing: 8

        enabled: delegate.scale > 0.4
        Item {
            id: deleteButtonParent
            width: iconSize
            height: iconSize
            z: 900
            //TODO: load on demand of the qml file
            Component {
                id: confirmationDialogComponent
                ConfirmationDialog {
                    enabled: true
                    z: 700
                    transformOrigin: Item.BottomLeft
                    question: i18n("Do you want to permanently delete activity '%1'?", activityName.text)
                    onAccepted: {
                        deleteTimer.activityId = model.id
                        deleteTimer.running = true
                    }
                    onDismissed: {
                        deleteButton.checked = false
                    }
                }
            }
            property ConfirmationDialog confirmationDialog
            PlasmaComponents.ToolButton {
                id: deleteButton
                iconSource: "list-delete"
                checkable: true
                width: units.iconSizes.large
                height: width
                opacity: model.current == true ? 0.4 : 1
                enabled: opacity == 1
                z: 800
                property double oldOpacity: delegate.PathView.itemOpacity

                onCheckedChanged: {
                    if (checked) {
                        oldOpacity = delegate.PathView.itemOpacity
                        delegate.PathView.itemOpacity = 1

                        // closes all other deleteDialogs from other ActivityDelegates.
                        delegate.parent.deleteDialogOpenedAtIndex = delegate.delegateIndex

                        if (!deleteButtonParent.confirmationDialog) {
                            deleteButtonParent.confirmationDialog = confirmationDialogComponent.createObject(deleteButtonParent)
                        }

                        deleteButtonParent.confirmationDialog.scale = 1

                        deleteButtonParent.confirmationDialog.anchors.bottom = deleteButton.verticalCenter
                        deleteButtonParent.confirmationDialog.x = Math.round(width/2);
                    } else {
                        delegate.PathView.itemOpacity = oldOpacity
                        deleteButtonParent.confirmationDialog.scale = 0
                    }
                }
            }
        }
    }
}

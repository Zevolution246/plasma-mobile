/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import QtQuick 1.0
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as MobileComponents
import org.kde.metadatamodels 0.1 as MetadataModels

Sheet {
    id: widgetsExplorer
    objectName: "widgetsExplorer"
    title: i18n("Add items")

    signal addAppletRequested(string plugin)
    signal closeRequested


    onAccepted: {
        stack.currentPage.accept()
    }
    onStatusChanged: {
        if (status == PlasmaComponents.DialogStatus.Closed) {
            closeRequested()
        }
    }

    ListModel {
        id: selectedModel
    }

    MetadataModels.MetadataUserTypes {
        id: userTypes
    }

    MetadataModels.MetadataCloudModel {
        id: cloudModel
        cloudCategory: "rdf:type"
        allowedCategories: userTypes.userTypes
    }

    PlasmaCore.DataSource {
        id: activitySource
        engine: "org.kde.activities"
        connectedSources: ["Status"]
        interval: 0
    }

    Component.onCompleted: open()

    content: [
        MobileComponents.ViewSearch {
            id: searchField
            MobileComponents.IconButton {
                icon: QIcon("go-previous")
                width: 32
                height: 32
                onClicked: {
                    searchField.searchQuery = ""
                    stack.pop()
                }
                opacity: stack.depth > 1 ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            onSearchQueryChanged: {
                if (stack.depth == 1 && searchQuery != "") {
                    stack.push(globalSearchComponent)
                }
            }
        },
        PlasmaComponents.PageStack {
            id: stack
            clip: true
            anchors {
                left: parent.left
                right: parent.right
                top: searchField.bottom
                bottom: parent.bottom
            }
            initialPage: Qt.createComponent("Menu.qml")
        }
    ]

    Component {
        id: globalSearchComponent
        ResourceBrowser {
            model: PlasmaCore.DataModel {
                keyRoleFilter: ".*"
                dataSource: PlasmaCore.DataSource {
                    engine: "org.kde.runner"
                    interval: 0
                    connectedSources: [searchField.searchQuery]
                }
            }
        }
    }
}

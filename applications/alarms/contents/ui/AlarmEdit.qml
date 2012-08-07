/*
 *   Copyright 2012 Marco Martin <mart@kde.org>
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

import QtQuick 1.1
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1 as PlasmaComponents
import org.kde.plasma.extras 0.1 as PlasmaExtras
import org.kde.locale 0.1 as KLocale
import org.kde.qtextracomponents 0.1

Item {
    id: alarmEditRoot

    Column {
        spacing: 8
        anchors.centerIn: parent

        Grid {
            spacing: 8
            anchors.horizontalCenter: parent.horizontalCenter
            rows: 3
            columns: 2

            PlasmaComponents.Label {
                anchors {
                    right: messageArea.left
                    rightMargin: 4
                }
                text: i18n("Message:")
            }
            PlasmaComponents.TextArea {
                id: messageArea
                width: alarmEditRoot.width / 2
                height: theme.defaultFont.mSize.height * 5
            }

            PlasmaComponents.Label {
                anchors {
                    right: repeatSwitch.left
                    rightMargin: 4
                }
                text: i18n("Repeat daily:")
            }
            PlasmaComponents.Switch {
                id: repeatSwitch
            }

            PlasmaComponents.Label {
                anchors {
                    right: audioSwitch.left
                    rightMargin: 4
                }
                text: i18n("Audio:")
            }
            PlasmaComponents.Switch {
                id: audioSwitch
                checked: true
            }
        }
        Row {
            spacing: 8
            anchors.horizontalCenter: parent.horizontalCenter
            PlasmaComponents.Button {
                text: i18n("Save")
            }
            PlasmaComponents.Button {
                text: i18n("Cancel")
            }
        }
    }
}

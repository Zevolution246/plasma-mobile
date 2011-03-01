/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 1.0
import org.kde.plasma.core 0.1 as PlasmaCore


Item {
    id: extraActionsButtonPlaceHolder
    width: actionSize
    height: actionSize

    PlasmaCore.FrameSvgItem {
            id: extraActionsFrame
            x: -placeHolder.x
            y: -margins.top
            width: layout.width+margins.left+margins.right
            height: layout.height+margins.top
            imagePath: "widgets/background"
            enabledBorders: "LeftBorder|RightBorder|TopBorder"
            opacity: 0

            Behavior on opacity {
                NumberAnimation { duration: 250 }
            }


        Row {
            id: layout
            x: extraActionsFrame.margins.left
            y: extraActionsFrame.margins.top
            ActionButton {
                id: removeButton
                svg: iconsSvg
                elementId: "configure"

                action: applet.action("configure")
            }

            Item {
                id: placeHolder
                width: actionSize
                height: actionSize
            }

            ActionButton {
                id: runButton
                anchors.right: parent.right
                svg: iconsSvg
                elementId: "close"

                action: applet.action("remove")
            }
        }
    }

    PlasmaCore.SvgItem {
        id: extraActionsButton
        width: actionSize
        height: actionSize
        x: 0
        y: 0
        svg: iconsSvg
        elementId: "configure"

        MouseArea {
            anchors.fill: parent
            anchors.leftMargin: -10
            anchors.topMargin: -10
            anchors.rightMargin: -10
            anchors.bottomMargin: -10

            drag.target: extraActionsButton
            drag.minimumX:  -actionSize
            drag.maximumX:  actionSize
            drag.minimumY: 0
            drag.maximumY: 0

            onPressed: {
                mouse.accepted = true
                extraActionsFrame.opacity = 1
            }
            onReleased: {
                extraActionsFrame.opacity = 0
                extraActionsButton.x = 0
                extraActionsButton.y = 0
            }
        }
    }
}
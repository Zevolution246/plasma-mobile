// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian K�gler <sebas@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.graphicslayouts 4.7 as GraphicsLayouts

Item {
    width: 400
    height: 300

    Column {
        anchors.fill: parent
        anchors.topMargin: 20
        spacing: 10
        Text {
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            id: title
            text: i18n("<h1>Activities</h1>")
            color: theme.textColor
            style: Text.Sunken
            styleColor: theme.backgroundColor
        }

        Text {
            id: description
            width: parent.width - 40
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            text: i18n("<p>Activities help you to organize your device.</p><p>The Contour shell organizes your apps, bookmarks, media, documents and contacts into Activities. Slide out the Activity switcher from the right hand side to switch between activities, to create new activities, and to remove old ones.</p>\
            <p>Use the buttons at the top left to personalize your activities by adding items and widgets.</p>")
            color: theme.textColor
            styleColor: theme.backgroundColor
        }
    }
}

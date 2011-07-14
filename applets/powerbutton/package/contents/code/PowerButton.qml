// -*- coding: iso-8859-1 -*-
/*
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>
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

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.mobilecomponents 0.1

Item {
    id: powerbutton
    width: 32
    height: 32

    PlasmaCore.DataSource {
        id: pmSource
        engine: "org.kde.devicecapabilities"
        connectedSources: ["PowerManagement"]
        interval: 0
    }


    IconButton {
        anchors.fill: parent
        icon: QIcon("system-suspend")

        onClicked: {
            print("suspendbutton triggered");
            var service = pmSource.serviceForSource("PowerManagement")
            var operation = service.operationDescription("suspend")
            service.startOperationCall(operation)
        }

        onPressAndHold: {
            print("suspendbutton pressAndHold");
            var service = pmSource.serviceForSource("PowerManagement")
            var operation = service.operationDescription("requestShutDown")
            service.startOperationCall(operation)
        }
    }
}

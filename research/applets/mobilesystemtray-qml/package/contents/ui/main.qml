/*
 *   Copyright 2010 Alexis Menard <menard@kde.org>
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

import Qt 4.7
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.qtextracomponents 0.1 as QtExtra

Item {
    PlasmaCore.DataSource {
          id: statusNotifierSource
          engine: "statusnotifieritem"
          interval: 0
          onSourceAdded: {
             connectSource(source)
          }
          Component.onCompleted: {
              connectedSources = sources
          }
      }

    Flickable {
        id: tasksFlickable
        anchors.fill: parent
        clip: true
        interactive:true
        contentWidth: tasksFlow.width
        contentHeight: tasksFlow.height

        Flow {
            id: tasksFlow
            width: ((tasksFlickable.width<tasksFlickable.height)?tasksFlickable.width:tasksFlickable.width*tasksRepeater.count)
            height: ((tasksFlickable.width>tasksFlickable.height)?tasksFlickable.height:tasksFlickable.height*tasksRepeater.count)

            Repeater {
                id: tasksRepeater
                model:  PlasmaCore.DataModel {
                    dataSource: statusNotifierSource
                }
                delegate: TaskWidget {
                    
                }
            }
        }
    }
}

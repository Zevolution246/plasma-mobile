/***************************************************************************
 *   Copyright 2006-2008 Aaron Seigo <aseigo@kde.org>                      *
 *   Copyright 2009 Marco Martin <notmart@gmail.com>                       *
 *   Copyright 2010 Alexis Menard <menard@kde.org>                         *
 *   Copyright 2010 Artur Duque de Souza <asouza@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

#ifndef MOBCORONA_H
#define MOBCORONA_H

#include <QtGui/QGraphicsScene>

#include <Plasma/Corona>

namespace Plasma
{
    class Applet;
} // namespace Plasma

class Activity;
class KActivityController;

/**
 * @short A Corona with mobile considerations
 */
class MobCorona : public Plasma::Corona
{
    Q_OBJECT

public:
    MobCorona(QObject * parent);
    ~MobCorona();

    /**
     * Loads the default (system wide) layout for this user
     **/
    void loadDefaultLayout();
    Plasma::Containment *findFreeContainment() const;

    virtual int numScreens() const;
    void setScreenGeometry(const QRect &geometry);
    virtual QRect screenGeometry(int id) const;
    virtual QRegion availableScreenRegion(int id) const;

    KConfigGroup storedConfig(int containmentId);
    Plasma::Containment *restoreContainment(const int containmentId);
    int totalContainments() const;
    
    
    void currentActivityChanged(const QString &newActivity);
    Activity* activity(const QString &id);
    void activityAdded(const QString &id);
    void activityRemoved(const QString &id);
    void activateNextActivity();
    void activatePreviousActivity();

public Q_SLOTS:
    void layoutContainments();


private:
    void init();
    Plasma::Applet *loadDefaultApplet(const QString &pluginName, Plasma::Containment *c);
    QRect m_screenGeometry;
    int m_containmentsRestoredCount;
    KActivityController *m_activityController;
    QHash<QString, Activity*> m_activities;
};

#endif



/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
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

#ifndef COMPLETIONMODEL_H
#define COMPLETIONMODEL_H

#include <QDeclarativeComponent>
#include <QObject>
#include <QImage>
#include <Nepomuk/Query/Result>

#include "settingsmodule.h"

class History;
class SettingsModulesModelPrivate;

class SettingsModulesModel : public QDeclarativeComponent
{
    Q_OBJECT
    Q_PROPERTY(QDeclarativeListProperty<SettingsModule> settingsModules READ settingsModules NOTIFY settingsModulesChanged)

public:
    SettingsModulesModel(QDeclarativeComponent* parent = 0 );
    ~SettingsModulesModel();

    QDeclarativeListProperty<SettingsModule> settingsModules();

public Q_SLOTS:
    void populate();
Q_SIGNALS:
    void dataChanged();
    void settingsModulesChanged();

private:
    SettingsModulesModelPrivate* d;
};

#endif // COMPLETIONMODEL_H

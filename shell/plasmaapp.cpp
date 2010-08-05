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

#include "plasmaapp.h"

#include "mobview.h"
#include "mobcorona.h"
#include "../common/qmlwidget.h"
#include "widgetsexplorer/mobilewidgetsexplorer.h"

#include <unistd.h>

#include <QApplication>
#include <QDesktopWidget>
#include <QGraphicsEffect>
#include <QPixmapCache>
#include <QtDBus/QtDBus>

#include <KAction>
#include <KCrash>
#include <KDebug>
#include <KCmdLineArgs>
#include <KStandardAction>
#include <KStandardDirs>
#include <KGlobalAccel>
#include <KWindowSystem>
#include <KServiceTypeTrader>

#include <ksmserver_interface.h>

#include <Plasma/Containment>
#include <Plasma/Theme>
#include <Plasma/WindowEffects>
#include <Plasma/Applet>
#include <Plasma/Package>
#include <Plasma/Wallpaper>

#include <X11/Xlib.h>
#include <X11/extensions/Xrender.h>

extern void setupBindings();

class CachingEffect : public QGraphicsEffect
{
  public :
    CachingEffect(QObject *parent = 0) : QGraphicsEffect(parent)
    {}

    void draw(QPainter *p)
    {
        QPoint point;
        QPixmap pixmap = sourcePixmap(Qt::LogicalCoordinates, &point);
        //maybe we are in a view with save and restore disabled..
        p->setCompositionMode(QPainter::CompositionMode_Source);

        p->drawPixmap(point, pixmap);
        p->setCompositionMode(QPainter::CompositionMode_SourceOver);
    }
};

PlasmaApp* PlasmaApp::self()
{
    if (!kapp) {
        return new PlasmaApp();
    }

    return qobject_cast<PlasmaApp*>(kapp);
}

PlasmaApp::PlasmaApp()
    : KUniqueApplication(),
      m_corona(0),
      m_mainView(0),
      m_currentContainment(0), m_nextContainment(0),
      m_trayContainment(0),
      m_isDesktop(false)
{
    setupBindings();
    KGlobal::locale()->insertCatalog("libplasma");

    KCmdLineArgs *args = KCmdLineArgs::parsedArgs();

    bool useGL = args->isSet("opengl");
    m_mainView = new MobView(0, MobView::mainViewId(), 0);
    m_mainView->setUseGL(useGL);

    bool isDesktop = args->isSet("desktop");
    if (isDesktop) {
        notifyStartup(false);
        KCrash::setFlags(KCrash::AutoRestart);
        //FIXME: uncomment on everyhting that is not Maemo
        //m_mainView->setWindowFlags(Qt::FramelessWindowHint);
    }

    connect(m_mainView, SIGNAL(containmentActivated()), this, SLOT(mainContainmentActivated()));

    int width = 800;
    int height = 480;
    if (isDesktop) {
        QRect rect = QApplication::desktop()->screenGeometry(m_mainView->screen());
        width = rect.width();
        height = rect.height();
    } else {
        QAction *action = KStandardAction::quit(qApp, SLOT(quit()), m_mainView);
        m_mainView->addAction(action);

        QString geom = args->getOption("screen");
        int x = geom.indexOf('x');

        if (x > 0)  {
            width = qMax(width, geom.left(x).toInt());
            height = qMax(height, geom.right(geom.length() - x - 1).toInt());
        }
    }

    bool isFullScreen = args->isSet("fullscreen");
    if (isFullScreen) {
        m_mainView->showFullScreen();
    }

    setIsDesktop(isDesktop);
    m_mainView->setFixedSize(width, height);
    m_mainView->move(0,0);

    KConfigGroup cg(KSharedConfig::openConfig("plasmarc"), "Theme-plasma-mobile");
    const QString themeName = cg.readEntry("name", "air-mobile");
    Plasma::Theme::defaultTheme()->setUseGlobalSettings(false);
    Plasma::Theme::defaultTheme()->setThemeName(themeName);

    cg = KConfigGroup(KGlobal::config(), "General");
    Plasma::Theme::defaultTheme()->setFont(cg.readEntry("desktopFont", font()));

    // this line initializes the corona and setups the main qml homescreen
    corona();
    connect(this, SIGNAL(aboutToQuit()), this, SLOT(cleanup()));

    KAction *lockAction = new KAction(this);
    lockAction->setText(i18n("Lock Plasma Mobile screen"));
    lockAction->setObjectName(QString("lock screen")); // NO I18

    KGlobalAccel::cleanComponent("plasma-mobile");
    lockAction->setGlobalShortcut(KShortcut(Qt::CTRL + Qt::Key_L));
    m_mainView->addAction(lockAction);
    connect(lockAction, SIGNAL(triggered()), this, SLOT(lockScreen()));
}

PlasmaApp::~PlasmaApp()
{
}

void PlasmaApp::cleanup()
{
    if (m_corona) {
        m_corona->saveLayout();
    }

    delete m_mainView;
    m_mainView = 0;

    delete m_corona;
    m_corona = 0;

    //TODO: This manual sync() should not be necessary?
    syncConfig();
}

void PlasmaApp::setIsDesktop(bool isDesktop)
{
    m_isDesktop = isDesktop;

    if (isDesktop) {
        KWindowSystem::setType(m_mainView->winId(), NET::Normal);
        m_mainView->setWindowFlags(m_mainView->windowFlags() | Qt::FramelessWindowHint);
        KWindowSystem::setOnAllDesktops(m_mainView->winId(), true);
        m_mainView->show();
    } else {
        m_mainView->setWindowFlags(m_mainView->windowFlags() & ~Qt::FramelessWindowHint);
        KWindowSystem::setOnAllDesktops(m_mainView->winId(), false);
        KWindowSystem::setType(m_mainView->winId(), NET::Normal);
    }
}

void PlasmaApp::syncConfig()
{
    KGlobal::config()->sync();
}

void PlasmaApp::setupHomeScreen()
{
    m_qmlWidget = new Plasma::QmlWidget();

    m_qmlWidget->setQmlPath(KStandardDirs::locate("appdata", "containments/homescreen/HomeScreen.qml"));

    if (!m_qmlWidget->engine()) {
        QCoreApplication::quit();
    }

    m_homescreen = m_qmlWidget->mainComponent();

    QDeclarativeItem *mainItem = qobject_cast<QDeclarativeItem*>(m_qmlWidget->rootObject());

    mainItem->setProperty("width", m_mainView->size().width());
    mainItem->setProperty("height", m_mainView->size().height());

    // adds the homescreen to corona
    m_corona->addItem(mainItem);

    // get references for the main objects that we'll need to deal with
    m_mainSlot = mainItem->findChild<QDeclarativeItem*>("mainSlot");
    m_spareSlot = mainItem->findChild<QDeclarativeItem*>("spareSlot");
    connect(m_mainSlot, SIGNAL(transformingChanged(bool)), this, SLOT(mainSlotTransformingChanged(bool)));

    QDeclarativeItem *containments = mainItem->findChild<QDeclarativeItem*>("containments");
    connect(containments, SIGNAL(transformingChanged(bool)), this, SLOT(containmentsTransformingChanged(bool)));


    m_trayPanel = mainItem->findChild<QDeclarativeItem*>("systraypanel");
    m_homeScreen = mainItem;

    connect(m_homeScreen, SIGNAL(transitionFinished()),
            this, SLOT(updateMainSlot()));

    m_panel = mainItem->findChild<QDeclarativeItem*>("activitypanel");

    m_mainView->setSceneRect(mainItem->x(), mainItem->y(),
                             mainItem->width(), mainItem->height());

    QDeclarativeItem *panelItems = m_panel->findChild<QDeclarativeItem*>("panelitems");

    foreach(QObject *item, panelItems->children()) {
        connect(item, SIGNAL(clicked()), this, SLOT(changeActivity()));
    }
}

void PlasmaApp::containmentsTransformingChanged(bool transforming)
{
    m_currentContainment->graphicsEffect()->setEnabled(transforming);
    m_alternateContainment->graphicsEffect()->setEnabled(transforming);
}


void PlasmaApp::changeActivity()
{
    QDeclarativeItem *item = qobject_cast<QDeclarativeItem*>(sender());
    Plasma::Containment *containment = m_containments.value(item->objectName().toInt());
    changeActivity(containment);
}

void PlasmaApp::changeActivity(Plasma::Containment *containment)
{
    if (containment == m_currentContainment) {
        return;
    }

    // found it!
    if (containment) {
        m_nextContainment = containment;
        setupContainment(containment);
    }
}

void PlasmaApp::lockScreen()
{
    changeActivity(m_containments.value(1));
}

void PlasmaApp::updateMainSlot()
{
    if (m_currentContainment && m_nextContainment) {
        m_homeScreen->setProperty("state", "Normal");

        m_nextContainment->setParentItem(m_mainSlot);

        m_nextContainment->graphicsEffect()->setEnabled(false);
        // resizing the containment will always resize it's parent item
        m_nextContainment->setPos(0,0);
        m_nextContainment->resize(m_mainView->size());

        m_currentContainment->setParentItem(0);
        m_currentContainment->setPos(0, m_currentContainment->size().height());

        m_currentContainment->setPos(m_mainView->width(), m_mainView->height());

        m_currentContainment->setVisible(false);
        m_currentContainment->graphicsEffect()->setEnabled(false);
        m_currentContainment = m_nextContainment;
        m_nextContainment = 0;
        m_currentContainment->setScreen(0);

    }
}

Plasma::Corona* PlasmaApp::corona()
{
    if (!m_corona) {
        m_corona = new MobCorona(this);
        m_corona->setItemIndexMethod(QGraphicsScene::NoIndex);

        connect(m_corona, SIGNAL(containmentAdded(Plasma::Containment*)),
                this, SLOT(manageNewContainment(Plasma::Containment*)));
        connect(m_corona, SIGNAL(configSynced()), this, SLOT(syncConfig()));


        // setup our QML home screen;
        setupHomeScreen();
        m_corona->initializeLayout();
        m_corona->setScreenGeometry(QRect(QPoint(0,0), m_mainView->size()));
        m_mainView->setScene(m_corona);
        m_mainView->show();
    }
    return m_corona;
}

bool PlasmaApp::hasComposite()
{
    return KWindowSystem::compositingActive();
}

void PlasmaApp::notifyStartup(bool completed)
{
    org::kde::KSMServerInterface ksmserver("org.kde.ksmserver",
                                           "/KSMServer", QDBusConnection::sessionBus());

    const QString startupID("mobile desktop");
    if (completed) {
        ksmserver.resumeStartup(startupID);
    } else {
        ksmserver.suspendStartup(startupID);
    }
}

void PlasmaApp::mainContainmentActivated()
{
    m_mainView->setWindowTitle(m_mainView->containment()->activity());
    const WId id = m_mainView->effectiveWinId();

    QWidget * activeWindow = QApplication::activeWindow();
    KWindowSystem::raiseWindow(id);

    if (activeWindow) {
        KWindowSystem::raiseWindow(activeWindow->effectiveWinId());
        m_mainView->activateWindow();
        activeWindow->setFocus();
    } else {
        m_mainView->activateWindow();
    }
}

void PlasmaApp::setupContainment(Plasma::Containment *containment)
{
    if (m_currentContainment) {
        containment->setParentItem(m_spareSlot);
        containment->setPos(0,0);
        containment->setPos(0, 0);

        containment->setVisible(true);

        containment->resize(m_mainView->size());
        //FIXME: this makes the containment to not paint until the animation finishes
        containment->graphicsEffect()->setEnabled(true);
        //###The reparenting need a repaint so this ensure that we
        //have actually re-render the containment otherwise it
        //makes animations slugglish. We need a better solution.
        QTimer::singleShot(0, this, SLOT(slideActivities()));
    }
}

void PlasmaApp::slideActivities()
{
    // change state
    m_homeScreen->setProperty("state", "Slide");
}

void PlasmaApp::resizeTray()
{
    m_trayContainment->resize(m_trayPanel->property("width").toReal(),
                              m_trayPanel->property("height").toReal());
}

void PlasmaApp::shrinkTray()
{
    m_trayPanel->setProperty("state", "passive");
}

void PlasmaApp::manageNewContainment(Plasma::Containment *containment)
{
    QAction *addAction = containment->action("add widgets");
    if (addAction) {
        connect(addAction, SIGNAL(triggered()), this, SLOT(showWidgetsExplorer()));
    }

    if (containment->location() == Plasma::TopEdge) { // systray's containment!
        if (m_trayContainment) {
            delete containment;
            return;
        }
        m_trayContainment = containment;
        m_trayContainment->setParentItem(m_trayPanel);
        m_trayContainment->setParent(m_trayPanel);

        m_trayContainment->resize(m_trayPanel->property("width").toReal(),
                                  m_trayPanel->property("height").toReal());
        m_trayContainment->setPos(0, 0);

        connect(m_trayPanel, SIGNAL(xChanged()), this, SLOT(resizeTray()));
        // "enlarge" is initiated by a QML mousearea, but "shrink" needs to be initiated by
        // the applet itself..
        connect(m_trayContainment, SIGNAL(shrinkRequested()), this, SLOT(shrinkTray()));

        return;
    }

    // add the containment and it identifier to a hash to enable us
    // to retrieve it later.
    m_containments.insert(containment->id(), containment);

    connect(containment, SIGNAL(destroyed(QObject *)), this, SLOT(containmentDestroyed(QObject *)));


    if (!m_mainSlot) {
        return;
    }

    containment->setParentItem(m_mainSlot);
    containment->setParent(m_mainSlot);
    containment->setPos(0, 0);

    CachingEffect *effect = new CachingEffect(containment);
    containment->setGraphicsEffect(effect);
    containment->graphicsEffect()->setEnabled(false);

    m_mainSlot->setFlag(QGraphicsItem::ItemHasNoContents, false);
    containment->resize(m_mainView->size());

    // we need our homescreen to show something!
    if (containment->id() == 1) {
        containment->setPos(0,0);
        m_currentContainment = containment;
        return;
    } else if (containment->id() == 2) {
        QDeclarativeItem *alternateSlot = m_homeScreen->findChild<QDeclarativeItem*>("alternateSlot");

        if (alternateSlot) {
            m_alternateContainment = containment;
            alternateSlot->setProperty("width", m_mainView->size().width());
            alternateSlot->setProperty("height", m_mainView->size().height());
            containment->setParentItem(alternateSlot);
            containment->setParent(alternateSlot);
            containment->setPos(0, 0);
            return;
        }
    }

    // XXX: FIX ME with beautiful values :)
    containment->setPos(m_mainView->width(), m_mainView->height());
    containment->setVisible(false);
}

void PlasmaApp::showWidgetsExplorer()
{
    if (!m_widgetsExplorer) {
        m_widgetsExplorer = new MobileWidgetsExplorer(0);
        m_widgetsExplorer.data()->setZValue(1000);
        m_corona->addItem(m_widgetsExplorer.data());
    }

    m_widgetsExplorer.data()->setContainment(m_currentContainment);
    m_widgetsExplorer.data()->setGeometry(m_mainView->sceneRect());
    m_widgetsExplorer.data()->show();
}

void PlasmaApp::containmentDestroyed(QObject *object)
{
    Plasma::Containment *cont = qobject_cast<Plasma::Containment *>(object);

    if (cont) {
        m_containments.remove(cont->id());
    }
}

#include "plasmaapp.moc"

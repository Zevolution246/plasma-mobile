project(alarmsengine)

find_package(Akonadi REQUIRED)
find_package (KdepimLibs REQUIRED)

include_directories(${CMAKE_CURRENT_BINARY_DIR} ${KDE4_INCLUDES} ${KDEPIMLIBS_INCLUDE_DIRS} ${QT_INCLUDES} )

add_definitions (${QT_DEFINITIONS} ${KDE4_DEFINITIONS} ${KDEPIM_DEFINITIONS} ${AKONADI_DEFINITIONS})

set(alarmsengine_srcs
    alarmcontainer.cpp
    alarmsengine.cpp
    alarmsjob.cpp
    alarmsservice.cpp
    calendarcreator.cpp
)

#kcfg_generate_dbus_interface(${CMAKE_CURRENT_SOURCE_DIR}/kalarmresource.kcfg org.kde.Akonadi.KAlarm.Settings)
qt4_add_dbus_interface(alarmsengine_srcs org.kde.Akonadi.KAlarm.Settings.xml kalarmsettings KAlarmSettings)
qt4_add_dbus_interface(alarmsengine_srcs org.kde.Akonadi.KAlarmDir.Settings.xml kalarmdirsettings KAlarmDirSettings)

kde4_add_plugin(plasma_engine_alarms ${alarmsengine_srcs})

target_link_libraries(plasma_engine_alarms
    ${KDE4_PLASMA_LIBS}
    ${KDEPIMLIBS_AKONADI_LIBS}
    #${KDE4_AKONADI_LIBS}
    ${KDE4_KPIMUTILS_LIBS}
    ${KDEPIMLIBS_KALARMCAL_LIBS}
    #${KDEPIMLIBS_AKONADI_KCAL_LIBS}
    ${KDEPIMLIBS_KCALCORE_LIBS}
)

install(TARGETS plasma_engine_alarms DESTINATION ${PLUGIN_INSTALL_DIR})
install(FILES plasma-engine-alarms.desktop DESTINATION ${SERVICES_INSTALL_DIR})

install(FILES org.kde.alarms.operations
        DESTINATION ${DATA_INSTALL_DIR}/plasma/services)
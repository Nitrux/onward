qt_add_executable(onward
    MANUAL_FINALIZATION
    main.cpp
    ../assets/assets.qrc
)

set(onward_qml_names
    main.qml
    WelcomePage.qml
    AnnotatedSlideshow.qml
    WorkspacePage.qml
    KeybindsPage.qml
    TopicPage.qml
    AppsPage.qml
    SystemPage.qml
    SettingsPage.qml
    CommunityPage.qml
)

foreach(name IN LISTS onward_qml_names)
    set(source "${CMAKE_CURRENT_SOURCE_DIR}/../qml/${name}")
    set_source_files_properties("${source}" PROPERTIES QT_RESOURCE_ALIAS "${name}")
    list(APPEND onward_qml_sources "${source}")
endforeach()

qt_add_qml_module(onward
    URI org.nitrux.onward
    NO_PLUGIN
    NO_IMPORT_SCAN
    RESOURCE_PREFIX /
    VERSION 1.0
    QML_FILES ${onward_qml_sources}
)

target_link_libraries(onward
    PRIVATE
        MauiKit4
        KF6::CoreAddons
        KF6::I18n
        KF6::I18nQml
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::Widgets
)

install(TARGETS onward ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
qt_finalize_executable(onward)

include(GNUInstallDirs)
configure_file(onward.in onward-service @ONLY)
install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/onward-service DESTINATION ${KDE_INSTALL_DATAROOTDIR}/onward RENAME onward)

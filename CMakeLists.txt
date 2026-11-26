cmake_minimum_required(VERSION 3.20)

project(onward VERSION 0.1.0 LANGUAGES CXX)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "/usr" CACHE PATH "Install path prefix" FORCE)
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(QT_MAJOR_VERSION 6)
set(REQUIRED_QT_VERSION 6.9)
set(REQUIRED_KF_VERSION 6.13.0)
set(REQUIRED_MAUIKIT_VERSION 4.0.5)

include(CheckCXXCompilerFlag)

find_package(ECM ${REQUIRED_KF_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMFindQmlModule)
include(FeatureSummary)

find_package(Qt6 ${REQUIRED_QT_VERSION} REQUIRED COMPONENTS Core Gui Qml Quick Widgets)
find_package(KF6 ${REQUIRED_KF_VERSION} REQUIRED COMPONENTS CoreAddons I18n)
set(QT_NO_PRIVATE_MODULE_WARNING ON CACHE BOOL
    "MauiKit uses Qt's private WaylandClient API" FORCE)
find_package(MauiKit4 ${REQUIRED_MAUIKIT_VERSION} REQUIRED)
ecm_find_qmlmodule(org.mauikit.controls 1.0)

if(NOT CMAKE_CROSSCOMPILING)
    string(TOLOWER "${CMAKE_HOST_SYSTEM_PROCESSOR}" ONWARD_HOST_PROCESSOR)
    string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" ONWARD_TARGET_PROCESSOR)
    if(ONWARD_HOST_PROCESSOR MATCHES "^(x86_64|amd64)$"
       AND ONWARD_TARGET_PROCESSOR MATCHES "^(x86_64|amd64)$")
        check_cxx_compiler_flag("-march=x86-64-v3" ONWARD_HAS_X86_64_V3)
        if(ONWARD_HAS_X86_64_V3)
            add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-march=x86-64-v3>)
        endif()
    endif()
endif()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

qt_standard_project_setup()
qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

add_subdirectory(src)

install(FILES org.nitrux.onward.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES README.md LICENSE
    DESTINATION ${KDE_INSTALL_DATAROOTDIR}/doc/${PROJECT_NAME})

if(NOT TARGET uninstall)
    configure_file(
        cmake_uninstall.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
        IMMEDIATE
        @ONLY
    )

    add_custom_target(uninstall
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
    )
endif()

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)

set(CPACK_PACKAGE_NAME "onward")
set(CPACK_PACKAGE_VENDOR "Nitrux Latinoamericana S.C.")
set(CPACK_PACKAGE_CONTACT "uri_herrera@nxos.org")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Onward - Nitrux desktop onboarding guide")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://nxos.org")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Uri Herrera <uri_herrera@nxos.org>")
set(CPACK_DEBIAN_PACKAGE_SECTION "utils")
set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
set(CPACK_PACKAGING_INSTALL_PREFIX "/usr")
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "mauikit (>= 4.0.5), openrc, libqt6svg6, qml6-module-qtquick, qml6-module-qtquick-controls, qml6-module-qtquick-layouts, qml6-module-qtquick-window")
set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "nitrux-wallpapers")
include(CPack)

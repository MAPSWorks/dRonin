#
# Project: dRonin
# NSIS configuration file for GCS
# dRonin, http://dronin.org, Copyright (c) 2015-2016
# Tau Labs, http://taulabs.org, Copyright (C) 2012-2013
# The OpenPilot Team, http://www.openpilot.org, Copyright (C) 2010-2012.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
# Additional note on redistribution: The copyright and license notices above
# must be maintained in each individual source file that is a derivative work
# of this source file; otherwise redistribution is prohibited.

# This script requires Unicode NSIS 2.46 or higher:
# http://www.scratchpaper.com/

# TODO:
#  - install only built/used modules, not a whole directory.
#  - remove only installed files, not a whole directory.

;--------------------------------
; Includes

!include "x64.nsh"
!include "WinVer.nsh"

; Needed for NSIS2 with outdated WinVer.nsh
!ifndef WINVER_10
  !define WINVER_10_NT     0x8A000000 ;10.0.10240
  !define WINVER_10        0x0A000000 ;10.0.10240
  !insertmacro __WinVer_DefineOSTest AtLeast 10     '""'
!endif

;--------------------------------
; Paths

  ; Tree root locations (relative to this script location)
  !define NSIS_DATA_TREE "."
  !define GCS_BUILD_TREE "${PROJECT_ROOT}"
  !define BRANDING_TREE "${SOURCE_ROOT}\branding"

  ; Default installation folder
  InstallDir "$PROGRAMFILES\dRonin"

  ; Get installation folder from registry if available
  InstallDirRegKey HKLM "Software\dRonin" "Install Location"

;--------------------------------
; Version information

  ; Program name and installer file
  !define PRODUCT_NAME "dRonin GCS"
  !define INSTALLER_NAME "dRonin GCS Installer"

  ; Read automatically generated version info
  !include "${PROJECT_ROOT}\dronin.nsh"

  Name "${PRODUCT_NAME}"
  OutFile "${PACKAGE_DIR}\${OUT_FILE}"

  VIProductVersion ${PRODUCT_VERSION}
  VIAddVersionKey "ProductName" "${INSTALLER_NAME}"
  VIAddVersionKey "FileVersion" "${FILE_VERSION}"
  VIAddVersionKey "Comments" "${INSTALLER_NAME}. ${BUILD_DESCRIPTION}"
  VIAddVersionKey "CompanyName" "dRonin, http://dRonin.org"
  VIAddVersionKey "LegalCopyright" "© 2015-2017 dRonin, 2012-2013 Tau Labs, 2010-2012 The OpenPilot Team"
  VIAddVersionKey "FileDescription" "${INSTALLER_NAME}"

;--------------------------------
; Installer interface and base settings

  !include "MUI2.nsh"
  !define MUI_ABORTWARNING

  ; Adds an XP manifest to the installer
  XPStyle on

  ; Request application privileges for Windows Vista/7
  RequestExecutionLevel admin

  ; Compression level
  SetCompressor /solid lzma

;--------------------------------
; Branding

  BrandingText "© 2015 dRonin http://dRonin.org"

  !define MUI_ICON "${BRANDING_TREE}\gcs.ico"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "${BRANDING_TREE}\win_package_header.bmp"
  !define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
  !define MUI_WELCOMEFINISHPAGE_BITMAP "${BRANDING_TREE}\win_package_welcome.bmp"
  !define MUI_WELCOMEFINISHPAGE_BITMAP_NOSTRETCH
  !define MUI_UNWELCOMEFINISHPAGE_BITMAP "${BRANDING_TREE}\win_package_welcome.bmp"
  !define MUI_UNWELCOMEFINISHPAGE_BITMAP_NOSTRETCH

;--------------------------------
; Language selection dialog settings

  ; Remember the installer language
  !define MUI_LANGDLL_REGISTRY_ROOT "HKLM" 
  !define MUI_LANGDLL_REGISTRY_KEY "Software\dRonin" 
  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
  !define MUI_LANGDLL_ALWAYSSHOW

;--------------------------------
; Settings for MUI_PAGE_FINISH
  !define MUI_FINISHPAGE_RUN
  !define MUI_FINISHPAGE_RUN_FUNCTION "RunApplication"

;--------------------------------
; Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "$(LicenseFile)"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_COMPONENTS
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
; Supported languages, license files and translations

  !include "${NSIS_DATA_TREE}\translations\languages.nsh"

;--------------------------------
; Reserve files

  ; If you are using solid compression, files that are required before
  ; the actual installation should be stored first in the data block,
  ; because this will make your installer start faster.

  !insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
; Installer sections

; Copy GCS core files
Section "Core files" InSecCore
  SectionIn RO
  SetOutPath "$INSTDIR\bin"
  File /r "${GCS_BUILD_TREE}\bin\*"
  SetOutPath "$INSTDIR"
SectionEnd

; Copy GCS plugins
Section "-Plugins" InSecPlugins
  SectionIn RO
  RMDir /r "$INSTDIR\lib\plugins"
  SetOutPath "$INSTDIR\lib\plugins"

  File /r "${GCS_BUILD_TREE}\lib\dr\plugins\*.dll"
  File /r "${GCS_BUILD_TREE}\lib\dr\plugins\*.pluginspec"
SectionEnd

; Copy GCS resources
Section "-Resources" InSecResources
  RMDir /r "$INSTDIR\share"
  SetOutPath "$INSTDIR\share"
  File /r "${GCS_BUILD_TREE}\share\*"
SectionEnd

; Copy firmware files
Section "Firmware" InSecFirmware
  Delete "$INSTDIR\firmware\*.*"
  SetOutPath "$INSTDIR\firmware"
  File "${FIRMWARE_DIR}\*.*"
SectionEnd

Section "Shortcuts" InSecShortcuts
  ; Create desktop and start menu shortcuts
  SetOutPath "$INSTDIR"
  CreateDirectory "$SMPROGRAMS\dRonin"
  CreateShortCut "$SMPROGRAMS\dRonin\dRonin GCS.lnk" "$INSTDIR\bin\drgcs.exe" \
	"" "$INSTDIR\bin\drgcs.exe" 0 "" "" "${PRODUCT_NAME} ${PRODUCT_VERSION}. ${BUILD_DESCRIPTION}"
  CreateShortCut "$SMPROGRAMS\dRonin\dRonin GCS (clean configuration).lnk" "$INSTDIR\bin\drgcs.exe" \
	"-r" "$INSTDIR\bin\drgcs.exe" 0 "" "" "${PRODUCT_NAME} ${PRODUCT_VERSION}. ${BUILD_DESCRIPTION}"
  CreateShortCut "$SMPROGRAMS\dRonin\dRonin Website.lnk" "http://dronin.org" \
	"" "$INSTDIR\bin\drgcs.exe" 0
  CreateShortCut "$DESKTOP\dRonin GCS.lnk" "$INSTDIR\bin\drgcs.exe" \
  	"" "$INSTDIR\bin\drgcs.exe" 0 "" "" "${PRODUCT_NAME} ${PRODUCT_VERSION}. ${BUILD_DESCRIPTION}"
  CreateShortCut "$SMPROGRAMS\dRonin\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0
SectionEnd

; Copy firmware files
Section "Drivers" InSecDrivers
  Delete "$INSTDIR\drivers\*.*"
  SetOutPath "$INSTDIR\drivers"
  File "${PACKAGE_DIR}\*.inf"
SectionEnd

Section ; create uninstall info
  ; Remove existing current-user scoped legacy keys
  DeleteRegKey HKCU "Software\dRonin" 
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\dRonin"
  ClearErrors

  ; Write the installation path into the registry
  WriteRegStr HKLM "Software\dRonin" "Install Location" $INSTDIR

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\dRonin" "DisplayName" "dRonin GCS"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\dRonin" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\dRonin" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\dRonin" "NoRepair" 1

  ; Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

;--------------------------------
; Installer section descriptions

  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${InSecCore} $(DESC_InSecCore)
    !insertmacro MUI_DESCRIPTION_TEXT ${InSecPlugins} $(DESC_InSecPlugins)
    !insertmacro MUI_DESCRIPTION_TEXT ${InSecResources} $(DESC_InSecResources)
    !insertmacro MUI_DESCRIPTION_TEXT ${InSecFirmware} $(DESC_InSecFirmware)
    !insertmacro MUI_DESCRIPTION_TEXT ${InSecShortcuts} $(DESC_InSecShortcuts)
    !insertmacro MUI_DESCRIPTION_TEXT ${InSecDrivers} $(DESC_InSecDrivers)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; Installer functions

Function .onInit

  SetShellVarContext all
  !insertmacro MUI_LANGDLL_DISPLAY

  ; Set drivers disabled on Win 10
  ${If} ${AtLeastWin10}
    SectionSetFlags "${InSecDrivers}" ${SF_RO} ; disable and read-only
    SectionSetText "${InSecDrivers}" "" ; hide it
  ${EndIf}

FunctionEnd

;--------------------------------
; Uninstaller sections

Section "un.dRonin GCS" UnSecProgram
  ; Remove installed files and/or directories
  RMDir /r /rebootok "$INSTDIR\bin"
  RMDir /r /rebootok "$INSTDIR\lib"
  RMDir /r /rebootok "$INSTDIR\share"
  RMDir /r /rebootok "$INSTDIR\firmware"
  RMDir /r /rebootok "$INSTDIR\utilities"
  RMDir /r /rebootok "$INSTDIR\drivers"
  RMDir /r /rebootok "$INSTDIR\misc"
  Delete /rebootok "$INSTDIR\Uninstall.exe"

  ; Remove directory
  RMDir /rebootok "$INSTDIR"

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\dRonin"
  DeleteRegKey HKLM "Software\dRonin"

  ; Remove shortcuts, if any
  SetShellVarContext all
  Delete /rebootok "$DESKTOP\dRonin GCS.lnk"
  Delete /rebootok "$SMPROGRAMS\dRonin\*"
  RMDir /rebootok "$SMPROGRAMS\dRonin"
SectionEnd

Section "un.Maps cache" UnSecCache
  ; Remove maps cache
  SetShellVarContext current
  RMDir /r /rebootok "$APPDATA\dRonin\mapscache"
SectionEnd

Section /o "un.Configuration" UnSecConfig
  ; Remove configuration
  SetShellVarContext current
  Delete /rebootok "$APPDATA\dRonin\dRonin*.db"
  Delete /rebootok "$APPDATA\dRonin\dRonin*.xml"
  Delete /rebootok "$APPDATA\dRonin\dRonin*.ini"
SectionEnd

Section "-un.Profile" UnSecProfile
  ; Remove dRonin user profile subdirectory if empty
  SetShellVarContext current
  RMDir "$APPDATA\dRonin"
SectionEnd

;--------------------------------
; Uninstall section descriptions

  !insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${UnSecProgram} $(DESC_UnSecProgram)
    !insertmacro MUI_DESCRIPTION_TEXT ${UnSecCache} $(DESC_UnSecCache)
    !insertmacro MUI_DESCRIPTION_TEXT ${UnSecConfig} $(DESC_UnSecConfig)
  !insertmacro MUI_UNFUNCTION_DESCRIPTION_END

;--------------------------------
; Uninstaller functions

Function un.onInit

  SetShellVarContext all
  !insertmacro MUI_UNGETLANGUAGE

FunctionEnd

;--------------------------------
; Function to run the application from installer

Function RunApplication

  Exec '"$INSTDIR\bin\drgcs.exe"'

FunctionEnd

# escape=`

# Use the latest Windows Server Core image with .NET Framework 4.8.
#
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019

# Restore the default Windows shell for correct batch processing.
#
SHELL ["cmd", "/S", "/C"]

# Download the Build Tools bootstrapper.
#
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe

# Windows 8.1 SDK
#
# https://developer.microsoft.com/en-us/windows/downloads/sdk-archive/
#
ADD https://go.microsoft.com/fwlink/p/?LinkId=323507 C:\TEMP\Win-8.1-SDK_Setup.exe

RUN C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --includeRecommended `
    --add Microsoft.VisualStudio.Component.VC.v141.x86.x64 `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    --add Microsoft.VisualStudio.Component.VC.140 `
    --add Microsoft.VisualStudio.Component.Windows10SDK.17763 `
    --installPath C:\BuildTools `
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

# Install all features in quiet mode
#
RUN C:\TEMP\Win-8.1-SDK_Setup.exe /features + /q

# Windows Software Development Kit for Windows 8.1 Features
#
#  OptionId.WindowsDesktopSoftwareDevelopmentKit
#  OptionId.WindowsPerformanceToolkit
#  OptionId.WindowsDesktopDebuggers
#  OptionId.AvrfExternal
#  OptionId.NetFxSoftwareDevelopmentKit
#  OptionId.WindowsSoftwareLogoToolkit
#  OptionId.MSIInstallTools
#

ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]


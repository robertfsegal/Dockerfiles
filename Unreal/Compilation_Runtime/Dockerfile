# escape=`

# Modified from UE4 4.27 source and borrowed scripts from ue4-docker (https://github.com/adamrehn/ue4-docker)

FROM mcr.microsoft.com/windows:10.0.17763.1817-amd64 as full

SHELL ["cmd", "/S", "/C"]

# Retrieve the DirectX runtime files required by the Unreal Engine, since even the full Windows base image does not include them
RUN curl --progress-bar -L "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe" --output %TEMP%\directx_redist.exe && `
	start /wait %TEMP%\directx_redist.exe /Q /T:%TEMP%\DirectX && `
	expand %TEMP%\DirectX\APR2007_xinput_x64.cab -F:xinput1_3.dll C:\Windows\System32\ && `
	expand %TEMP%\DirectX\Feb2010_X3DAudio_x64.cab -F:X3DAudio1_7.dll C:\Windows\System32\ && `
	expand %TEMP%\DirectX\Jun2010_D3DCompiler_43_x64.cab -F:D3DCompiler_43.dll C:\Windows\System32\ && `
	expand %TEMP%\DirectX\Jun2010_XAudio_x64.cab -F:XAudio2_7.dll C:\Windows\System32\ && `
	expand %TEMP%\DirectX\Jun2010_XAudio_x64.cab -F:XAPOFX1_5.dll C:\Windows\System32\

# Retrieve the DirectX shader compiler files needed for DirectX Raytracing (DXR)
RUN curl --progress-bar -L "https://github.com/microsoft/DirectXShaderCompiler/releases/download/v1.6.2104/dxc_2021_04-20.zip" --output %TEMP%\dxc.zip && `
	powershell -Command "Expand-Archive -Path \"$env:TEMP\dxc.zip\" -DestinationPath $env:TEMP" && `
	xcopy /y %TEMP%\bin\x64\dxcompiler.dll C:\Windows\System32\ && `
	xcopy /y %TEMP%\bin\x64\dxil.dll C:\Windows\System32\

# Install the Visual C++ runtime files using Chocolatey
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

ADD https://aka.ms/vs/16/release/vs_buildtools.exe c:\vs_buildtools.exe

# Install VS build tool
# For more info, check out https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2019
#
SHELL ["cmd", "/s", "/c"]

RUN c:\vs_buildtools.exe --quiet --wait --norestart --nocache `
	--installPath C:\BuildTools `
	--productId Microsoft.VisualStudio.Product.BuildTools `
	--locale en-US `
	--add Microsoft.VisualStudio.Workload.VCTools `
	--add Microsoft.VisualStudio.Workload.MSBuildTools `
	--add Microsoft.VisualStudio.Component.NuGet `
	--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
	--add Microsoft.VisualStudio.Component.Windows10SDK.20348 `
	--add Microsoft.Net.Component.4.5.TargetingPack `
	--add Microsoft.Net.ComponentGroup.4.6.2.DeveloperTools `
	--add Microsoft.NetCore.Component.SDK `
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

ADD https://www.perforce.com/downloads/perforce/r21.2/bin.ntx64/helix-p4-x64.exe c:\helix-p4-x64.exe

RUN c:\helix-p4-x64 /s /v""/qn""

ENTRYPOINT ["cmd"]
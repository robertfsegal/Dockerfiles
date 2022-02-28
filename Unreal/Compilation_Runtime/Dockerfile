# Modified from UE4 4.27 source and borrowed scripts from ue4-docker (https://github.com/adamrehn/ue4-docker)

# escape=`
ARG DLL_IMAGE=20H2
ARG BASETAG=dev-windows-20H2
ARG VISUAL_STUDIO_BUILD_NUMBER=16
# FROM ${DLL_IMAGE}:${BASETAG} AS full
FROM mcr.microsoft.com/windows:10.0.17763.1817-amd64 as full

SHELL ["cmd", "/S", "/C"]

# Gather the system DLLs that we need from the full Windows base image
RUN xcopy /y C:\Windows\System32\avicap32.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\avrt.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\d3d10warp.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\D3DSCache.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\dsound.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\dxva2.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\glu32.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\mf.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\mfplat.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\mfplay.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\mfreadwrite.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\msdmo.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\msvfw32.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\opengl32.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\ResourcePolicyClient.dll C:\GatheredDlls\

# Retrieve the DirectX runtime files required by the Unreal Engine, since even the full Windows base image does not include them
RUN curl --progress-bar -L "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe" --output %TEMP%\directx_redist.exe && `
	start /wait %TEMP%\directx_redist.exe /Q /T:%TEMP%\DirectX && `
	expand %TEMP%\DirectX\APR2007_xinput_x64.cab -F:xinput1_3.dll C:\GatheredDlls\ && `
	expand %TEMP%\DirectX\Feb2010_X3DAudio_x64.cab -F:X3DAudio1_7.dll C:\GatheredDlls\ && `
	expand %TEMP%\DirectX\Jun2010_D3DCompiler_43_x64.cab -F:D3DCompiler_43.dll C:\GatheredDlls\ && `
	expand %TEMP%\DirectX\Jun2010_XAudio_x64.cab -F:XAudio2_7.dll C:\GatheredDlls\ && `
	expand %TEMP%\DirectX\Jun2010_XAudio_x64.cab -F:XAPOFX1_5.dll C:\GatheredDlls\

# Retrieve the DirectX shader compiler files needed for DirectX Raytracing (DXR)
RUN curl --progress-bar -L "https://github.com/microsoft/DirectXShaderCompiler/releases/download/v1.6.2104/dxc_2021_04-20.zip" --output %TEMP%\dxc.zip && `
	powershell -Command "Expand-Archive -Path \"$env:TEMP\dxc.zip\" -DestinationPath $env:TEMP" && `
	xcopy /y %TEMP%\bin\x64\dxcompiler.dll C:\GatheredDlls\ && `
	xcopy /y %TEMP%\bin\x64\dxil.dll C:\GatheredDlls\

# Copy the required DLLs from the full Windows base image into a smaller Windows Server Core base image
ARG BASETAG
FROM mcr.microsoft.com/windows/servercore:${BASETAG}
COPY --from=full C:\GatheredDlls\ C:\Windows\System32\

# Install the Visual C++ runtime files using Chocolatey
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
RUN choco install -y vcredist-all

# Copy our entrypoint script for enabling vendor-specific graphics APIs
COPY entrypoint.cmd C:\entrypoint.cmd
COPY enable-graphics-apis.ps1 C:\enable-graphics-apis.ps1

# When running containers based on this image, be sure to specify the following flags for the `docker run` command to enable GPU acceleration:
# --isolation process --device class/5B45201D-F2F2-4F3B-85BB-30FF1F953599
# (For more information, see: <https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/gpu-acceleration>)

ADD https://aka.ms/vs/${VISUAL_STUDIO_BUILD_NUMBER}/release/vs_buildtools.exe C:/vs_buildtools.exe

# Install VS build tool
# For more info, check out https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2019
#


RUN c:\vs_buildtools.exe --quiet --wait --norestart --nocache `
	--installPath C:\BuildTools `
	--channelUri "https://aka.ms/vs/${VISUAL_STUDIO_BUILD_NUMBER}/release/channel" `
	--installChannelUri "https://aka.ms/vs/${VISUAL_STUDIO_BUILD_NUMBER}/release/channel" `
	--channelId VisualStudio.${VISUAL_STUDIO_BUILD_NUMBER}.Release `
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


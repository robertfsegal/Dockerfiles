# escape=`

# Get OpenJDK nanoserver container
#
FROM openjdk:8-nanoserver as openjdk

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Remoting versions can be found in Remoting sub-project changelog
# https://github.com/jenkinsci/remoting/blob/master/CHANGELOG.
#
ENV SLAVE_FILENAME=slave.jar `
    REMOTING_VERSION=3.23

ENV SLAVE_HASH_FILENAME=$SLAVE_FILENAME.sha1

# Get the Slave from the Jenkins Artifacts Repository
#
ADD https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/3.23/remoting-3.23.jar c:\slave.jar



FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019

# Install Chocolatey
#
RUN powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# New Powershell, so choco is available 
#
SHELL ["powershell.exe", "-ExecutionPolicy", "Bypass", "-Command"]

# Chocolatey installation of various tools based on Conan Docker tools
# https://github.com/conan-io/conan-docker-tools/blob/master/msvc_15/Dockerfile
#
ENV JAVA_HOME="c:\Program Files\openjdk" `
    JENKINS_HOME="c:\Program Files\jenkins" 

RUN setx /M PATH $($env:Path.TrimEnd(';') +';' + $env:JAVA_HOME + '\bin;')

# Copy Java into the  from the OpenJDK image
#
COPY --from=openjdk "c:\openjdk-8" "$JAVA_HOME"
COPY --from=openjdk "c:\slave.jar" ".\slave.jar"

# Visual Studio build tools
#
RUN choco install --no-progress --yes visualstudio2017buildtools --ignore-package-exit-codes=3010
RUN choco install --no-progress --yes visualcpp-build-tools --ignore-package-exit-codes=3010
RUN choco install --no-progress --yes visualstudio2017-workload-vctools --ignore-package-exit-codes=3010

# Python and CMake
#
RUN choco install --no-progress --yes --norestart cmake --params '"/InstallDir:C:\tools\cmake"' --installargs 'ADD_CMAKE_TO_PATH=""System""'
RUN choco install --no-progress --yes --norestart python3 --version=3.8.0 --params '"/InstallDir:C:\tools\python3"' 
RUN python -m pip install --quiet --upgrade pip
RUN python -m pip install win-unicode-console --quiet --upgrade --force-reinstall --no-cache
RUN python -m pip install conan --quiet --upgrade --force-reinstall --no-cache
RUN python -m pip install conan_package_tools --quiet --upgrade --force-reinstall --no-cache

# SDK Archive
#
# https://developer.microsoft.com/en-us/windows/downloads/sdk-archive/
#
# Windows 8.1 SDK
# https://go.microsoft.com/fwlink/p/?LinkId=323507 // 8.1
#
ADD https://go.microsoft.com/fwlink/p/?LinkId=323507  C:\TEMP\winsdksetup-8.1.exe
RUN C:\TEMP\winsdksetup-8.1.exe /features + /q

# Windows 10 SDK
# https://go.microsoft.com/fwlink/p/?LinkId=619296  // 10.0.10240
#
# Windows 10 SDK header and lib files retrieved from Windows 10 SDK v10.0.10240.0.
#
# [RS] copying files manually into container because running the installer directly is 
# failing for some reason
#
COPY ["./sdks/win-10/10.0.10240.0/Include", "C:/Program Files (x86)/Windows Kits/10/Include/10.0.10240.0/"]
COPY ["./sdks/win-10/10.0.10240.0/Lib",     "C:/Program Files (x86)/Windows Kits/10/Lib/10.0.10240.0/"]

COPY ./jenkins-agent-setup-user.ps1 C:/ProgramData/Jenkins/jenkins-agent-setup-user.ps1
RUN  "Powershell C:/ProgramData/Jenkins/jenkins-agent-setup-user.ps1"

COPY ./slave-launch.ps1 C:/ProgramData/Jenkins/slave-launch.ps1

EXPOSE 5000

USER jenkins
ENTRYPOINT ["powershell.exe", "-f", "C:/ProgramData/Jenkins/slave-launch.ps1"]
# escape=`

# Setup shared variables
ARG ERLANG_VERSION=20.3
ARG RABBITMQ_VERSION=3.7.6

# Use server core to support erlang install
FROM microsoft/windowsservercore as source

# Setup PowerShell as default Run Shell
SHELL ["PowerShell.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; "]

# Environment Variables (ARGs needed to see outer scope ARGs)
ARG ERLANG_VERSION
ENV ERLANG_VERSION=$ERLANG_VERSION

# Install Erlang OTP
COPY otp_win64_20.3.exe c:\erlang_install.exe
RUN Write-Host -Object 'Installing Erlang OTP' ; `
    Start-Process -NoNewWindow -Wait -FilePath "c:\\erlang_install.exe" -ArgumentList /S, /D=c:\erlang ; `
    Write-Host -Object 'Removing Erlang OTP Installer' ; `
    Remove-Item -Path "c:\\erlang_install.exe" ; `
    Write-Host -Object 'Done Installing Erlang OTP'



# Start from nano server
FROM microsoft/nanoserver:1709

# Setup PowerShell as default Run Shell
SHELL ["PowerShell.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; "]

# Environment Variables (ARGs needed to see outer scope ARGs)
ARG RABBITMQ_VERSION
ENV ERLANG_HOME=c:\erlang `
    RABBITMQ_HOME=c:\rabbitmq `
    RABBITMQ_BASE=c:\data `
    ERLANG_VERSION=$ERLANG_VERSION `
    RABBITMQ_VERSION=$RABBITMQ_VERSION  `
    RABBITMQ_SERVER=C:\rabbitmq

# setup persistent folders
VOLUME $RABBITMQ_BASE

# Copy erlang and c++ runtime from windows core image
COPY --from=source C:\erlang\ $ERLANG_HOME
COPY --from=source C:\windows\system32\mfc120.dll C:\windows\system32
COPY --from=source C:\windows\system32\mfc120chs.dll C:\windows\system32
COPY --from=source C:\windows\system32\mfc120cht.dll C:\windows\system32
COPY --from=source C:\windows\system32\mfc120deu.dll C:\windows\system32
COPY --from=source C:\windows\system32\mfc120enu.dll C:\windows\system32
COPY --from=source C:\windows\system32\mfc120esn.dll C:\windows\system32
COPY --from=source C:\windows\system32\mfc120fra.dll C:\windows\system32
COPY --from=source C:\windows\system32\mfc120ita.dll C:\windows\system32
COPY --from=source C:\windows\system32\mfc120jpn.dll C:\windows\system32
COPY --from=source C:\windows\system32\mfc120kor.dll C:\windows\system32
COPY --from=source C:\windows\system32\mfc120rus.dll C:\windows\system32
COPY --from=source C:\windows\system32\mfc120u.dll C:\windows\system32
COPY --from=source C:\windows\system32\mfcm120.dll C:\windows\system32
COPY --from=source C:\windows\system32\mfcm120u.dll C:\windows\system32
#msvcp120.dll & msvcr120.dll already exists on nanoserver
#COPY --from=source C:\windows\system32\msvcp120.dll C:\windows\system32
#COPY --from=source C:\windows\system32\msvcr120.dll C:\windows\system32
COPY --from=source C:\windows\system32\vcamp120.dll C:\windows\system32
COPY --from=source C:\windows\system32\vccorlib120.dll C:\windows\system32
COPY --from=source C:\windows\system32\vcomp120.dll C:\windows\system32


COPY rabbitmq_server-${RABBITMQ_VERSION} ${RABBITMQ_HOME}

# setup working directory
WORKDIR $RABBITMQ_HOME\sbin

# Ports
# 4369: epmd, a peer discovery service used by RabbitMQ nodes and CLI tools
# 5672: used by AMQP 0-9-1 and 1.0 clients without TLS
# 5671: used by AMQP 0-9-1 and 1.0 clients with TLS
# 25672: used by Erlang distribution for inter-node and CLI tools communication and is allocated from a dynamic range (limited to a single port by default, computed as AMQP port + 20000).
# 15672: HTTP API clients and rabbitmqadmin (only if the management plugin is enabled)
# 61613: STOMP clients without TLS (only if the STOMP plugin is enabled)
# 61614: STOMP clients with TLS (only if the STOMP plugin is enabled)
# 1883: MQTT clients without TLS, if the MQTT plugin is enabled
# 8883: MQTT clients with TLS, if the MQTT plugin is enabled
# 15674: STOMP-over-WebSockets clients (only if the Web STOMP plugin is enabled)
# 15675: MQTT-over-WebSockets clients (only if the Web MQTT plugin is enabled)
EXPOSE 5672 15672

ENV HOMEDRIVE=c:\ `
    HOMEPATH=erlang

# turn on management plugin
RUN "rabbitmq-plugins.bat" enable rabbitmq_management --offline

# run external command when container starts to allow for additional setup
CMD .\rabbitmq-server.bat

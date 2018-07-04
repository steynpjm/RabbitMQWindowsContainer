#Invoke-WebRequest -URI http://erlang.org/download/otp_win64_20.3.exe -OutFile otp_win64_20.3.exe
Invoke-WebRequest -URI https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.7.6/rabbitmq-server-windows-3.7.6.zip -OutFile rabbitmq-server-windows-3.7.6.zip
Expand-Archive -Path .\rabbitmq-server-windows-3.7.6.zip -DestinationPath .\rabbitmq-server-windows-3.7.6

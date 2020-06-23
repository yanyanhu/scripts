#!/bin/bash

sudo yum install libunwind libicu
# download required version from the MS website: https://dotnet.microsoft.com/download/dotnet-core
curl -sSL -o dotnet.tar.gz https://go.microsoft.com/fwlink/?LinkID=835019
sudo mkdir -p /opt/dotnet && sudo tar zxf dotnet.tar.gz -C /opt/dotnet
sudo ln -s /opt/dotnet/dotnet /usr/local/bin/dotnet

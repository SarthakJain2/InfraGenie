#See https://aka.ms/containerfastmode to understand how  Visual Studio uses this Dockerfile to  build your images for  faster debugging.

FROM mcr.microsoft.com/dotnet/runtime:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443
# VOLUME /files


FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["Rhipheus.Genie.Cli/Rhipheus.Genie.Cli.csproj", "Rhipheus.Genie.Cli/"]
RUN dotnet restore "Rhipheus.Genie.Cli/Rhipheus.Genie.Cli.csproj"
COPY . .
WORKDIR "/src/Rhipheus.Genie.Cli"
RUN dotnet build "Rhipheus.Genie.Cli.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Rhipheus.Genie.Cli.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "genie.dll","--server"]
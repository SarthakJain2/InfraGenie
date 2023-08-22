#See https://aka.ms/containerfastmode to  understand how Visual Studio  uses this  Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
ENV ASPNETCORE_ENTRYPOINT=Development
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["Rhipheus.Genie.Web.Api/Rhipheus.Genie.Web.Api.csproj", "Rhipheus.Genie.Web.Api/"]
COPY ["Rhipheus.Genie.Api.Models/Rhipheus.Genie.Api.Models.csproj", "Rhipheus.Genie.Api.Models/"]
COPY ["Rhipheus.Genie.Entities/Rhipheus.Genie.Entities.csproj", "Rhipheus.Genie.Entities/"]
RUN dotnet restore "Rhipheus.Genie.Web.Api/Rhipheus.Genie.Web.Api.csproj"
COPY . .
WORKDIR "/src/Rhipheus.Genie.Web.Api"
RUN dotnet build "Rhipheus.Genie.Web.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Rhipheus.Genie.Web.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Rhipheus.Genie.Web.Api.dll","--environment=Development"]
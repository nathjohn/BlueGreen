FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5028

ENV ASPNETCORE_URLS=http://+:5028

USER app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["src/BgApp/BgApp.csproj", "src/BgApp/"]
RUN dotnet restore "src/BgApp/BgApp.csproj"
COPY . .
WORKDIR "/src/src/BgApp"
RUN dotnet build "BgApp.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "BgApp.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BgApp.dll"]

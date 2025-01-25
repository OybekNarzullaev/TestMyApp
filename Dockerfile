# Step 1: Build the .NET Core Application
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["MyApp/MyApp.csproj", "MyApp/"]
RUN dotnet restore "MyApp/MyApp.csproj"
COPY . .
WORKDIR "/src/MyApp"
RUN dotnet build "MyApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MyApp.csproj" -c Release -o /app/publish

# Step 2: Install PostgreSQL
FROM postgres:latest AS postgres

# Step 3: Combine both ASP.NET Core and PostgreSQL in a single container
FROM base AS final

# Copy the .NET application
COPY --from=publish /app/publish /app

# Copy PostgreSQL configuration
COPY --from=postgres /usr/local/bin/docker-entrypoint.sh /usr/local/bin/

WORKDIR /app

ENTRYPOINT ["dotnet", "MyApp.dll"]

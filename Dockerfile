# Use the official .NET SDK image to build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy the project file and restore dependencies
COPY *.csproj ./ 
RUN dotnet restore

# Copy the rest of the application source code
COPY . ./ 
RUN dotnet publish -c Release -o /out

# Use a lightweight runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Install the .NET SDK (needed for running dotnet ef)
RUN apt-get update && apt-get install -y \
    dotnet-sdk-8.0

# Copy the build output from the previous stage
COPY --from=build /out . 

# Expose port 5000
EXPOSE 5000

# Run migrations and then start the app
ENTRYPOINT ["sh", "-c", "dotnet ef database update && dotnet MyApp.dll"]

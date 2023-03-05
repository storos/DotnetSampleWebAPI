FROM mcr.microsoft.com/dotnet/sdk:7.0 AS builder
COPY . /src
RUN dotnet publish "/src/dotnetsamplewebapi.csproj" -c Release -o /publish

FROM mcr.microsoft.com/dotnet/aspnet:7.0
COPY --from=builder /publish /app
WORKDIR /app
EXPOSE 80/tcp
ENTRYPOINT ["dotnet", "dotnetsamplewebapi.dll"]

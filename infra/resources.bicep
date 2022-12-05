param name string
param homeIP string
@secure()
param databasePassword string
param location string = resourceGroup().location

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var containerAppName = '${name}-container-app'
var dbName = '${name}-${resourceToken}-db'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${name}-workspace'
  location: location
  properties: {
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}


resource containerEnv 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: '${name}-container-env'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    zoneRedundant: false
  }
}

resource containerApp 'Microsoft.App/containerapps@2022-03-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: containerEnv.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8000
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          image: 'lscr.io/linuxserver/babybuddy:latest'
          name: containerAppName
          env: [
            {
              name: 'PUID'
              value: '1000'
            }
            {
              name: 'PGID'
              value: '1000'
            }
            {
              name: 'TZ'
              value: 'Europe/London'
            }
            {
              name: 'DB_ENGINE'
              value: 'django.db.backends.postgresql'
            }
            {
              name: 'DB_HOST'
              value: '${dbName}.postgres.database.azure.com'
            }
            {
              name: 'DB_NAME'
              value: 'babybuddy'
            }
            {
              name: 'DB_USER'
              value: 'bb_db_pg_admin'
            }
            {
              name: 'DB_PASSWORD'
              value: databasePassword
            }
          ]
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        maxReplicas: 10
      }
    }
  }
}


resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-01-20-preview' = {
  name: dbName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    version: '13'
    administratorLogin: 'bb_db_pg_admin'
    administratorLoginPassword: databasePassword
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    network: {
    }
    highAvailability: {
      mode: 'Disabled'
    }
    maintenanceWindow: {
      customWindow: 'Disabled'
      dayOfWeek: 0
      startHour: 0
      startMinute: 0
    }
  }
}

resource postgresServer_babybuddy 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-01-20-preview' = {
  parent: postgresServer
  name: 'babybuddy'
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

resource postgresServer_AllowAllWindowsAzureIps 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-01-20-preview' = {
  parent: postgresServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource postgresServer_AllowMyIP 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-01-20-preview' = {
  parent: postgresServer
  name: 'AllowMyIP'
  properties: {
    startIpAddress: homeIP
    endIpAddress: homeIP
  }
}

resource postgresServer_FirewallIPAddress_2022_10_11_10_59_35 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-01-20-preview' = {
  parent: postgresServer
  name: 'FirewallIPAddress_2022-10-11_10-59-35'
  properties: {
    startIpAddress: homeIP
    endIpAddress: homeIP
  }
}

output webUrl string = containerApp.properties.latestRevisionFqdn

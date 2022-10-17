# Deploy babybuddy to Azure!

Follow these instructions to deploy [babybuddy](https://github.com/babybuddy/babybuddy) to Azure,
using Azure Container Apps and a free Azure account.

## Using Azure Portal

After [signing up for an Azure account](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli),
click the link below and fill out the required fields:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpamelafox%2Fbabybuddy-azure%2Fmain%2Finfra%2Fmain.json)

That link will create a resource group with an Azure Container Apps environment and a Flexible PostGreSQL server.
The container will be built from 'lscr.io/linuxserver/babybuddy:latest' and the database will be named "babybuddy".

Once created, you can find its URL by navigating to the Azure Portal, finding the Container App resource,
opening the Overview, and finding the "Application URL" on the right hand side.

Now you can login using the default admin user password (admin/admin). Change that password immediately.
Enjoy tracking your bundle of joy/snot! 👶🏼

## Using Azure CLI

1. [Sign up for an Azure account](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
2. [Install the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
3. Login using the Azure CLI on the command-line:
```
az login
```

4. Deploy all the necessary Azure resources:

```
az deployment sub create \
    --name babybuddy-deployment \
    --location <LOCATION> \
    --template-file infra/main.bicep \
    --parameters name=<NAME> location=<LOCATION> databasePassword=<PASSWORD> homeIP=<IP.ADD.RESS> \
```

That command will create a resource group with an Azure Container Apps environment and a Flexible PostGreSQL server.
The container will be built from 'lscr.io/linuxserver/babybuddy:latest' and the database will be named "babybuddy".

The command above requires four parameters:

* `name`: The name to prefix all the created resources, defaults to "babybuddy"
* `location`: The location for the created resources, such as "eastus". [See all regions](https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/#overview)
* `databasePassword`: The PostGreSQL password, no default. Remember it in a password manager.
* `homeIP`: Your home IP address, so that you can also login to the DB from a local pg shell if desired.

Here's an example:

```
az deployment sub create \
  --name babybuddy-deploy-7 \
  --location eastus \
  --template-file infra/main.bicep \
  --parameters name=babybuddy7 location=eastus databasePassword=SuperDuperSecurePassword homeIP=74.212.134.255 \
```

You can also add `-c` to that command if you want to confirm what resources it will create first.

Once deployed, you can find its URL by navigating to the Azure Portal, finding the Container App resource,
opening the Overview, and finding the "Application URL" on the right hand side.

Now you can login using the default admin user password (admin/admin). Change that password immediately.
Enjoy tracking your bundle of joy/snot! 👶🏼
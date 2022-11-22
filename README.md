# Deploy babybuddy to Azure!

Follow these instructions to deploy [babybuddy](https://github.com/babybuddy/babybuddy) to Azure,
using Azure Container Apps and a free Azure account. 

Enjoy tracking your bundle of joy/snot! 👶🏼

## Using Azure Portal

🎥 [Watch a screencast of deployment with the Azure Portal](https://www.youtube.com/watch?v=-4ln47lTuRw)

1. [Sign up for a free Azure account](https://azure.microsoft.com/free/)
2. Click the link below and fill out the required fields:

    [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fpamelafox%2Fbabybuddy-azure%2Fmain%2Finfra%2Fmain.json)

    ⚠️ If the deploy fails, it likely has to do with a resource not being available in the selected region.
    Try "West US", "Central US", "East US 2", or "Canada Central".

    That deployment will create a resource group with an Azure Container Apps environment and a Flexible PostgreSQL server.
    The container will be built from 'lscr.io/linuxserver/babybuddy:latest' and the database will be named "babybuddy".

3. Once created, find the website URL by navigating to the Azure Portal, selecting the Container App resource,
opening the Overview, and finding the "Application URL" on the right hand side.

4. If you see an nginx error upon your first visit to the URL, just reload the page.

6. Login using the default admin user password (admin/admin). Change that password immediately.



## Using Azure CLI

1. [Sign up for a free Azure account](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
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

    That command will create a resource group with an Azure Container Apps environment and a Flexible PostgreSQL server.
    The container will be built from 'lscr.io/linuxserver/babybuddy:latest' and the database will be named "babybuddy".

    The command above requires four parameters:

    * `name`: The name to prefix all the created resources, defaults to "babybuddy"
    * `location`: The location for the created resources, such as "eastus". [See all regions](https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/#overview)
    * `databasePassword`: The PostGreSQL password, no default. Remember it in a password manager.
    * `homeIP`: Your home IP address, so that you can also login to the DB from a local pg shell if desired.

    Here's an example:

    ```
    az deployment sub create \
      --name babybuddy-deploy1 \
      --location eastus \
      --template-file infra/main.bicep \
      --parameters name=babybuddy location=eastus databasePassword=SuperDuperSecurePassword homeIP=74.212.134.255 \
    ```

    You can also add `-c` to that command if you want to confirm what resources it will create first.

5. Once deployed, find its URL by navigating to the Azure Portal, selecting the Container App resource,
opening the Overview, and finding the "Application URL" on the right hand side.

6. If you see an nginx error upon your first visit to the URL, just reload the page.

7. Now you can login using the default admin user password (admin/admin). Change that password immediately.

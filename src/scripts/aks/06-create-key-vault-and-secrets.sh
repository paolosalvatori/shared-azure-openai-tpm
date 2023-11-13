#!/bin/bash

# Variables
source ./00-variables.sh

# Check if the resource group already exists
echo "Checking if [$resourceGroupName] resource group actually exists in the [$subscriptionName] subscription..."

az group show --name $resourceGroupName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$resourceGroupName] resource group actually exists in the [$subscriptionName] subscription"
    echo "Creating [$resourceGroupName] resource group in the [$subscriptionName] subscription..."
    
    # create the resource group
    az group create --name $resourceGroupName --location $location 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$resourceGroupName] resource group successfully created in the [$subscriptionName] subscription"
    else
        echo "Failed to create [$resourceGroupName] resource group in the [$subscriptionName] subscription"
        exit
    fi
else
	echo "[$resourceGroupName] resource group already exists in the [$subscriptionName] subscription"
fi

# Check if the key vault already exists
echo "Checking if [$keyVaultName] key vault actually exists in the [$subscriptionName] subscription..."
az keyvault show --name $keyVaultName --resource-group $resourceGroupName &> /dev/null

if [[ $? != 0 ]]; then
	echo "No [$keyVaultName] key vault actually exists in the [$subscriptionName] subscription"
    echo "Creating [$keyVaultName] key vault in the [$subscriptionName] subscription..."
    
    # create the key vault
    az keyvault create \
    --name $keyVaultName \
    --resource-group $resourceGroupName \
    --location $location \
    --enabled-for-deployment \
    --enabled-for-disk-encryption \
    --enabled-for-template-deployment \
    --sku $keyVaultSku 1> /dev/null
        
    if [[ $? == 0 ]]; then
        echo "[$keyVaultName] key vault successfully created in the [$subscriptionName] subscription"
    else
        echo "Failed to create [$keyVaultName] key vault in the [$subscriptionName] subscription"
        exit
    fi
else
	echo "[$keyVaultName] key vault already exists in the [$subscriptionName] subscription"
fi

create_secret() {
    local secretName="$1"
    local secretValue="$2"
    local keyVaultName="$3"
    
    echo "Checking if [$secretName] secret actually exists in the [$keyVaultName] key vault..."
    az keyvault secret show --name "$secretName" --vault-name "$keyVaultName" &> /dev/null

    if [[ $? != 0 ]]; then
        echo "No [$secretName] secret actually exists in the [$keyVaultName] key vault"
        echo "Creating [$secretName] secret in the [$keyVaultName] key vault..."

        # Create the secret
        az keyvault secret set \
            --name "$secretName" \
            --vault-name "$keyVaultName" \
            --value "$secretValue" 1> /dev/null

        if [[ $? == 0 ]]; then
            echo "[$secretName] secret successfully created in the [$keyVaultName] key vault"
        else
            echo "Failed to create [$secretName] secret in the [$keyVaultName] key vault"
            exit 1
        fi
    else
        echo "[$secretName] secret already exists in the [$keyVaultName] key vault"
    fi
}

# Create secrets
create_secret "TenantAzureOpenAIMappings--fabrikam" "TanOpenAi" "$keyVaultName"
create_secret "TenantAzureOpenAIMappings--contoso" "BaboOpenAI" "$keyVaultName"
create_secret "Prometheus--Histograms--TotalTokens--Width" "100" "$keyVaultName"
create_secret "Prometheus--Histograms--TotalTokens--Start" "100" "$keyVaultName"
create_secret "Prometheus--Histograms--TotalTokens--Count" "10" "$keyVaultName"
create_secret "Prometheus--Histograms--PromptTokens--Width" "10" "$keyVaultName"
create_secret "Prometheus--Histograms--PromptTokens--Start" "10" "$keyVaultName"
create_secret "Prometheus--Histograms--PromptTokens--Count" "10" "$keyVaultName"
create_secret "Prometheus--Histograms--CompletionTokens--Width" "100" "$keyVaultName"
create_secret "Prometheus--Histograms--CompletionTokens--Start" "100" "$keyVaultName"
create_secret "Prometheus--Histograms--CompletionTokens--Count" "10" "$keyVaultName"
create_secret "Prometheus--Enabled" "True" "$keyVaultName"
create_secret "ChatCompletionsOptions--Temperature" "0.8" "$keyVaultName"
create_secret "ChatCompletionsOptions--MaxTokens" "16000" "$keyVaultName"
create_secret "AzureOpenAI--SystemPrompt" "The assistant is helpful, creative, clever, and very friendly." "$keyVaultName"
create_secret "AzureOpenAI--Services--TanOpenAi--Version" "2023-08-01-preview" "$keyVaultName"
create_secret "AzureOpenAI--Services--TanOpenAi--Type" "azuread" "$keyVaultName"
create_secret "AzureOpenAI--Services--TanOpenAi--Model" "gpt-35-turbo-16k" "$keyVaultName"
create_secret "AzureOpenAI--Services--TanOpenAi--MaxRetries" "3" "$keyVaultName"
create_secret "AzureOpenAI--Services--TanOpenAi--MaxResponseTokens" "1000" "$keyVaultName"
create_secret "AzureOpenAI--Services--TanOpenAi--Endpoint" "https://tanopenai.openai.azure.com/" "$keyVaultName"
create_secret "AzureOpenAI--Services--TanOpenAi--Deployment" "gpt-35-turbo-16k" "$keyVaultName"
create_secret "AzureOpenAI--Services--BaboOpenAI--Version" "2023-08-01-preview" "$keyVaultName"
create_secret "AzureOpenAI--Services--BaboOpenAI--Type" "azuread" "$keyVaultName"
create_secret "AzureOpenAI--Services--BaboOpenAI--Model" "gpt-35-turbo-16k" "$keyVaultName"
create_secret "AzureOpenAI--Services--BaboOpenAI--MaxRetries" "3" "$keyVaultName"
create_secret "AzureOpenAI--Services--BaboOpenAI--MaxResponseTokens" "1000" "$keyVaultName"
create_secret "AzureOpenAI--Services--BaboOpenAI--Endpoint" "https://baboopenai.openai.azure.com/" "$keyVaultName"
create_secret "AzureOpenAI--Services--BaboOpenAI--Deployment" "gpt-35-turbo-16k" "$keyVaultName"
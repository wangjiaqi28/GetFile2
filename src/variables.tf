# --------------------------------------------------------------------------
/*
variable "ARM_CLIENT_ID" {
  type        = string
  description = "Azure Service Principal Client ID"
}

variable "ARM_CLIENT_SECRET" {
  type        = string
  description = "Azure Service Principal Client Secret"
  sensitive   = true
}

variable "ARM_TENANT_ID" {
  type        = string
  description = "Azure Tenant ID"
}

variable "ARM_SUBSCRIPTION_ID" {
  type        = string
  description = "Azure Subscription ID"
}
*/

# --------------------------------------------------------------------------
variable "api_version" {
  type        = string
  description = "API バージョン"
  default = "2018-06-01"
}

variable "target_factory_name" {
  type        = string
  description = "デプロイ先ファクトリー名"
  default = "SCP-1-DataFactory-Integration001-Stage"
}

variable "target_resource_group" {
  type        = string
  description = "デプロイ先リソースグループ"
  default = "SCP-JPE-STAGE01-RG"
}

variable "reference_storageAccounts_map" {
  type = map(string)
  default = {
    # blob imp
    "scpblobdev01" = "scpblobstage01"
    # blob sup
    "scpblobdev02" = "scpblobstage02"
  }
}
variable "reference_linked_service_name_map" {
  type = map(string)
  default = {
    # imp
    "SCP_1_ADFLinkedServices_Blob001_Dev" = "SCP_1_ADFLinkedServices_Blob001_Stage"
    # sup
    "SCP_1_ADFLinkedServices_Blob002_Dev" = "SCP_1_ADFLinkedServices_Blob002_Stage"
    # service now
    "SCP_1_ADFLinkedServices_ServiceNow_invpr001_Dev" = "SCP_1_ADFLinkedServices_ServiceNow_invpr001_Stage"
    # af
    "SCP_1_ADFLinkedServices_Functions001_Dev" = "SCP_1_ADFLinkedServices_Functions001_Stage"
    # akv
    "SCP_1_ADFLinkedServices_KeyVault001_Dev" = "SCP_1_ADFLinkedServices_KeyVault001_Stage"
  }
}

variable "reference_integration_runtime_map" {
  type = map(string)
  default = {
    "AutoResolveIntegrationRuntime" = "SCP-1-DataFactory-Integration001-Stage"
  }
}

variable "reference_pipeline_parameters" {
  type = map(map(string))
  default = {
    "tmp_blob_name" = {
      "scpblobdev01" = "scpblobstage01"
      "scpblobdev02" = "scpblobstage02"
    }
    "sftp_host" = {
      "A1" = "A2"
      "B1" = "B2"
    }
    "sftp_user_name" = {
      "A1" = "A2"
      "B1" = "B2"
    }
    "sftp_secret" = {
      "A1" = "A2"
      "B1" = "B2"
    }
    "sftp_key_vault_name" = {
      "SCP-1-KeyVault-001-Dev" = "SCP-1-KeyVault-001-Stage"
    }
    "blob_name" = {
      "scpblobdev01" = "scpblobstage01"
      "scpblobdev02" = "scpblobstage02"
    }
  }
}
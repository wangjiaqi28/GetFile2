<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.2 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | 2.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.23.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.adf_dataflow](https://registry.terraform.io/providers/Azure/azapi/2.3.0/docs/resources/resource) | resource |
| [azapi_resource.adf_datasets](https://registry.terraform.io/providers/Azure/azapi/2.3.0/docs/resources/resource) | resource |
| [azapi_resource.adf_pipeline_level1](https://registry.terraform.io/providers/Azure/azapi/2.3.0/docs/resources/resource) | resource |
| [azapi_resource.adf_pipeline_level2](https://registry.terraform.io/providers/Azure/azapi/2.3.0/docs/resources/resource) | resource |
| [azapi_resource.adf_pipeline_level3](https://registry.terraform.io/providers/Azure/azapi/2.3.0/docs/resources/resource) | resource |
| [azapi_resource.adf_triggers](https://registry.terraform.io/providers/Azure/azapi/2.3.0/docs/resources/resource) | resource |
| [azurerm_data_factory.target_factory](https://registry.terraform.io/providers/hashicorp/azurerm/4.23.0/docs/data-sources/data_factory) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_version"></a> [api\_version](#input\_api\_version) | API バージョン | `string` | `"2018-06-01"` | no |
| <a name="input_reference_integration_runtime_map"></a> [reference\_integration\_runtime\_map](#input\_reference\_integration\_runtime\_map) | n/a | `map(string)` | <pre>{<br/>  "AutoResolveIntegrationRuntime": "SCP-1-DataFactory-Integration001-Stage"<br/>}</pre> | no |
| <a name="input_reference_linked_service_name_map"></a> [reference\_linked\_service\_name\_map](#input\_reference\_linked\_service\_name\_map) | n/a | `map(string)` | <pre>{<br/>  "SCP_1_ADFLinkedServices_Blob001_Dev": "SCP_1_ADFLinkedServices_Blob001_Stage",<br/>  "SCP_1_ADFLinkedServices_Blob002_Dev": "SCP_1_ADFLinkedServices_Blob002_Stage",<br/>  "SCP_1_ADFLinkedServices_Functions001_Dev": "SCP_1_ADFLinkedServices_Functions001_Stage",<br/>  "SCP_1_ADFLinkedServices_KeyVault001_Dev": "SCP_1_ADFLinkedServices_KeyVault001_Stage",<br/>  "SCP_1_ADFLinkedServices_ServiceNow_invpr001_Dev": "SCP_1_ADFLinkedServices_ServiceNow_invpr001_Stage"<br/>}</pre> | no |
| <a name="input_reference_pipeline_parameters"></a> [reference\_pipeline\_parameters](#input\_reference\_pipeline\_parameters) | n/a | `map(map(string))` | <pre>{<br/>  "blob_name": {<br/>    "scpblobdev01": "scpblobstage01",<br/>    "scpblobdev02": "scpblobstage02"<br/>  },<br/>  "sftp_host": {<br/>    "A1": "A2",<br/>    "B1": "B2"<br/>  },<br/>  "sftp_key_vault_name": {<br/>    "SCP-1-KeyVault-001-Dev": "SCP-1-KeyVault-001-Stage"<br/>  },<br/>  "sftp_secret": {<br/>    "A1": "A2",<br/>    "B1": "B2"<br/>  },<br/>  "sftp_user_name": {<br/>    "A1": "A2",<br/>    "B1": "B2"<br/>  },<br/>  "tmp_blob_name": {<br/>    "scpblobdev01": "scpblobstage01",<br/>    "scpblobdev02": "scpblobstage02"<br/>  }<br/>}</pre> | no |
| <a name="input_reference_storageAccounts_map"></a> [reference\_storageAccounts\_map](#input\_reference\_storageAccounts\_map) | n/a | `map(string)` | <pre>{<br/>  "scpblobdev01": "scpblobstage01",<br/>  "scpblobdev02": "scpblobstage02"<br/>}</pre> | no |
| <a name="input_target_factory_name"></a> [target\_factory\_name](#input\_target\_factory\_name) | デプロイ先ファクトリー名 | `string` | `"SCP-1-DataFactory-Integration001-Stage"` | no |
| <a name="input_target_resource_group"></a> [target\_resource\_group](#input\_target\_resource\_group) | デプロイ先リソースグループ | `string` | `"SCP-JPE-STAGE01-RG"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
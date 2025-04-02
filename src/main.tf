# terraform definition--------------------------------------------------------------
terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "2.3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.23.0"
    }
  }

  required_version = ">= 1.8.2"
}

# provider definition--------------------------------------------------------------
provider "azurerm" {
  features {}
}
provider "azapi" {}

# get target_factory--------------------------------------------------------------
data "azurerm_data_factory" "target_factory" {
  name                = var.target_factory_name
  resource_group_name = var.target_resource_group
}

# dataset
locals {
  dataset_json_files = fileset("${path.module}/dataset", "*.json")

  processed_datasets = {
    for json_file in local.dataset_json_files :
    json_file => merge(
      jsondecode(file("${path.module}/dataset/${json_file}")),
      {
        properties = merge(
          jsondecode(file("${path.module}/dataset/${json_file}")).properties,
          {
            linkedServiceName = merge(
              jsondecode(file("${path.module}/dataset/${json_file}")).properties.linkedServiceName,
              {
                referenceName = lookup(
                  var.reference_linked_service_name_map,
                  jsondecode(file("${path.module}/dataset/${json_file}")).properties.linkedServiceName.referenceName,
                  jsondecode(file("${path.module}/dataset/${json_file}")).properties.linkedServiceName.referenceName
                )
              }
            )
          }
        )
      }
    )
  }

  # 读取 dataflow/*.json 文件
  dataflow_json_files = fileset("${path.module}/dataflow", "*.json")

  processed_dataflows = {
    for json_file in local.dataflow_json_files :
    json_file => {
      name       = jsondecode(file("${path.module}/dataflow/${json_file}")).name
      properties = jsondecode(file("${path.module}/dataflow/${json_file}")).properties
    }
  }

  # 读取 pipeline/*.json 文件
  pipeline_json_files = fileset("${path.module}/pipeline", "*.json")

  # 处理管道 JSON 文件，替换 linkedServiceName.referenceName
  processed_pipelines = {
  for json_file in local.pipeline_json_files :
  json_file => {
    name       = jsondecode(file("${path.module}/pipeline/${json_file}")).name
    properties = merge(
      jsondecode(file("${path.module}/pipeline/${json_file}")).properties,
      {
        activities = [
          for activity in jsondecode(file("${path.module}/pipeline/${json_file}")).properties.activities :
          merge(
            activity,
            contains(keys(activity), "linkedServiceName") ? {
              linkedServiceName = can(activity.linkedServiceName.referenceName) ? merge(
                activity.linkedServiceName,
                {
                  referenceName = lookup(
                    var.reference_linked_service_name_map,
                    activity.linkedServiceName.referenceName,
                    activity.linkedServiceName.referenceName
                  )
                }
              ) : activity.linkedServiceName
            } : {},
            contains(keys(activity), "typeProperties") && contains(keys(activity.typeProperties), "connectVia") ? {
              typeProperties = merge(
                activity.typeProperties,
                {
                  connectVia = merge(
                    activity.typeProperties.connectVia,
                    {
                      referenceName = lookup(
                        var.reference_integration_runtime_map,
                        activity.typeProperties.connectVia.referenceName,
                        activity.typeProperties.connectVia.referenceName
                      )
                    }
                  )
                }
              )
            } : {}
          )
        ],
        parameters = contains(keys(jsondecode(file("${path.module}/pipeline/${json_file}")).properties), "parameters") ? {
          for param_key, param_value in jsondecode(file("${path.module}/pipeline/${json_file}")).properties.parameters :
          param_key => merge(
            param_value,
            can(param_value.defaultValue) && contains(keys(var.reference_pipeline_parameters), param_key) && can(var.reference_pipeline_parameters[param_key][param_value.defaultValue]) ? {
              defaultValue = lookup(
                var.reference_pipeline_parameters[param_key],
                param_value.defaultValue,
                param_value.defaultValue
              )
            } : {}
          )
        } : jsondecode(file("${path.module}/pipeline/${json_file}")).properties.parameters
      }
    )
  }
}

  # 解析每个 JSON 文件，提取依赖关系
  pipeline_dependencies = {
    for json_file in local.pipeline_json_files :
    json_file => {
      name = jsondecode(file("${path.module}/pipeline/${json_file}")).name
      dependencies = compact([
        for activity in jsondecode(file("${path.module}/pipeline/${json_file}")).properties.activities :
        activity.type == "ExecutePipeline" ? activity.typeProperties.pipeline.referenceName : null
      ])
    }
  }

  # 提取无依赖的管道（level1_pipelines）
  level1_pipelines = {
    for key, value in local.pipeline_dependencies :
    key => value if length(value.dependencies) == 0
  }

  # 提取依赖于 level1_pipelines 的管道（level2_pipelines）
  level2_pipelines = {
    for key, value in local.pipeline_dependencies :
    key => value if length([for dep in value.dependencies : dep if contains([for k, v in local.level1_pipelines : v.name], dep)]) > 0
  }

  # 提取依赖于 level2_pipelines 的管道（level3_pipelines）
  level3_pipelines = {
    for key, value in local.pipeline_dependencies :
    key => value if length([for dep in value.dependencies : dep if contains([for k, v in local.level2_pipelines : v.name], dep)]) > 0
  }

  # 获取 trigger 文件夹下的所有 JSON 文件
  trigger_json_files = fileset("${path.module}/trigger", "*.json")

  # 处理触发器 JSON 文件
  processed_triggers = {
    for json_file in local.trigger_json_files :
    basename(json_file) => {
      name       = jsondecode(file("${path.module}/trigger/${json_file}")).name
      properties = merge(
        jsondecode(file("${path.module}/trigger/${json_file}")).properties,
        {
          typeProperties = merge(
            jsondecode(file("${path.module}/trigger/${json_file}")).properties.typeProperties,
            {
              scope = can(
                jsondecode(file("${path.module}/trigger/${json_file}")).properties.typeProperties.scope
              ) ? replace(
                replace(
                  jsondecode(file("${path.module}/trigger/${json_file}")).properties.typeProperties.scope,
                  "/resourceGroups/${split("/", jsondecode(file("${path.module}/trigger/${json_file}")).properties.typeProperties.scope)[4]}",
                  "/resourceGroups/${var.target_resource_group}"
                ),
                "/storageAccounts/${split("/", jsondecode(file("${path.module}/trigger/${json_file}")).properties.typeProperties.scope)[8]}",
                "/storageAccounts/${lookup(var.reference_storageAccounts_map, split("/", jsondecode(file("${path.module}/trigger/${json_file}")).properties.typeProperties.scope)[8], split("/", jsondecode(file("${path.module}/trigger/${json_file}")).properties.typeProperties.scope)[8])}"
              ) : null
            }
          )
        }
      )
    }
  }
  
}

# create dataset resource
resource "azapi_resource" "adf_datasets" {
  for_each = local.processed_datasets

  type      = "Microsoft.DataFactory/factories/datasets@${var.api_version}"
  name      = each.value.name
  parent_id = data.azurerm_data_factory.target_factory.id

  body = {
    properties = each.value.properties
  }
}

# create dataflow resource
resource "azapi_resource" "adf_dataflow" {
  for_each = local.processed_dataflows

  type      = "Microsoft.DataFactory/factories/dataflows@${var.api_version}"
  name      = each.value.name
  parent_id = data.azurerm_data_factory.target_factory.id

  body = {
    properties = each.value.properties
  }

  depends_on = [
    azapi_resource.adf_datasets
  ]
}

# 创建 Level 1 管道资源（无依赖的管道）
resource "azapi_resource" "adf_pipeline_level1" {
  for_each = local.level1_pipelines

  schema_validation_enabled = false
  type      = "Microsoft.DataFactory/factories/pipelines@${var.api_version}"
  name      = each.value.name
  parent_id = data.azurerm_data_factory.target_factory.id

  body = {
    properties = local.processed_pipelines[each.key].properties
  }

  depends_on = [
    azapi_resource.adf_dataflow
  ]
}

# 创建 Level 2 管道资源（依赖于 Level 1 的管道）
resource "azapi_resource" "adf_pipeline_level2" {
  for_each = local.level2_pipelines

  schema_validation_enabled = false
  type      = "Microsoft.DataFactory/factories/pipelines@${var.api_version}"
  name      = each.value.name
  parent_id = data.azurerm_data_factory.target_factory.id

  body = {
    properties = local.processed_pipelines[each.key].properties
  }

  depends_on = [
    azapi_resource.adf_pipeline_level1
  ]
}

# 创建 Level 3 管道资源（依赖于 Level 2 的管道）
resource "azapi_resource" "adf_pipeline_level3" {
  for_each = local.level3_pipelines

  schema_validation_enabled = false
  type      = "Microsoft.DataFactory/factories/pipelines@${var.api_version}"
  name      = each.value.name
  parent_id = data.azurerm_data_factory.target_factory.id

  body = {
    properties = local.processed_pipelines[each.key].properties
  }

  depends_on = [
    azapi_resource.adf_pipeline_level2
  ]
}



# create trigger resource
resource "azapi_resource" "adf_triggers" {
  for_each = local.processed_triggers

  schema_validation_enabled = false
  type      = "Microsoft.DataFactory/factories/triggers@${var.api_version}"
  name      = each.value.name
  parent_id = data.azurerm_data_factory.target_factory.id

  body = {
    properties = each.value.properties
  }

  depends_on = [
    azapi_resource.adf_pipeline_level3
  ]
}


# 输出分层结果
# output "debug1" {
#   value = local.pipeline_json_files
# }

# output "debug2" {
#   value = local.processed_pipelines
# }

# output "debug3" {
#   value = local.processed_pipelines
# }




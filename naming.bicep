// =============================================================================
// Azure Bicep Naming Module
// =============================================================================
// Bicep port of azure-tf-naming. Produces standardized Azure resource names
// following the pattern:
//   <cloudAcronym>-<abbreviation>-<prefix>-<workload>-<environment>-<location>
//
// All inputs are optional; empty components are filtered out. "Clean" names
// (no hyphens, length-limited) are produced for resources with strict rules.
//
// Reference:
//   https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
//   https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules
// =============================================================================

metadata name = 'Azure Naming Module'
metadata description = 'Generates standardized Azure resource names with CAF abbreviations.'

// -----------------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------------

@description('Cloud acronym: "azu" (Azure Commercial) or "azg" (Azure Government).')
@allowed([
  'azu'
  'azg'
])
param cloudAcronym string = 'azu'

@description('Prefix (e.g., company or project). Lowercase alphanumeric only.')
@maxLength(20)
param prefix string = ''

@description('Workload or application name. Lowercase alphanumeric only.')
@maxLength(20)
param workload string = ''

@description('Environment: h/hub, p/prod, np/nonprod, d/dev, t/test, s/stage.')
@allowed([
  'h'
  'hub'
  'p'
  'prod'
  'np'
  'nonprod'
  'd'
  'dev'
  't'
  'test'
  's'
  'stage'
])
param environment string = 'd'

@description('Azure region (e.g., eastus, usgovvirginia). Lowercase alphanumeric only.')
param location string = ''

@description('Delimiter between name components.')
param delimiter string = '-'

@description('If true, abbreviate the region (e.g., eus for eastus).')
param useAzureRegionAbbr bool = false

@description('VM OS type for hostname format: "l" (Linux), "w" (Windows), or empty.')
@allowed([
  ''
  'l'
  'w'
])
param vmOsType string = ''

@description('VM application name (3-6 lowercase alphanumeric chars) for hostname format.')
@maxLength(6)
param vmApplicationName string = ''

// -----------------------------------------------------------------------------
// Region abbreviation map
// -----------------------------------------------------------------------------

var regionAbbreviations = {
  // Azure Public
  eastus: 'eus'
  eastus2: 'eus2'
  westus: 'wus'
  westus2: 'wus2'
  westus3: 'wus3'
  centralus: 'cus'
  northcentralus: 'ncus'
  southcentralus: 'scus'
  westcentralus: 'wcus'
  canadacentral: 'cac'
  canadaeast: 'cae'
  brazilsouth: 'brs'
  brazilsoutheast: 'brse'
  northeurope: 'neu'
  westeurope: 'weu'
  uksouth: 'uks'
  ukwest: 'ukw'
  francecentral: 'frc'
  francesouth: 'frs'
  germanywestcentral: 'gwc'
  germanynorth: 'gno'
  norwayeast: 'noe'
  norwaywest: 'now'
  switzerlandnorth: 'szn'
  switzerlandwest: 'szw'
  swedencentral: 'swc'
  eastasia: 'eas'
  southeastasia: 'seas'
  australiaeast: 'aue'
  australiasoutheast: 'ause'
  australiacentral: 'auc'
  australiacentral2: 'auc2'
  japaneast: 'jpe'
  japanwest: 'jpw'
  koreacentral: 'krc'
  koreasouth: 'krs'
  southindia: 'ins'
  centralindia: 'inc'
  westindia: 'inw'
  jioindiawest: 'jiw'
  jioindiacentral: 'jic'
  uaenorth: 'uan'
  uaecentral: 'uac'
  southafricanorth: 'san'
  southafricawest: 'saw'
  qatarcentral: 'qac'
  // Azure Government
  usgovvirginia: 'va'
  usgovtexas: 'tx'
  usgovarizona: 'az'
  usdodeast: 'ude'
  usdodcentral: 'udc'
}

// -----------------------------------------------------------------------------
// Computed name components
// -----------------------------------------------------------------------------

var locationAbbr = useAzureRegionAbbr && contains(regionAbbreviations, location)
  ? regionAbbreviations[location]
  : location

var environmentShortMap = {
  hub: 'h'
  prod: 'p'
  nonprod: 'np'
  dev: 'd'
  test: 't'
  stage: 's'
  h: 'h'
  p: 'p'
  np: 'np'
  d: 'd'
  t: 't'
  s: 's'
}
var environmentShort = environmentShortMap[environment]

// Base name components (filter empties, then join)
var nameComponents = filter([prefix, workload, environment, locationAbbr], c => !empty(c))
var baseName = join(nameComponents, delimiter)

// Sanitized components use short environment, joined then delimiter stripped
var sanitizedComponents = filter([prefix, workload, environmentShort, locationAbbr], c => !empty(c))
var sanitizedBaseName = toLower(replace(join(sanitizedComponents, delimiter), delimiter, ''))

// -----------------------------------------------------------------------------
// CAF Resource Type Abbreviations
// -----------------------------------------------------------------------------

var abbreviations = {
  // AI + Machine Learning
  ai_search: 'srch'
  ai_services: 'ais'
  ai_foundry_account: 'aif'
  ai_foundry_account_project: 'proj'
  ai_foundry_hub: 'hub'
  ai_foundry_hub_project: 'proj'
  ai_video_indexer: 'avi'
  machine_learning_workspace: 'mlw'
  openai_service: 'oai'
  bot_service: 'bot'
  computer_vision: 'cv'
  content_moderator: 'cm'
  content_safety: 'cs'
  custom_vision_prediction: 'cstv'
  custom_vision_training: 'cstvt'
  document_intelligence: 'di'
  face_api: 'face'
  health_insights: 'hi'
  immersive_reader: 'ir'
  language_service: 'lang'
  speech_service: 'spch'
  translator: 'trsl'

  // Analytics and IoT
  analysis_services: 'as'
  databricks_access_connector: 'dbac'
  databricks_workspace: 'dbw'
  data_explorer_cluster: 'dec'
  data_explorer_database: 'dedb'
  data_factory: 'adf'
  digital_twin: 'dt'
  stream_analytics: 'asa'
  synapse_private_link_hub: 'synplh'
  synapse_sql_pool: 'syndp'
  synapse_spark_pool: 'synsp'
  synapse_workspace: 'synw'
  data_lake_store: 'dls'
  data_lake_analytics: 'dla'
  event_hub_namespace: 'evhns'
  event_hub: 'evh'
  event_grid_domain: 'evgd'
  event_grid_namespace: 'evgns'
  event_grid_subscription: 'evgs'
  event_grid_topic: 'evgt'
  event_grid_system_topic: 'egst'
  fabric_capacity: 'fc'
  hdinsight_hadoop_cluster: 'hadoop'
  hdinsight_hbase_cluster: 'hbase'
  hdinsight_kafka_cluster: 'kafka'
  hdinsight_spark_cluster: 'spark'
  hdinsight_storm_cluster: 'storm'
  hdinsight_ml_services_cluster: 'mls'
  iot_hub: 'iot'
  provisioning_services: 'provs'
  provisioning_services_certificate: 'pcert'
  power_bi_embedded: 'pbi'
  time_series_insights: 'tsi'

  // Compute and Web
  app_service_environment: 'ase'
  app_service_plan: 'asp'
  load_testing: 'lt'
  availability_set: 'avail'
  arc_enabled_server: 'arcs'
  arc_enabled_kubernetes: 'arck'
  arc_private_link_scope: 'pls'
  arc_gateway: 'arcgw'
  batch_account: 'ba'
  cloud_service: 'cld'
  communication_services: 'acs'
  disk_encryption_set: 'des'
  function_app: 'func'
  gallery: 'gal'
  hosting_environment: 'host'
  image_template: 'it'
  managed_disk_os: 'dsk-os'
  managed_disk_data: 'dsk-data'
  notification_hub: 'ntf'
  notification_hub_namespace: 'ntfns'
  proximity_placement_group: 'ppg'
  restore_point_collection: 'rpc'
  snapshot: 'snap'
  static_web_app: 'stapp'
  virtual_machine: 'vm'
  virtual_machine_scale_set: 'vmss'
  vm_maintenance_configuration: 'mc'
  vm_storage_account: 'stvm'
  web_app: 'app'

  // Containers
  aks_cluster: 'aks'
  aks_system_node_pool: 'npsystem'
  aks_user_node_pool: 'np'
  container_app: 'ca'
  container_app_environment: 'cae'
  container_app_job: 'caj'
  container_registry: 'cr'
  container_instance: 'ci'
  service_fabric_cluster: 'sf'
  service_fabric_managed_cluster: 'sfmc'

  // Databases
  cosmos_db: 'cosmos'
  cosmos_db_cassandra: 'coscas'
  cosmos_db_mongodb: 'cosmon'
  cosmos_db_nosql: 'cosno'
  cosmos_db_table: 'costab'
  cosmos_db_gremlin: 'cosgrm'
  cosmos_db_postgresql: 'cospos'
  redis_cache: 'redis'
  managed_redis: 'amr'
  sql_server: 'sql'
  sql_database: 'sqldb'
  sql_elastic_job_agent: 'sqlja'
  sql_elastic_pool: 'sqlep'
  mysql_database: 'mysql'
  postgresql_database: 'psql'
  sql_stretch_database: 'sqlstrdb'
  sql_managed_instance: 'sqlmi'

  // Developer Tools
  app_configuration: 'appcs'
  maps_account: 'map'
  signalr: 'sigr'
  web_pubsub: 'wps'

  // DevOps
  managed_grafana: 'amg'

  // Integration
  api_management: 'apim'
  integration_account: 'ia'
  logic_app: 'logic'
  service_bus_namespace: 'sbns'
  service_bus_queue: 'sbq'
  service_bus_topic: 'sbt'
  service_bus_topic_subscription: 'sbts'

  // Management and Governance
  automation_account: 'aa'
  application_insights: 'appi'
  monitor_action_group: 'ag'
  monitor_data_collection_rule: 'dcr'
  monitor_alert_processing_rule: 'apr'
  blueprint: 'bp'
  blueprint_assignment: 'bpa'
  data_collection_endpoint: 'dce'
  deployment_script: 'script'
  log_analytics_workspace: 'log'
  log_analytics_query_pack: 'pack'
  management_group: 'mg'
  subscription_name: 'sub'
  purview: 'pview'
  resource_group: 'rg'
  template_spec: 'ts'

  // Migration
  migrate_project: 'migr'
  database_migration_service: 'dms'
  recovery_services_vault: 'rsv'

  // Networking
  application_gateway: 'agw'
  application_security_group: 'asg'
  cdn_profile: 'cdnp'
  cdn_endpoint: 'cdne'
  connection: 'con'
  dns_forwarding_ruleset: 'dnsfrs'
  dns_private_resolver: 'dnspr'
  dns_resolver_inbound_endpoint: 'in'
  dns_resolver_outbound_endpoint: 'out'
  firewall: 'afw'
  firewall_policy: 'afwp'
  expressroute_circuit: 'erc'
  expressroute_direct: 'erd'
  expressroute_gateway: 'ergw'
  front_door_profile: 'afd'
  front_door_endpoint: 'fde'
  front_door_firewall_policy: 'fdfp'
  front_door_classic: 'afdc'
  ip_group: 'ipg'
  load_balancer_internal: 'lbi'
  load_balancer_external: 'lbe'
  load_balancer_rule: 'rule'
  local_network_gateway: 'lgw'
  nat_gateway: 'ng'
  network_interface: 'nic'
  network_security_perimeter: 'nsp'
  network_security_group: 'nsg'
  network_security_group_rule: 'nsgsr'
  network_watcher: 'nw'
  private_link: 'pl'
  private_endpoint: 'pep'
  public_ip: 'pip'
  public_ip_prefix: 'ippre'
  route_filter: 'rf'
  route_server: 'rtserv'
  route_table: 'rt'
  service_endpoint_policy: 'se'
  traffic_manager: 'traf'
  user_defined_route: 'udr'
  virtual_network: 'vnet'
  virtual_network_gateway: 'vgw'
  virtual_network_manager: 'vnm'
  virtual_network_peering: 'peer'
  subnet: 'snet'
  virtual_wan: 'vwan'
  virtual_wan_hub: 'vhub'

  // Security
  bastion: 'bas'
  key_vault: 'kv'
  key_vault_managed_hsm: 'kvmhsm'
  managed_identity: 'id'
  ssh_key: 'sshkey'
  vpn_gateway: 'vpng'
  vpn_connection: 'vcn'
  vpn_site: 'vst'
  waf_policy: 'waf'
  waf_policy_rule_group: 'wafrg'

  // Storage
  storsimple: 'ssimp'
  backup_vault: 'bvault'
  backup_vault_policy: 'bkpol'
  file_share: 'share'
  storage_account: 'st'
  storage_sync_service: 'sss'

  // Virtual Desktop Infrastructure
  virtual_desktop_host_pool: 'vdpool'
  virtual_desktop_application_group: 'vdag'
  virtual_desktop_workspace: 'vdws'
  virtual_desktop_scaling_plan: 'vdscaling'
}

// -----------------------------------------------------------------------------
// Helpers (Bicep has no functions; use variables + ternaries)
// -----------------------------------------------------------------------------
// Standard hyphenated name: {cloud}-{abbr}-{base}
//   join(filter([cloud, abbr, base], !empty), delimiter)
//
// Sanitized name: {cloud}{abbr}{sanitizedBase} truncated and lowercased.
//   substring requires length<=string length; use ternary to clamp.

// -----------------------------------------------------------------------------
// Standard names (with hyphens, full pattern)
// -----------------------------------------------------------------------------

var standardNames = toObject(
  items(abbreviations),
  entry => entry.key,
  entry => toLower(join(filter([cloudAcronym, entry.value, baseName], c => !empty(c)), delimiter))
)

// -----------------------------------------------------------------------------
// Clean names (length-restricted; some with no hyphens)
// -----------------------------------------------------------------------------
// Truncation helper inlined: substring(s, 0, length(s) > max ? max : length(s))

// No-hyphen sanitized names (alphanumeric only, length capped)
var st_full = toLower('${cloudAcronym}${abbreviations.storage_account}${sanitizedBaseName}')
var storageAccountName = substring(st_full, 0, length(st_full) > 24 ? 24 : length(st_full))

var cr_full = toLower('${cloudAcronym}${abbreviations.container_registry}${sanitizedBaseName}')
var containerRegistryName = substring(cr_full, 0, length(cr_full) > 50 ? 50 : length(cr_full))

var ba_full = toLower('${cloudAcronym}${abbreviations.batch_account}${sanitizedBaseName}')
var batchAccountName = substring(ba_full, 0, length(ba_full) > 24 ? 24 : length(ba_full))

var as_full = toLower('${cloudAcronym}${abbreviations.analysis_services}${sanitizedBaseName}')
var analysisServicesName = substring(as_full, 0, length(as_full) > 63 ? 63 : length(as_full))

// Hyphenated but length-capped names
var kv_full = standardNames.key_vault
var keyVaultName = substring(kv_full, 0, length(kv_full) > 24 ? 24 : length(kv_full))

var kvhsm_full = standardNames.key_vault_managed_hsm
var keyVaultManagedHsmName = substring(kvhsm_full, 0, length(kvhsm_full) > 24 ? 24 : length(kvhsm_full))

var cosmos_full = standardNames.cosmos_db
var cosmosDbName = substring(cosmos_full, 0, length(cosmos_full) > 44 ? 44 : length(cosmos_full))

var sqlsrv_full = standardNames.sql_server
var sqlServerName = substring(sqlsrv_full, 0, length(sqlsrv_full) > 63 ? 63 : length(sqlsrv_full))

var sqlmi_full = standardNames.sql_managed_instance
var sqlManagedInstanceName = substring(sqlmi_full, 0, length(sqlmi_full) > 63 ? 63 : length(sqlmi_full))

var dbw_full = standardNames.databricks_workspace
var databricksWorkspaceName = substring(dbw_full, 0, length(dbw_full) > 30 ? 30 : length(dbw_full))

var mlw_full = standardNames.machine_learning_workspace
var machineLearningWorkspaceName = substring(mlw_full, 0, length(mlw_full) > 33 ? 33 : length(mlw_full))

var func_full = standardNames.function_app
var functionAppName = substring(func_full, 0, length(func_full) > 60 ? 60 : length(func_full))

var web_full = standardNames.web_app
var webAppName = substring(web_full, 0, length(web_full) > 60 ? 60 : length(web_full))

var asp_full = standardNames.app_service_plan
var appServicePlanName = substring(asp_full, 0, length(asp_full) > 40 ? 40 : length(asp_full))

var stapp_full = standardNames.static_web_app
var staticWebAppName = substring(stapp_full, 0, length(stapp_full) > 40 ? 40 : length(stapp_full))

var aks_full = standardNames.aks_cluster
var aksClusterName = substring(aks_full, 0, length(aks_full) > 63 ? 63 : length(aks_full))

var ca_full = standardNames.container_app
var containerAppName = substring(ca_full, 0, length(ca_full) > 32 ? 32 : length(ca_full))

var cae_full = standardNames.container_app_environment
var containerAppEnvironmentName = substring(cae_full, 0, length(cae_full) > 60 ? 60 : length(cae_full))

var ci_full = standardNames.container_instance
var containerInstanceName = substring(ci_full, 0, length(ci_full) > 63 ? 63 : length(ci_full))

var vm_full = standardNames.virtual_machine
var virtualMachineName = substring(vm_full, 0, length(vm_full) > 64 ? 64 : length(vm_full))

var vmss_full = standardNames.virtual_machine_scale_set
var virtualMachineScaleSetName = substring(vmss_full, 0, length(vmss_full) > 64 ? 64 : length(vmss_full))

var apim_full = standardNames.api_management
var apiManagementName = substring(apim_full, 0, length(apim_full) > 50 ? 50 : length(apim_full))

var sbns_full = standardNames.service_bus_namespace
var serviceBusNamespaceName = substring(sbns_full, 0, length(sbns_full) > 50 ? 50 : length(sbns_full))

var evhns_full = standardNames.event_hub_namespace
var eventHubNamespaceName = substring(evhns_full, 0, length(evhns_full) > 50 ? 50 : length(evhns_full))

var iot_full = standardNames.iot_hub
var iotHubName = substring(iot_full, 0, length(iot_full) > 50 ? 50 : length(iot_full))

var synw_full = standardNames.synapse_workspace
var synapseWorkspaceName = substring(synw_full, 0, length(synw_full) > 50 ? 50 : length(synw_full))

var adf_full = standardNames.data_factory
var dataFactoryName = substring(adf_full, 0, length(adf_full) > 63 ? 63 : length(adf_full))

var logws_full = standardNames.log_analytics_workspace
var logAnalyticsWorkspaceName = substring(logws_full, 0, length(logws_full) > 63 ? 63 : length(logws_full))

var rg_full = standardNames.resource_group
var resourceGroupName = substring(rg_full, 0, length(rg_full) > 90 ? 90 : length(rg_full))

var rsv_full = standardNames.recovery_services_vault
var recoveryServicesVaultName = substring(rsv_full, 0, length(rsv_full) > 50 ? 50 : length(rsv_full))

var bvault_full = standardNames.backup_vault
var backupVaultName = substring(bvault_full, 0, length(bvault_full) > 50 ? 50 : length(bvault_full))

var afd_full = standardNames.front_door_profile
var frontDoorProfileName = substring(afd_full, 0, length(afd_full) > 64 ? 64 : length(afd_full))

// -----------------------------------------------------------------------------
// Merged names object (clean overrides for strict-rule resources)
// -----------------------------------------------------------------------------

var names = union(standardNames, {
  storage_account: storageAccountName
  container_registry: containerRegistryName
  batch_account: batchAccountName
  analysis_services: analysisServicesName
  key_vault: keyVaultName
  key_vault_managed_hsm: keyVaultManagedHsmName
  cosmos_db: cosmosDbName
  sql_server: sqlServerName
  sql_managed_instance: sqlManagedInstanceName
  databricks_workspace: databricksWorkspaceName
  machine_learning_workspace: machineLearningWorkspaceName
  function_app: functionAppName
  web_app: webAppName
  app_service_plan: appServicePlanName
  static_web_app: staticWebAppName
  aks_cluster: aksClusterName
  container_app: containerAppName
  container_app_environment: containerAppEnvironmentName
  container_instance: containerInstanceName
  virtual_machine: virtualMachineName
  virtual_machine_scale_set: virtualMachineScaleSetName
  api_management: apiManagementName
  service_bus_namespace: serviceBusNamespaceName
  event_hub_namespace: eventHubNamespaceName
  iot_hub: iotHubName
  synapse_workspace: synapseWorkspaceName
  data_factory: dataFactoryName
  log_analytics_workspace: logAnalyticsWorkspaceName
  resource_group: resourceGroupName
  recovery_services_vault: recoveryServicesVaultName
  backup_vault: backupVaultName
  front_door_profile: frontDoorProfileName
})

// -----------------------------------------------------------------------------
// VM hostname format: {cloudShort}{locationAbbr}{os}{appName}{envShort}
// e.g. "azeus2lautopd"
// -----------------------------------------------------------------------------

var vmCloudAcronymShort = cloudAcronym == 'azg' ? 'ag' : 'az'
var vmHostname = (!empty(vmApplicationName) && !empty(vmOsType))
  ? toLower('${vmCloudAcronymShort}${locationAbbr}${vmOsType}${vmApplicationName}${environmentShort}')
  : ''

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------

@description('Base name without resource type abbreviation.')
output baseName string = baseName

@description('Sanitized base name (no delimiters) for resources with strict rules.')
output sanitizedBaseName string = sanitizedBaseName

@description('Location abbreviation actually used.')
output locationAbbr string = locationAbbr

@description('Map of all generated Azure resource names keyed by snake_case resource type.')
output names object = names

// Convenience outputs (commonly used resources, camelCase Bicep style)
output resourceGroup string = names.resource_group
output storageAccount string = names.storage_account
output keyVault string = names.key_vault
output containerRegistry string = names.container_registry
output virtualNetwork string = names.virtual_network
output subnet string = names.subnet
output networkSecurityGroup string = names.network_security_group
output networkInterface string = names.network_interface
output publicIp string = names.public_ip
output applicationGateway string = names.application_gateway
output firewall string = names.firewall
output loadBalancerInternal string = names.load_balancer_internal
output loadBalancerExternal string = names.load_balancer_external
output routeTable string = names.route_table
output privateEndpoint string = names.private_endpoint
output bastion string = names.bastion
output managedIdentity string = names.managed_identity
output appServicePlan string = names.app_service_plan
output webApp string = names.web_app
output functionApp string = names.function_app
output staticWebApp string = names.static_web_app
output aksCluster string = names.aks_cluster
output containerApp string = names.container_app
output containerAppEnvironment string = names.container_app_environment
output containerInstance string = names.container_instance
output virtualMachine string = names.virtual_machine
output virtualMachineScaleSet string = names.virtual_machine_scale_set
output managedDiskOs string = names.managed_disk_os
output managedDiskData string = names.managed_disk_data
output sqlServer string = names.sql_server
output sqlDatabase string = names.sql_database
output cosmosDb string = names.cosmos_db
output redisCache string = names.redis_cache
output mysqlDatabase string = names.mysql_database
output postgresqlDatabase string = names.postgresql_database
output logAnalyticsWorkspace string = names.log_analytics_workspace
output applicationInsights string = names.application_insights
output automationAccount string = names.automation_account
output dataFactory string = names.data_factory
output databricksWorkspace string = names.databricks_workspace
output synapseWorkspace string = names.synapse_workspace
output iotHub string = names.iot_hub
output eventHubNamespace string = names.event_hub_namespace
output eventHub string = names.event_hub
output serviceBusNamespace string = names.service_bus_namespace
output apiManagement string = names.api_management
output logicApp string = names.logic_app
output machineLearningWorkspace string = names.machine_learning_workspace
output openaiService string = names.openai_service
output aiSearch string = names.ai_search
output aiServices string = names.ai_services
output fileShare string = names.file_share
output backupVault string = names.backup_vault
output recoveryServicesVault string = names.recovery_services_vault
output frontDoorProfile string = names.front_door_profile
output vpnGateway string = names.vpn_gateway

@description('Custom VM hostname (empty if vmOsType or vmApplicationName not provided).')
output vmHostname string = vmHostname

@description('VM hostname details.')
output vmDetails object = {
  hostname: vmHostname
  cloudAcronymShort: vmCloudAcronymShort
  location: locationAbbr
  osType: vmOsType
  applicationName: vmApplicationName
  environmentShort: environmentShort
}

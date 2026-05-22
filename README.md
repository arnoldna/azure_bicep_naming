# Azure Bicep Naming Module

Bicep port of `azure-tf-naming`. Generates standardized Azure resource names following the pattern:

```text
<cloudAcronym>-<abbreviation>-<prefix>-<workload>-<environment>-<location>
```

All inputs are optional; empty components are filtered out. "Clean" names (no hyphens, length-limited) are produced automatically for resources with strict naming rules (Storage Account, Container Registry, Key Vault, AKS, etc.).

## Quick start

```bicep
module naming './naming.bicep' = {
  name: 'naming'
  params: {
    cloudAcronym: 'azu'
    prefix: 'contoso'
    workload: 'web'
    environment: 'p'
    location: 'eastus2'
    useAzureRegionAbbr: true
  }
}

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: naming.outputs.resourceGroup   // azu-rg-contoso-web-p-eus2
  location: 'eastus2'
}

resource sa 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: naming.outputs.storageAccount  // azustcontosowebpeus2 (<=24, alnum only)
  location: rg.location
  // ...
}
```

## Parameters

| Name | Type | Default | Description |
|---|---|---|---|
| `cloudAcronym` | string | `azu` | `azu` (Commercial) or `azg` (Government). |
| `prefix` | string | `''` | Company / project identifier. Lowercase alphanumeric. |
| `workload` | string | `''` | Application / workload name. Lowercase alphanumeric. |
| `environment` | string | `d` | `h/hub`, `p/prod`, `np/nonprod`, `d/dev`, `t/test`, `s/stage`. |
| `location` | string | `''` | Azure region code (e.g., `eastus`, `usgovvirginia`). |
| `delimiter` | string | `-` | Separator between components. |
| `useAzureRegionAbbr` | bool | `false` | Use short region codes (`eus` for `eastus`). |
| `vmOsType` | string | `''` | `l` (Linux) or `w` (Windows) for VM hostname format. |
| `vmApplicationName` | string | `''` | 3-6 char app name for VM hostname format. |

## Outputs

The module exposes two kinds of outputs:

- `names` — object map keyed by snake_case resource type (matches the Terraform module's `names` map). Useful when consuming many names at once.
- Convenience camelCase outputs for the most common resources (`resourceGroup`, `storageAccount`, `keyVault`, `aksCluster`, etc.).

### Examples

| Inputs | `resourceGroup` | `storageAccount` | `keyVault` |
|---|---|---|---|
| `azu / contoso / webapp / prod / eastus2` (abbr) | `azu-rg-contoso-webapp-prod-eus2` | `azustcontosowebapppeus2` | `azu-kv-contoso-webapp-pr` |
| `azu / app / dev` (no prefix) | `azu-rg-app-dev` | `azustappd` | `azu-kv-app-dev` |
| `azg / dod / mission / prod / usgovvirginia` (abbr) | `azg-rg-dod-mission-prod-va` | `azgstdodmissionpva` | `azg-kv-dod-mission-pro` |

## Differences vs the Terraform module

Bicep has fewer string-manipulation primitives than Terraform, so the port makes a couple of conscious trade-offs:

1. **No regex sanitation.** Terraform uses `replace(..., "/[^a-z0-9-]/", "")` to strip invalid characters. Bicep's `replace()` is literal-only. Inputs are constrained by `@allowed` / `@maxLength` decorators and assumed to be lowercase alphanumeric (matching the TF validation rules), so no regex is required.
2. **`substring` clamping inlined.** Bicep's `substring()` throws if the requested length exceeds the string length, so each length-restricted name uses an inline `length(s) > max ? max : length(s)` pattern.
3. **`union()` instead of `merge()`.** Used to overlay clean names onto the standard-name map.
4. **VM hostname** is provided as a single combined output (`vmHostname`) plus a `vmDetails` object; if either `vmOsType` or `vmApplicationName` is empty, `vmHostname` is `''`.

## Building / validating

```pwsh
az bicep build --file naming.bicep
```

Or via the Bicep CLI directly:

```pwsh
bicep build naming.bicep
```

## See also

- [Microsoft CAF resource abbreviations](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Azure resource naming rules](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- Companion Terraform module: `../azure-tf-naming/`

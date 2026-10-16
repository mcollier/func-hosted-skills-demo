targetScope = 'subscription'

param connectorGatewayName string
// param connectionName string = 'office365-outlook'
// param mcpServerConfigName string = 'Office-365-Outlook-send-email-only'
param location string
param tags object = {}
// param managedIdentityPrincipalId string = deployer().objectId
// param deployerPrincipalId string = deployer().objectId
param tenantId string = tenant().tenantId

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

var abbreviations = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))


resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbreviations.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

module connectorGateway 'connectorGateway.bicep' = {
  name: 'connectorGateway'
  scope: rg
  params: {
    connectorGatewayName: connectorGatewayName
    location: location
    tags: tags
  }
}

// NOTE: the commented resources below reference the gateway as a resource;
// when enabled, move them into connectorGateway.bicep (or a new module scoped to rg).

// resource office365Connection 'Microsoft.Web/connectorGateways/connections@2026-05-01-preview' = {
//   parent: connectorGateway
//   name: connectionName
//   properties: {
//     connectorName: 'office365'
//     displayName: 'Office 365 Outlook Connection'
//   }
// }

// resource office365ConnectionAccessPolicy 'Microsoft.Web/connectorGateways/connections/accessPolicies@2026-05-01-preview' = {
//   parent: office365Connection
//   name: managedIdentityPrincipalId
//   properties: {
//     principal: {
//       type: 'ActiveDirectory'
//       identity: {
//         objectId: managedIdentityPrincipalId
//         tenantId: tenantId
//       }
//     }
//   }
// }

// resource office365ConnectionDeployerAccessPolicy 'Microsoft.Web/connectorGateways/connections/accessPolicies@2026-05-01-preview' = {
//   parent: office365Connection
//   name: deployerPrincipalId
//   properties: {
//     principal: {
//       type: 'ActiveDirectory'
//       identity: {
//         objectId: deployerPrincipalId
//         tenantId: tenantId
//       }
//     }
//   }
// }

// resource office365McpServerConfig 'Microsoft.Web/connectorGateways/mcpserverconfigs@2026-05-01-preview' = {
//   parent: connectorGateway
//   name: mcpServerConfigName
//   properties: {
//     state: 'Enabled'
//     description: 'Microsoft Office 365 is a cloud-based service that is designed to help meet your organization\'s needs for robust security, reliability, and user productivity.'
//     connectors: [
//       {
//         name: 'office365'
//         connectionName: office365Connection.name
//         displayName: 'Office 365 Outlook'
//         description: ''
//         operations: [
//           {
//             name: 'SendEmailV2'
//             displayName: 'Send an email'
//             description: 'This operation sends an email message.'
//             userParameters: []
//             agentParameters: [
//               {
//                 name: 'emailMessage'
//                 schema: {
//                   type: 'object'
//                   properties: {
//                     To: {
//                       type: 'string'
//                       format: 'email'
//                       description: 'Specify email addresses separated by semicolons like someone@contoso.com'
//                       required: true
//                     }
//                     Subject: {
//                       type: 'string'
//                       description: 'Specify the subject of the mail'
//                       required: true
//                     }
//                     Body: {
//                       type: 'string'
//                       format: 'html'
//                       description: 'Specify the body of the mail'
//                       required: true
//                     }
//                   }
//                 }
//               }
//             ]
//           }
//         ]
//       }
//     ]
//     policies: []
//     settings: {
//       textOnlyContent: true
//     }
//   }
// }

output resourceGroupName string = rg.name
output connectorGatewayName string = connectorGateway.outputs.name
// output connectionId string = office365Connection.id
// output connectionAccessPolicyId string = office365ConnectionAccessPolicy.id
// output deployerConnectionAccessPolicyId string = office365ConnectionDeployerAccessPolicy.id
// output mcpEndpointUrl string = office365McpServerConfig.properties.mcpEndpointUrl

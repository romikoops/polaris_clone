import getConfig from './config.constants'

export function getApiHost () {
  return `${getConfig().api_url}/tenant`
}

export function getTenantApiUrl () {
  const { localStorage } = window
  const id = localStorage.getItem('overrideTenantId') ? localStorage.getItem('overrideTenantId') : localStorage.getItem('tenantId')

  return `${getConfig().api_url}/tenants/${id}`
}

export function getTenantIndex () {
  return `${getConfig().api_url}/tenants`
}

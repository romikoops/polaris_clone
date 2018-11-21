import getConfig from './config.constants'

export function getApiHost () {
  return `${getConfig().api_url}/tenant`
}

export function getTenantApiUrl () {
  const { localStorage } = window

  return `${getConfig().api_url}/tenants/${localStorage.getItem('tenantId')}`
}

export function getTenantIndex () {
  return `${getConfig().api_url}/tenants`
}

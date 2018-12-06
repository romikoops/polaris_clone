import getConfig from './config.constants'

export function getApiHost () {
  return `${getConfig().api_url}`
}

export function getTenantApiUrl () {
  const { localStorage } = window
  const id = localStorage.getItem('tenantId')

  return `${getConfig().api_url}/tenants/${id}`
}

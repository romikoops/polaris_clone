import getConfig from '../constants/config.constants'

export function getApiHost () {
  return `${getConfig().api_url}/tenant`
}

export function getTenantApiUrl () {
  const { localStorage } = window

  return `${getConfig().api_url}/tenants/${localStorage.getItem('tenantId')}`
}

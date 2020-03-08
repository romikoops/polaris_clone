import getConfig from './config.constants'

export function getApiHost () {
  return `${getConfig().apiUrl}`
}

export function getTenantApiUrl () {
  const { localStorage } = window
  const id = localStorage.getItem('tenantId')

  return `${getConfig().apiUrl}/tenants/${id}`
}

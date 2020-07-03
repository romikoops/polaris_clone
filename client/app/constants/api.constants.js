import getConfig from './config.constants'

export function getApiHost () {
  return `${getConfig().apiUrl}`
}

export function getTenantApiUrl () {
  const { localStorage } = window
  const id = localStorage.getItem('organizationId')

  return `${getConfig().apiUrl}/organizations/${id}`
}

import getConfig from '../constants/config.constants'

export function getApiHost () {
  return `${getConfig().api_url}/tenants`
}

export function getFullApiHost () {
  const { localStorage } = window
  const url = localStorage.getItem('tenantUrl')

  return url
}

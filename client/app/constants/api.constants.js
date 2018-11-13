import getConfig from '../constants/config.constants'
import { store } from '../helpers'

export function getApiHost () {
  return `${getConfig().api_url}/tenants`
}

export function getFullApiHost () {
  const s = store
  // debugger // eslint-disable-line no-debugger
  if (!s.getState().app.test) return ''

  return store.getState().app.test.data.url
}

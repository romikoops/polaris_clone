import { moment } from '../constants'

const { localStorage } = window

export function authHeader () {
  const aHeader = JSON.parse(localStorage.getItem('authHeader'))
  const sandbox = localStorage.getItem('sandbox')
  if (aHeader && moment().isBefore(moment.unix(aHeader.expiry))) {
    aHeader.sandbox = sandbox

    return aHeader
  }

  return {}
}

export default authHeader

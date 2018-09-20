import getConfig from '../constants/config.constants'

export function getSubdomain () {
  return getConfig().tenant
}

export default getSubdomain

import getConfig from '../constants/config.constants'

export default function getSubdomain () {
  return getConfig().tenant
}

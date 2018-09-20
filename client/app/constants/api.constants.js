import getConfig from '../constants/config.constants'
import getSubdomain from '../helpers/subdomain'

export default function getApiHost () {
  return `${getConfig().api_url}/subdomain/${getSubdomain()}`
}

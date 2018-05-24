import { getSubdomain } from '../helpers/subdomain'

let url

const subdomainKey = getSubdomain()
if (process.env.NODE_ENV === 'production') {
  url = 'https://api2.itsmycargo.com'
  // url = 'https://devapi.itsmycargo.com'
} else {
  url = 'http://localhost:3000'
  // url = 'https://api2.itsmycargo.com'
  // url = 'https://devapi.itsmycargo.com'
  // url = 'http://192.168.178.43:3000'
  // url = 'https://api2.itsmycargo.com'
  // url = 'http://imcr-staging.edrmpdsn2j.eu-central-1.elasticbeanstalk.com';
}
export const BASE_URL = `${url}/subdomain/${subdomainKey}`

export default BASE_URL

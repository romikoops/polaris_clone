let url;
import { getSubdomain } from '../helpers/subdomain';
const subdomainKey = getSubdomain();
if (process.env.NODE_ENV === 'production') {
    url = 'https://api2.itsmycargo.com';
} else {
    url = 'http://localhost:3000';
    // url = 'https://api2.itsmycargo.com';
    // url = 'http://imcr-staging.edrmpdsn2j.eu-central-1.elasticbeanstalk.com';
}
export const BASE_URL = url + '/subdomain/' + subdomainKey;
// export const BASE_URL = url;

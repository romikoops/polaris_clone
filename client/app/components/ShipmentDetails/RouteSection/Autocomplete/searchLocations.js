import { getTenantApiUrl } from '../../../../constants/api.constants'
import { authHeader } from '../../../../helpers'

const { fetch } = window
export default function searchLocations (input, countries, timestamp, callback) {
  fetch(
    `${getTenantApiUrl()}/locations?query=${input}&countries=${countries}`,
    {
      method: 'GET',
      headers: authHeader()
    }
  ).then((promise) => {
    promise.json().then((response) => {
      if (response.data) {
        const {
          results
        } = response.data
        callback(results, timestamp)
      } else {
        callback([])
      }
    })
  })
}

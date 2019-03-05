import { getTenantApiUrl } from '../../../../constants/api.constants'
import { authHeader } from '../../../../helpers'

const { fetch } = window

function findAvailability (lat, lng, loadType, carriage, availableHubIds, callback) {
  fetch(
    `${getTenantApiUrl()}/trucking_availability?` +
      `lat=${lat}&lng=${lng}&` +
      `load_type=${loadType}&` +
      `carriage=${carriage}&` +
      `hub_ids=${availableHubIds}`,
    {
      method: 'GET',
      headers: authHeader()
    }
  ).then((promise) => {
    promise.json().then((response) => {
      if (response.data) {
        const {
          truckingAvailable, nexusIds, hubIds, truckTypeObject
        } = response.data
        callback(truckingAvailable, nexusIds, hubIds, truckTypeObject)
      } else {
        callback(false, [], [], {})
      }
    })
  }).catch(() => {
    callback(false, [], [], {})
  })
}

const getRequests = {
  findAvailability
}

export default getRequests

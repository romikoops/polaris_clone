import { BASE_URL } from '../../constants'
import { authHeader } from '../../helpers'

const { fetch } = window

function findNexus (lat, lng, callback) {
  fetch(`${BASE_URL}/find_nexus?lat=${lat}&lng=${lng}`, {
    method: 'GET',
    headers: authHeader()
  }).then((promise) => {
    promise.json().then((response) => {
      callback(response.data.nexus)
    })
  })
}

function findAvailability (lat, lng, tenantId, loadType, availableNexusesIds, direction, callback) {
  fetch(
    `${BASE_URL}/trucking_availability?` +
      `lat=${lat}&lng=${lng}&` +
      `tenant_id=${tenantId}&` +
      `load_type=${loadType}&` +
      `nexus_ids=${availableNexusesIds}&` +
      `direction=${direction}`,
    {
      method: 'GET',
      headers: authHeader()
    }
  ).then((promise) => {
    promise.json().then((response) => {
      const { truckingAvailable, nexusIds } = response.data
      callback(truckingAvailable, nexusIds)
    })
  })
}

function nexuses (nexusIds, target, itineraryIds, callback) {
  fetch(
    `${BASE_URL}/nexuses?` +
      `itinerary_ids=${itineraryIds}&` +
      `target=${target}&` +
      `nexus_ids=${nexusIds}`,
    {
      method: 'GET',
      headers: authHeader()
    }
  ).then((promise) => {
    promise.json().then((response) => {
      callback(response.data)
    })
  })
}

const getRequests = {
  findNexus,
  findAvailability,
  nexuses
}

export default getRequests

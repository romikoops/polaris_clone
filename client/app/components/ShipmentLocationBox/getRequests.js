import { getTenantApiUrl } from '../../constants/api.constants'
import { authHeader } from '../../helpers'

const { fetch } = window

function findNexus (lat, lng, callback) {
  fetch(`${getTenantApiUrl()}/find_nexus?lat=${lat}&lng=${lng}`, {
    method: 'GET',
    headers: authHeader()
  }).then((promise) => {
    promise.json().then((response) => {
      callback(response.data.nexus)
    })
  })
}

function findAvailability (lat, lng, tenantId, loadType, carriage, availableHubIds, callback) {
  fetch(
    `${getTenantApiUrl()}/trucking_availability?` +
      `lat=${lat}&lng=${lng}&` +
      `tenant_id=${tenantId}&` +
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

function searchLocations (input, countries, timestamp, callback) {
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

function findTruckTypes (originNexusIds, destinationNexusIds, callback) {
  fetch(
    `${getTenantApiUrl()}/truck_type_availability?` +
      `origin_nexus_ids=${originNexusIds}&` +
      `destination_nexus_ids=${destinationNexusIds}`,
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

function nexuses (nexusIds, hubIds, target, itineraryIds, callback) {
  fetch(
    `${getTenantApiUrl()}/nexuses?` +
      `itinerary_ids=${itineraryIds}&` +
      `target=${target}&` +
      `nexus_ids=${nexusIds}&` +
      `hub_ids=${hubIds}`,
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

function incoterms (direction, preCarriage, onCarriage, callback) {
  fetch(
    `${getTenantApiUrl()}/incoterms?` +
      `pre_carriage=${preCarriage}&` +
      `on_carriage=${onCarriage}&` +
      `direction=${direction}`,
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
  nexuses,
  incoterms,
  findTruckTypes,
  searchLocations
}

export default getRequests

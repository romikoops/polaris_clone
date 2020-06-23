import { get } from 'lodash'
import { getTenantApiUrl } from '../../../../constants/api.constants'
import { authHeader, toSnakeQueryString } from '../../../../helpers'

const { fetch } = window

function findAvailability (lat, lng, loadType, carriage, availableHubIds, callback) {
  return fetch(
    `${getTenantApiUrl()}/trucking_availability?` +
      `lat=${lat}&lng=${lng}&` +
      `load_type=${loadType}&` +
      `carriage=${carriage}&` +
      `hub_ids=${availableHubIds}`,
    {
      method: 'GET',
      headers: authHeader()
    }
  ).then((promise) => promise.json()).then((response) => callback(
    get(response, 'data.truckingAvailable', false),
    get(response, 'data.hubIds', [])
  )).catch(() => callback(false, [])) // eslint-disable-line standard/no-callback-literal
}

function counterpartCountries (target, args) {
  const queryArgs = { ...args, target }

  return fetch(`${getTenantApiUrl()}/trucking_counterparts?${toSnakeQueryString(queryArgs, true)}`,
    {
      method: 'GET',
      headers: authHeader()
    }).then((response) => response.json()).then((response) => {
    if (response.data) {
      return response.data
    }

    return []
  })
}

const getRequests = {
  findAvailability,
  counterpartCountries
}

export default getRequests

import { Promise } from 'es6-promise-promise'
import { getTenantApiUrl } from '../constants/api.constants'
import { authHeader } from '../helpers'

const { fetch } = window

function handleResponse (response) {
  const promise = Promise
  const respJSON = response.json()
  if (!response.ok) {
    return promise.reject(respJSON)
  }

  return respJSON
}

function getMapData (id) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ id })
  }

  return fetch(`${getTenantApiUrl()}/admin/maps/geojsons`, requestOptions).then(handleResponse)
}

const mapService = {
  getMapData
}

export default mapService

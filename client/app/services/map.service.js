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
    method: 'GET',
    headers: { ...authHeader() }
  }

  return fetch(`${getTenantApiUrl()}/admin/maps/geojsons?id=${id}`, requestOptions).then(handleResponse)
}
function getGeoJson (id) {
  const requestOptions = {
    method: 'GET',
    headers: { ...authHeader() }
  }

  return fetch(`${getTenantApiUrl()}/admin/maps/geojson?id=${id}`, requestOptions).then(handleResponse)
}

const mapService = {
  getMapData,
  getGeoJson
}

export default mapService

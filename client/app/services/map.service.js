import { Promise } from 'es6-promise-promise'
import { getTenantApiUrl } from '../constants/api.constants'
import { authHeader, toQueryString } from '../helpers'

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

function getEditorMapData (args) {
  const requestOptions = {
    method: 'GET',
    headers: { ...authHeader() }
  }
  const queryString = toQueryString(args, true)

  return fetch(`${getTenantApiUrl()}/admin/maps/editor_map_data?${queryString}`, requestOptions).then(handleResponse)
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
  getGeoJson,
  getEditorMapData
}

export default mapService

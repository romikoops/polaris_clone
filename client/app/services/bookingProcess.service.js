import { Promise } from 'es6-promise-promise'
import { getTenantApiUrl } from '../constants/api.constants'
import { authHeader, toSnakeQueryString } from '../helpers'

const { fetch } = window

function handleResponse (response) {
  const promise = Promise
  const respJSON = response.json()
  if (!response.ok) {
    return promise.reject(respJSON)
  }

  return respJSON
}

function getContacts (args) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const query = toSnakeQueryString(args, true)

  return fetch(`${getTenantApiUrl()}/booking_process/contacts?${query}`, requestOptions).then(handleResponse)
}

export const bookingProcessService = {
  getContacts
}

export default bookingProcessService

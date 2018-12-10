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

function getContentForComponent (component) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/content/component/${component}`, requestOptions).then(handleResponse)
}

const contentService = {
  getContentForComponent
}

export default contentService

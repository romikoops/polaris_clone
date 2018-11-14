import { Promise } from 'es6-promise-promise'
import { getFullApiHost } from '../constants/api.constants'
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

function getUserConversations () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/messaging/get`, requestOptions).then(handleResponse)
}

function getAdminConversations () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/messaging/get_admin`, requestOptions).then(handleResponse)
}

function sendUserMessage (message) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ message })
  }
  const url = `${getFullApiHost()}/messaging/send`

  return fetch(url, requestOptions).then(handleResponse)
}

function getShipmentData (ref) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ ref })
  }
  const url = `${getFullApiHost()}/messaging/data`

  return fetch(url, requestOptions).then(handleResponse)
}
function getShipmentsData (keys) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ keys })
  }
  const url = `${getFullApiHost()}/messaging/shipments`

  return fetch(url, requestOptions).then(handleResponse)
}

function markAsRead (shipmentRef) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ shipmentRef })
  }
  const url = `${getFullApiHost()}/messaging/mark`

  return fetch(url, requestOptions).then(handleResponse)
}

const messagingService = {
  getUserConversations,
  sendUserMessage,
  getShipmentData,
  markAsRead,
  getAdminConversations,
  getShipmentsData
}

export default messagingService

import { Promise } from 'es6-promise-promise'
import { getTenantApiUrl } from '../constants/api.constants'
import { authHeader, toQueryString } from '../helpers'

const { fetch, localStorage, FormData } = window

function handleResponse (response) {
  const promise = Promise
  const respJSON = response.json()
  if (!response.ok) {
    return promise.reject(respJSON)
  }

  return respJSON
}

function getStoredShipment () {
  const storedShipment = JSON.parse(localStorage.getItem('shipment'))

  return storedShipment || {}
}

function getAll () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/shipments`, requestOptions).then(handleResponse)
}

function getShipment (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/shipments/${id}`, requestOptions).then(handleResponse)
}

function getSchedulesForResult (args) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const url = `${getTenantApiUrl()}/shipments/${args.shipmentId}/view_more_schedules`
  const params = { trip_id: args.tripId, delta: args.delta }

  return fetch(`${url}?${toQueryString(params, false)}`, requestOptions).then(handleResponse)
}

function newShipment (details) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ details })
  }
  const url = `${getTenantApiUrl()}/create_shipment`

  return fetch(url, requestOptions).then(handleResponse)
}

function getOffers (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }
  const url = `${getTenantApiUrl()}/shipments/${data.shipment.id}/get_offers`

  return fetch(url, requestOptions).then(handleResponse)
}

function chooseOffer (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }
  const url = `${getTenantApiUrl()}/shipments/${data.id}/choose_offer`

  return fetch(url, requestOptions).then(handleResponse)
}
function sendQuotes (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }
  const url = `${getTenantApiUrl()}/shipments/${data.shipment.id}/send_quotes`

  return fetch(url, requestOptions).then(handleResponse)
}

function requestShipment (id) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }
  const url = `${getTenantApiUrl()}/shipments/${id}/request_shipment`

  return fetch(url, requestOptions).then(handleResponse)
}
function getNotes (noteIds) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ itineraries: noteIds })
  }
  const url = `${getTenantApiUrl()}/notes/fetch`

  return fetch(url, requestOptions).then(handleResponse)
}
function getLastAvailableDate (params) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const url = `${getTenantApiUrl()}/itineraries/last_available_date?${toQueryString(params)}`

  return fetch(url, requestOptions).then(handleResponse)
}

function uploadDocument (doc, type, url) {
  const formData = new FormData()
  formData.append('file', doc)
  formData.append('type', type)
  const requestOptions = {
    method: 'POST',
    headers: authHeader(),
    body: formData
  }

  return fetch(getTenantApiUrl() + url, requestOptions).then(handleResponse)
}

function updateCurrency (currency) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ currency })
  }
  const url = `${getTenantApiUrl()}/currencies/set`

  return fetch(url, requestOptions).then(handleResponse)
}

function deleteDocument (documentId) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/documents/delete/${documentId}`, requestOptions).then(handleResponse)
}

function updateShipmentUser (shipmentId) {
  const requestOptions = {
    method: 'PATCH',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/shipments/${shipmentId}/update_user/`, requestOptions)
}

function updateContact (data) {
  const formData = new FormData()
  formData.append('update', JSON.stringify(data))
  const requestOptions = {
    method: 'PATCH',
    headers: authHeader(),
    body: formData
  }

  return fetch(`${getTenantApiUrl()}/contacts/${data.id}`, requestOptions).then(handleResponse)
}

export const shipmentService = {
  newShipment,
  updateContact,
  getAll,
  getShipment,
  chooseOffer,
  sendQuotes,
  deleteDocument,
  getOffers,
  getStoredShipment,
  uploadDocument,
  requestShipment,
  updateCurrency,
  getNotes,
  getSchedulesForResult,
  getLastAvailableDate,
  updateShipmentUser
}

export default shipmentService

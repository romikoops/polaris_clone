import { Promise } from 'es6-promise-promise'
import { getFullApiHost } from '../constants/api.constants'
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

  return fetch(`${getFullApiHost()}/shipments`, requestOptions).then(handleResponse)
}

function getShipment (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/shipments/${id}`, requestOptions).then(handleResponse)
}

function getSchedulesForResult (args) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const url = `${getFullApiHost()}/shipments/${args.shipmentId}/view_more_schedules`
  const params = { trip_id: args.tripId, delta: args.delta }

  return fetch(`${url}?${toQueryString(params)}`, requestOptions).then(handleResponse)
}

function newShipment (details) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ details })
  }
  const url = `${getFullApiHost()}/create_shipment`

  return fetch(url, requestOptions).then(handleResponse)
}

function getOffers (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }
  const url = `${getFullApiHost()}/shipments/${data.shipment.id}/get_offers`

  return fetch(url, requestOptions).then(handleResponse)
}

function chooseOffer (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }
  const url = `${getFullApiHost()}/shipments/${data.id}/choose_offer`

  return fetch(url, requestOptions).then(handleResponse)
}
function sendQuotes (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }
  const url = `${getFullApiHost()}/shipments/${data.shipment.id}/send_quotes`

  return fetch(url, requestOptions).then(handleResponse)
}

function setShipmentContacts (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }
  const url = `${getFullApiHost()}/shipments/${data.shipment.id}/update_shipment`

  return fetch(url, requestOptions).then(handleResponse)
}
function requestShipment (id) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }
  const url = `${getFullApiHost()}/shipments/${id}/request_shipment`

  return fetch(url, requestOptions).then(handleResponse)
}
function getNotes (noteIds) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(noteIds)
  }
  const url = `${getFullApiHost()}/notes/fetch`

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

  return fetch(getFullApiHost() + url, requestOptions).then(handleResponse)
}

function updateCurrency (currency) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ currency })
  }
  const url = `${getFullApiHost()}/currencies/set`

  return fetch(url, requestOptions).then(handleResponse)
}

function deleteDocument (documentId) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/documents/delete/${documentId}`, requestOptions).then(handleResponse)
}

function updateContact (data) {
  const formData = new FormData()
  formData.append('update', JSON.stringify(data))
  const requestOptions = {
    method: 'PATCH',
    headers: authHeader(),
    body: formData
  }

  return fetch(`${getFullApiHost()}/contacts/${data.id}`, requestOptions).then(handleResponse)
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
  setShipmentContacts,
  uploadDocument,
  requestShipment,
  updateCurrency,
  getNotes,
  getSchedulesForResult
}

export default shipmentService

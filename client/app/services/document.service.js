import { Promise } from 'es6-promise-promise'
import getApiHost from '../constants/api.constants'
import { authHeader } from '../helpers'

const { fetch, FormData } = window

function handleResponse (response) {
  const promise = Promise
  if (!response.ok) {
    return promise.reject(response.statusText)
  }

  return response.json()
}

function uploadPricings (file, loadType, open) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }
  const url = open
    ? `/admin/open_pricings/ocean_${loadType}_pricings/process_csv`
    : `/admin/pricings/ocean_${loadType}_pricings/process_csv`

  return fetch(`${getApiHost()}${url}`, requestOptions).then(handleResponse)
}

function uploadHubs (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getApiHost()}/admin/hubs/process_csv`, requestOptions).then(handleResponse)
}

function downloadPricings (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }

  return fetch(`${getApiHost()}/admin/pricings/download`, requestOptions).then(handleResponse)
}

function uploadSchedules (file, target) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getApiHost()}/admin/${target}_schedules/process_csv`, requestOptions).then(handleResponse)
}

function uploadItinerarySchedules (file, target) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getApiHost()}/admin/schedules/overwrite/${target}`, requestOptions).then(handleResponse)
}

function uploadLocalCharges (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getApiHost()}/admin/local_charges/process_csv`, requestOptions).then(handleResponse)
}

function downloadLocalCharges (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }

  return fetch(`${getApiHost()}/admin/local_charges/download`, requestOptions).then(handleResponse)
}

function downloadQuotations (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }

  return fetch(`${BASE_URL}/shipments/${options.shipment.id}/quotations/download`, requestOptions).then(handleResponse)
}

function downloadHubs () {
  const requestOptions = {
    method: 'GET',
    headers: { ...authHeader() }
  }

  return fetch(`${getApiHost()}/admin/hubs/sheet/download`, requestOptions).then(handleResponse)
}

function downloadGdpr (id) {
  const requestOptions = {
    method: 'GET',
    headers: { ...authHeader() }
  }

  return fetch(`${getApiHost()}/users/${id}/gdpr/download`, requestOptions).then(handleResponse)
}

function downloadSchedules (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }

  return fetch(`${getApiHost()}/admin/schedules/download`, requestOptions).then(handleResponse)
}

function downloadTrucking (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }

  return fetch(`${getApiHost()}/admin/trucking/download`, requestOptions).then(handleResponse)
}

export const documentService = {
  uploadPricings,
  uploadHubs,
  uploadLocalCharges,
  downloadSchedules,
  uploadSchedules,
  downloadPricings,
  downloadLocalCharges,
  downloadHubs,
  uploadItinerarySchedules,
  downloadTrucking,
  downloadGdpr,
  downloadQuotations
}

export default documentService

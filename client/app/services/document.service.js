import { Promise } from 'es6-promise-promise'
import { getTenantApiUrl } from '../constants/api.constants'
import { authHeader } from '../helpers'

const { fetch, FormData } = window

function handleResponse (response) {
  const promise = Promise
  if (!response.ok) {
    return promise.reject(response.statusText)
  }

  return response.json()
}

function uploadPricings (file, mot, loadType, open) {
  const formData = new FormData()
  formData.append('file', file)
  formData.append('mot', mot)
  formData.append('load_type', loadType)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }
  const url = open
    ? `/admin/open_pricings/ocean_${loadType}_pricings/process_csv` // deprecated?
    : `/admin/pricings/upload`

  return fetch(`${getTenantApiUrl()}${url}`, requestOptions).then(handleResponse)
}

function uploadHubs (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getTenantApiUrl()}/admin/hubs/process_csv`, requestOptions).then(handleResponse)
}

function downloadPricings (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }

  return fetch(`${getTenantApiUrl()}/admin/pricings/download`, requestOptions).then(handleResponse)
}

function uploadSchedules (file, target) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getTenantApiUrl()}/admin/${target}_schedules/process_csv`, requestOptions).then(handleResponse)
}

function uploadItinerarySchedules (file, target) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getTenantApiUrl()}/admin/schedules/overwrite/${target}`, requestOptions).then(handleResponse)
}

function uploadLocalCharges (file, mot) {
  const formData = new FormData()
  formData.append('file', file)
  formData.append('mot', mot)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getTenantApiUrl()}/admin/local_charges/upload`, requestOptions).then(handleResponse)
}
function uploadChargeCategories (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getTenantApiUrl()}/admin/charge_categories/upload`, requestOptions).then(handleResponse)
}

function downloadLocalCharges (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }

  return fetch(`${getTenantApiUrl()}/admin/local_charges/download`, requestOptions).then(handleResponse)
}

function uploadGeneratorSheet (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getTenantApiUrl()}/admin/schedules/auto_generate_sheet`, requestOptions).then(handleResponse)
}

function downloadQuotations (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }

  return fetch(`${getTenantApiUrl()}/shipments/${options.shipment.id}/quotations/download`, requestOptions).then(handleResponse)
}

function downloadShipment (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }

  return fetch(`${getTenantApiUrl()}/shipments/${options.shipment.id}/shipment/download`, requestOptions).then(handleResponse)
}

function downloadHubs () {
  const requestOptions = {
    method: 'GET',
    headers: { ...authHeader() }
  }

  return fetch(`${getTenantApiUrl()}/admin/hubs/sheet/download`, requestOptions).then(handleResponse)
}
function downloadChargeCategories () {
  const requestOptions = {
    method: 'GET',
    headers: { ...authHeader() }
  }

  return fetch(`${getTenantApiUrl()}/admin/charge_categories/download`, requestOptions).then(handleResponse)
}

function downloadGdpr (id) {
  const requestOptions = {
    method: 'GET',
    headers: { ...authHeader() }
  }

  return fetch(`${getTenantApiUrl()}/users/${id}/gdpr/download`, requestOptions).then(handleResponse)
}

function downloadSchedules (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }

  return fetch(`${getTenantApiUrl()}/admin/schedules/download`, requestOptions).then(handleResponse)
}

function downloadTrucking (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }

  return fetch(`${getTenantApiUrl()}/admin/trucking/download`, requestOptions).then(handleResponse)
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
  downloadShipment,
  downloadQuotations,
  downloadChargeCategories,
  uploadChargeCategories,
  uploadGeneratorSheet
}

export default documentService

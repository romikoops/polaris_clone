import { Promise } from 'es6-promise-promise'
import { BASE_URL } from '../constants'
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
  return fetch(`${BASE_URL}${url}`, requestOptions).then(handleResponse)
}

function uploadHubs (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }
  return fetch(`${BASE_URL}/admin/hubs/process_csv`, requestOptions).then(handleResponse)
}
function downloadPricings (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }
  return fetch(`${BASE_URL}/admin/pricings/download`, requestOptions).then(handleResponse)
}

function uploadSchedules (file, target) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }
  return fetch(`${BASE_URL}/admin/${target}_schedules/process_csv`, requestOptions).then(handleResponse)
}

function uploadItinerarySchedules (file, target) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }
  return fetch(`${BASE_URL}/admin/schedules/overwrite/${target}`, requestOptions).then(handleResponse)
}

function uploadLocalCharges (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }
  return fetch(`${BASE_URL}/admin/local_charges/process_csv`, requestOptions).then(handleResponse)
}

function downloadLocalCharges (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }
  return fetch(`${BASE_URL}/admin/local_charges/download`, requestOptions).then(handleResponse)
}

function downloadHubs () {
  const requestOptions = {
    method: 'GET',
    headers: { ...authHeader() }
  }
  return fetch(`${BASE_URL}/admin/hubs/sheet/download`, requestOptions).then(handleResponse)
}
function downloadSchedules (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }

  return fetch(`${BASE_URL}/admin/schedules/download`, requestOptions).then(handleResponse)
}

function downloadTrucking (options) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ options })
  }
  return fetch(`${BASE_URL}/admin/trucking/download`, requestOptions).then(handleResponse)
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
  downloadTrucking
}

export default documentService

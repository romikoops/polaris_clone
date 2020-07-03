import { Promise } from 'es6-promise-promise'
import { getApiHost, getTenantApiUrl } from '../constants/api.constants'
import { authHeader, cookieKey, toQueryString } from '../helpers'

const { fetch, FormData } = window

function handleResponse (response) {
  if (!response.ok) {
    return Promise.reject(response.statusText)
  }

  return response.json()
}

function getLocations (userId) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/users/${userId}/addresses`, requestOptions).then(handleResponse)
}

function destroyAddress (userId, addressId) {
  const requestOptions = {
    method: 'DELETE',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/users/${userId}/addresses/${addressId}`, requestOptions).then(handleResponse)
}

function searchShipments (text, target, page, perPage) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  let query = ''

  query += `query=${text}&page=${page || 1}`
  if (perPage) query += `&per_page=${perPage}`

  return fetch(`${getTenantApiUrl()}/search/shipments/${target}?${query}`, requestOptions)
    .then(handleResponse)
}
function searchContacts (text, page, perPage) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  let query = ''

  query += `query=${text}&page=${page || 1}`
  if (perPage) query += `&per_page=${perPage}`

  return fetch(`${getTenantApiUrl()}/search/contacts?${query}`, requestOptions)
    .then(handleResponse)
}

function makePrimary (userId, addressId) {
  const requestOptions = {
    method: 'PATCH',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/users/${userId}/addresses/${addressId}`, requestOptions).then(handleResponse)
}

function getStoredUser () {
  const sortedUser = JSON.parse(window.localStorage.getItem(cookieKey()))

  return sortedUser || {}
}

function getAll () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/users`, requestOptions).then(handleResponse)
}

function getById (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/users/${id}`, requestOptions).then(handleResponse)
}

function editUserAddress (userId, data) {
  const formData = new FormData()
  formData.append('edit_address', JSON.stringify(data))
  const requestOptions = {
    method: 'POST',
    headers: authHeader(),
    body: formData
  }

  return fetch(
    `${getTenantApiUrl()}/users/${userId}/addresses/${data.id}/edit`,
    requestOptions
  ).then(handleResponse)
}

// prefixed function name with underscore because delete is a reserved word in javascript
// eslint-disable-next-line no-underscore-dangle
function _delete (id) {
  const requestOptions = {
    method: 'DELETE',
    headers: authHeader()
  }

  return fetch(`/users/${id}`, requestOptions).then(handleResponse)
}

function getHubs (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/users/${id}/hubs`, requestOptions).then(handleResponse)
}
function getShipment (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/shipments/${id}`, requestOptions).then(handleResponse)
}

function getDashboard (userId) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/users/${userId}/home`, requestOptions).then(handleResponse)
}

function getContacts (params) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const url = `${getTenantApiUrl()}/contacts?${toQueryString(params, false)}`

  return fetch(url, requestOptions).then(handleResponse)
}

function deleteDocument (documentId) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/documents/delete/${documentId}`, requestOptions).then(handleResponse)
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

function getContact (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/contacts/${id}`, requestOptions).then(handleResponse)
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

function newUserAddress (userId, data) {
  const formData = new FormData()
  formData.append('new_address', JSON.stringify(data))
  const requestOptions = {
    method: 'POST',
    headers: authHeader(),
    body: formData
  }

  return fetch(`${getTenantApiUrl()}/users/${userId}/addresses`, requestOptions).then(handleResponse)
}

function newContact (data) {
  const formData = new FormData()
  formData.append('new_contact', JSON.stringify(data))
  const requestOptions = {
    method: 'POST',
    headers: authHeader(),
    body: formData
  }

  return fetch(`${getTenantApiUrl()}/contacts`, requestOptions).then(handleResponse)
}

function getShipments (_pages, perPage, params, redirect) {
  const pages = _pages || {
    open: 1,
    quoted: 1,
    requested: 1,
    archived: 1,
    rejected: 1,
    finished: 1
  }
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  let query = ''
  const queryKeys = Object.keys(pages)
  queryKeys.forEach((status, i) => {
    query += `${status}_page=${pages[status] || 1}&`
  })
  if (perPage) query += `per_page=${perPage}`

  const queryString = params ? toQueryString(params, true) : ''

  return fetch(`${getTenantApiUrl()}/shipments?${query}${queryString}`, requestOptions).then(handleResponse)
}

function deltaShipmentsPage (target, page, perPage, params) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  let query = `page=${page || 1}&target=${target}`
  if (perPage) query += `&per_page=${perPage}`

  const queryString = params ? toQueryString(params, true) : ''

  return fetch(`${getTenantApiUrl()}/shipments/pages/delta_page_handler?${query}${queryString}`, requestOptions)
    .then(handleResponse)
}

function deleteContactAddress (addressId) {
  const requestOptions = {
    method: 'POST',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/contacts/delete_contact_address/${addressId}`, requestOptions).then(handleResponse)
}

function saveAddressEdit (data) {
  const formData = new FormData()
  formData.append('address', JSON.stringify(data))
  const requestOptions = {
    method: 'POST',
    headers: authHeader(),
    body: formData
  }

  return fetch(`${getTenantApiUrl()}/contacts/update_contact_address/${data.id}`, requestOptions).then(handleResponse)
}
function reuseShipment (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/shipments/${id}/reuse_booking_data`, requestOptions).then(handleResponse)
}
function getCurrentUser () {
  const requestOptions = {
    method: 'GET',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getApiHost()}/user`, requestOptions).then(handleResponse)
}

function confirmAccount (token) {
  return fetch(`${getTenantApiUrl()}/users/${token}/activate`).then(handleResponse)
}

export const userService = {
  getLocations,
  destroyAddress,
  newUserAddress,
  getDashboard,
  makePrimary,
  getShipment,
  getShipments,
  getHubs,
  deleteDocument,
  uploadDocument,
  getAll,
  getById,
  getStoredUser,
  getContact,
  getContacts,
  updateContact,
  newContact,
  saveAddressEdit,
  deleteContactAddress,
  editUserAddress,
  delete: _delete,
  reuseShipment,
  searchShipments,
  deltaShipmentsPage,
  searchContacts,
  confirmAccount,
  getCurrentUser
}
export default userService

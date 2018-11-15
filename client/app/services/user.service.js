import { Promise } from 'es6-promise-promise'
import { authHeader } from '../helpers/auth-header'
import getSubdomain from '../helpers/subdomain'
import { getTenantApiUrl } from '../constants/api.constants'
import { toQueryString } from '../helpers'

const { fetch, FormData } = window
const subdomainKey = getSubdomain()
const cookieKey = `${subdomainKey}_user`

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

function destroyLocation (userId, addressId) {
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

function optOut (userId, target) {
  const requestOptions = {
    method: 'POST',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/users/${userId}/opt_out/${target}`, requestOptions).then(handleResponse)
}

function getStoredUser () {
  const sortedUser = JSON.parse(window.localStorage.getItem(cookieKey))

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

function editUserLocation (userId, data) {
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
  const url = `${getTenantApiUrl()}/contacts?${toQueryString(params)}`

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

function newUserLocation (userId, data) {
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

function newAlias (data) {
  const formData = new FormData()
  formData.append('new_contact', JSON.stringify(data))
  const requestOptions = {
    method: 'POST',
    headers: authHeader(),
    body: formData
  }

  return fetch(`${getTenantApiUrl()}/contacts/new_alias`, requestOptions).then(handleResponse)
}

function getShipments (pages, perPage) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  let query = ''
  Object.keys(pages).forEach((status) => {
    query += `${status}_page=${pages[status] || 1}&`
  })
  if (perPage) query += `per_page=${perPage}`

  return fetch(`${getTenantApiUrl()}/shipments?${query}`, requestOptions).then(handleResponse)
}

function deltaShipmentsPage (target, page, perPage) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  let query = `page=${page || 1}&target=${target}`
  if (perPage) query += `&per_page=${perPage}`

  return fetch(`${getTenantApiUrl()}/shipments/pages/delta_page_handler?${query}`, requestOptions).then(handleResponse)
}

function deleteAlias (aliasId) {
  const requestOptions = {
    method: 'POST',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/contacts/delete_alias/${aliasId}`, requestOptions).then(handleResponse)
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

function getPricings () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/pricings`, requestOptions).then(handleResponse)
}
function getPricingsForItinerary (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/pricings/${id}`, requestOptions).then(handleResponse)
}
function requestPricing (req) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(req)
  }

  return fetch(`${getTenantApiUrl()}/pricings/${req.pricing_id}/request`, requestOptions).then(handleResponse)
}

export const userService = {
  getLocations,
  destroyLocation,
  newUserLocation,
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
  newAlias,
  deleteAlias,
  saveAddressEdit,
  deleteContactAddress,
  editUserLocation,
  delete: _delete,
  optOut,
  reuseShipment,
  searchShipments,
  deltaShipmentsPage,
  searchContacts,
  getPricings,
  getPricingsForItinerary,
  requestPricing
}
export default userService

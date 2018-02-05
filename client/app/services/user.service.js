import { Promise } from 'es6-promise-promise'
import { authHeader, getSubdomain } from '../helpers'
import { BASE_URL } from '../constants'

const { fetch, FormData } = window
const subdomainKey = getSubdomain()
const cookieKey = `${subdomainKey}_user`

// FIXME: console.log(cookieKey)
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

  return fetch(`${BASE_URL}/users/${userId}/locations`, requestOptions).then(handleResponse)
}

function destroyLocation (userId, locationId) {
  const requestOptions = {
    method: 'DELETE',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/users/${userId}/locations/${locationId}`, requestOptions).then(handleResponse)
}

function makePrimary (userId, locationId) {
  const requestOptions = {
    method: 'PATCH',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/users/${userId}/locations/${locationId}`, requestOptions).then(handleResponse)
}

function getShipments () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/shipments`, requestOptions).then(handleResponse)
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

  return fetch(`${BASE_URL}/users`, requestOptions).then(handleResponse)
}

function getById (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/users/${id}`, requestOptions).then(handleResponse)
}

function update (user) {
  const requestOptions = {
    method: 'PUT',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ update: user })
  }

  return fetch(`${BASE_URL}/users/${user.id}/update`, requestOptions).then(handleResponse)
}

function editUserLocation (userId, data) {
  const formData = new FormData()
  formData.append('edit_location', JSON.stringify(data))
  const requestOptions = {
    method: 'POST',
    headers: authHeader(),
    body: formData
  }
  return fetch(
    `${BASE_URL}/users/${userId}/locations/${data.id}/edit`,
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

  return fetch(`${BASE_URL}/users/${id}/hubs`, requestOptions).then(handleResponse)
}
function getShipment (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/shipments/${id}`, requestOptions).then(handleResponse)
}

function getDashboard (userId) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/users/${userId}/home`, requestOptions).then(handleResponse)
}

function deleteDocument (documentId) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/documents/delete/${documentId}`, requestOptions).then(handleResponse)
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

  return fetch(BASE_URL + url, requestOptions).then(handleResponse)
}

function getContact (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/contacts/${id}`, requestOptions).then(handleResponse)
}

function updateContact (data) {
  const formData = new FormData()
  formData.append('update', JSON.stringify(data))
  const requestOptions = {
    method: 'POST',
    headers: authHeader(),
    body: formData
  }
  return fetch(`${BASE_URL}/contacts/update_contact/${data.id}`, requestOptions).then(handleResponse)
}

function newUserLocation (userId, data) {
  const formData = new FormData()
  formData.append('new_location', JSON.stringify(data))
  const requestOptions = {
    method: 'POST',
    headers: authHeader(),
    body: formData
  }
  return fetch(`${BASE_URL}/users/${userId}/locations`, requestOptions).then(handleResponse)
}

function newContact (data) {
  const formData = new FormData()
  formData.append('new_contact', JSON.stringify(data))
  const requestOptions = {
    method: 'POST',
    headers: authHeader(),
    body: formData
  }
  return fetch(`${BASE_URL}/contacts`, requestOptions).then(handleResponse)
}

function newAlias (data) {
  const formData = new FormData()
  formData.append('new_contact', JSON.stringify(data))
  const requestOptions = {
    method: 'POST',
    headers: authHeader(),
    body: formData
  }
  return fetch(`${BASE_URL}/contacts/new_alias`, requestOptions).then(handleResponse)
}

function deleteAlias (aliasId) {
  const requestOptions = {
    method: 'POST',
    headers: authHeader()
  }
  return fetch(`${BASE_URL}/contacts/delete_alias/${aliasId}`, requestOptions).then(handleResponse)
}

function deleteContactAddress (addressId) {
  const requestOptions = {
    method: 'POST',
    headers: authHeader()
  }
  return fetch(`${BASE_URL}/contacts/delete_contact_address/${addressId}`, requestOptions).then(handleResponse)
}

function saveAddressEdit (data) {
  const formData = new FormData()
  formData.append('address', JSON.stringify(data))
  const requestOptions = {
    method: 'POST',
    headers: authHeader(),
    body: formData
  }
  return fetch(`${BASE_URL}/contacts/update_contact_address/${data.id}`, requestOptions).then(handleResponse)
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
  update,
  getStoredUser,
  getContact,
  updateContact,
  newContact,
  newAlias,
  deleteAlias,
  saveAddressEdit,
  deleteContactAddress,
  editUserLocation,
  delete: _delete
}

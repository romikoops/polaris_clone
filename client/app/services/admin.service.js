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

function getHubs (page, hubType, countryId, status) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  let query = ''
  if (hubType) {
    query += `&hub_type=${hubType}`
  }
  if (status) {
    query += `&status=${status}`
  }
  if (countryId && countryId.length) {
    query += `&country_ids=${countryId}`
  }

  return fetch(`${BASE_URL}/admin/hubs?page=${page || 1}${query}`, requestOptions)
    .then(handleResponse)
}
function getAllHubs () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/hubs/all/processed`, requestOptions)
    .then(handleResponse)
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

function searchHubs (text, page, hubType, countryId, status) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  let query = ''
  if (text) {
    query += `&text=${text}`
  }
  if (hubType) {
    query += `&hub_type=${hubType}`
  }
  if (status) {
    query += `&status=${status}`
  }
  if (countryId && countryId.length) {
    query += `&country_ids=${countryId}`
  }

  return fetch(`${BASE_URL}/admin/search/hubs?page=${page || 1}${query}`, requestOptions)
    .then(handleResponse)
}
function searchShipments (text, target, page, perPage) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  let query = ''

  query += `query=${text}&page=${page || 1}&per_page=${perPage}`

  return fetch(`${BASE_URL}/admin/search/shipments/${target}?${query}`, requestOptions)
    .then(handleResponse)
}

function getItineraries () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/itineraries`, requestOptions).then(handleResponse)
}

function getItinerary (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/itineraries/${id}`, requestOptions).then(handleResponse)
}
function viewTrucking (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/trucking/${id}`, requestOptions).then(handleResponse)
}
function getLayovers (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/itineraries/${id}/layovers`, requestOptions)
    .then(handleResponse)
}

function getHub (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/hubs/${id}`, requestOptions).then(handleResponse)
}

function wizardHubs (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }
  const uploadUrl = `${BASE_URL}/admin/hubs/process_csv`

  return fetch(uploadUrl, requestOptions).then(handleResponse)
}

function wizardSCharge (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }
  const uploadUrl = `${BASE_URL}/admin/local_charges/process_csv`

  return fetch(uploadUrl, requestOptions).then(handleResponse)
}

function wizardPricings (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }
  const uploadUrl = `${BASE_URL}/admin/pricings/train_and_ocean_pricings/process_csv`

  return fetch(uploadUrl, requestOptions).then(handleResponse)
}

function wizardTrucking (type, file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }
  let uploadUrl
  if (type === 'zipcode') {
    uploadUrl = `${BASE_URL}/admin/trucking/trucking_zip_pricings`
  } else if (type === 'city') {
    uploadUrl = `${BASE_URL}/admin/trucking/trucking_city_pricings`
  }

  return fetch(uploadUrl, requestOptions).then(handleResponse)
}

function wizardOpenPricings (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }
  const uploadUrl = `${BASE_URL}/admin/open_pricings/train_and_ocean_pricings/process_csv`

  return fetch(uploadUrl, requestOptions).then(handleResponse)
}

function getServiceCharges () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/local_charges`, requestOptions).then(handleResponse)
}
function getShipments (pages, perPage) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  let query = ''
  const queryKeys = Object.keys(pages)
  queryKeys.forEach((status, i) => {
    query += `${status}_page=${pages[status] || 1}&`
  })
  if (perPage) query += `&per_page=${perPage}`

  return fetch(`${BASE_URL}/admin/shipments?${query}`, requestOptions).then(handleResponse)
}
function deltaShipmentsPage (target, page, perPage) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const query = `page=${page || 1}&target=${target}&per_page=${perPage}`

  return fetch(`${BASE_URL}/admin/shipments/pages/delta_page_handler?${query}`, requestOptions).then(handleResponse)
}

function getDashboard () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/dashboard`, requestOptions).then(handleResponse)
}

function getShipment (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/shipments/${id}`, requestOptions).then(handleResponse)
}

function getItineraryPricings (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/route_pricings/${id}`, requestOptions)
    .then(handleResponse)
}

function confirmShipment (id, action) {
  const requestOptions = {
    method: 'PUT',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ shipment_action: action })
  }
  const url = `${BASE_URL}/admin/shipments/${id}`

  return fetch(url, requestOptions).then(handleResponse)
}

function getPricings (pages) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  let pageQuery = ''
  if (pages) {
    Object.keys(pages).forEach((key) => {
      pageQuery += `${key}=${pages[key]}&`
    })
    pageQuery = pageQuery.slice(0, -1)
  }

  return fetch(`${BASE_URL}/admin/pricings?${pageQuery}`, requestOptions)
    .then(handleResponse)
}

function searchPricings (text, page, mot) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/search/pricings?page=${page || 1}
    &mot=${mot}&text=${text}`, requestOptions)
    .then(handleResponse)
}

function deletePricing (pricing) {
  const requestOptions = {
    method: 'DELETE',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/pricings/${pricing.id}`, requestOptions)
    .then(handleResponse)
}

function getClientPricings (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/client_pricings/${id}`, requestOptions)
    .then(handleResponse)
}

function getClients () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/clients`, requestOptions).then(handleResponse)
}

function getClient (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/clients/${id}`, requestOptions).then(handleResponse)
}

function getSchedules () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/schedules`, requestOptions).then(handleResponse)
}

function getTrucking () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/trucking`, requestOptions).then(handleResponse)
}

function getVehicleTypes (itineraryId) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/vehicle_types?itinerary_id=${itineraryId}`, requestOptions).then(handleResponse)
}

function autoGenSchedules (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }

  return fetch(`${BASE_URL}/admin/schedules/auto_generate`, requestOptions)
    .then(handleResponse)
}

function updatePricing (id, data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }

  return fetch(`${BASE_URL}/admin/pricings/update/${id}`, requestOptions)
    .then(handleResponse)
}
function assignDedicatedPricings (pricing, clientIds) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ pricing, clientIds })
  }

  return fetch(`${BASE_URL}/admin/pricings/assign_dedicated`, requestOptions)
    .then(handleResponse)
}
function getPricingsTest (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ data })
  }

  return fetch(`${BASE_URL}/admin/pricings/test/${data.itineraryId}`, requestOptions)
    .then(handleResponse)
}

function updateServiceCharge (id, data) {
  const requestOptions = {
    method: 'PUT',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ data })
  }

  return fetch(`${BASE_URL}/admin/local_charges/${id}`, requestOptions)
    .then(handleResponse)
}

function newClient (data) {
  const formData = new FormData()
  formData.append('new_client', JSON.stringify(data))
  const requestOptions = {
    method: 'POST',
    headers: authHeader(),
    body: formData
  }

  return fetch(`${BASE_URL}/admin/clients`, requestOptions).then(handleResponse)
}

function activateHub (hubId) {
  const requestOptions = {
    method: 'PATCH',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/hubs/${hubId}/set_status`, requestOptions)
    .then(handleResponse)
}

function documentAction (docId, action) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(action)
  }

  return fetch(`${BASE_URL}/admin/documents/action/${docId}`, requestOptions)
    .then(handleResponse)
}

function deleteDocument (documentId) {
  const requestOptions = {
    method: 'DELETE',
    headers: authHeader()
  }

  return fetch(`${BASE_URL}/admin/documents/${documentId}`, requestOptions).then(handleResponse)
}

function saveNewHub (hub, location) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ hub, location })
  }

  return fetch(`${BASE_URL}/admin/hubs`, requestOptions).then(handleResponse)
}
function deleteHub (hubId) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${BASE_URL}/admin/hubs/${hubId}/delete`, requestOptions)
    .then(handleResponse)
}

function deleteClient (id) {
  const requestOptions = {
    method: 'DELETE',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${BASE_URL}/admin/clients/${id}`, requestOptions)
    .then(handleResponse)
}
function editHub (hubId, object) {
  const requestOptions = {
    method: 'PATCH',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(object)
  }

  return fetch(`${BASE_URL}/admin/hubs/${hubId}`, requestOptions)
    .then(handleResponse)
}
function newRoute (itinerary) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ itinerary })
  }

  return fetch(`${BASE_URL}/admin/itineraries`, requestOptions).then(handleResponse)
}
function saveNewTrucking (obj) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ obj })
  }

  return fetch(`${BASE_URL}/admin/trucking`, requestOptions).then(handleResponse)
}
function assignManager (obj) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ obj })
  }

  return fetch(`${BASE_URL}/admin/user_managers/assign`, requestOptions)
    .then(handleResponse)
}
function editShipmentPrice (id, priceObj) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ priceObj })
  }

  return fetch(`${BASE_URL}/admin/shipments/${id}/edit_price`, requestOptions)
    .then(handleResponse)
}
function editShipmentServicePrice (id, data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }

  return fetch(`${BASE_URL}/admin/shipments/${id}/edit_service_price`, requestOptions)
    .then(handleResponse)
}
function editLocalCharges (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ data })
  }

  return fetch(`${BASE_URL}/admin/local_charges/${data.id}/edit`, requestOptions)
    .then(handleResponse)
}
function editCustomsFees (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ data })
  }

  return fetch(`${BASE_URL}/admin/customs_fees/${data.id}/edit`, requestOptions)
    .then(handleResponse)
}
function editShipmentTime (id, timeObj) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ timeObj })
  }

  return fetch(`${BASE_URL}/admin/shipments/${id}/edit_time`, requestOptions)
    .then(handleResponse)
}
function deleteItinerary (id) {
  const requestOptions = {
    method: 'DELETE',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${BASE_URL}/admin/itineraries/${id}`, requestOptions).then(handleResponse)
}
function deleteTrip (id) {
  const requestOptions = {
    method: 'DELETE',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${BASE_URL}/admin/schedules/${id}`, requestOptions).then(handleResponse)
}
function uploadTrucking (url, file, direction) {
  const formData = new FormData()
  formData.append('file', file)
  formData.append('direction', direction)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${BASE_URL}${url}`, requestOptions).then(handleResponse)
}
function newHubImage (id, file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${BASE_URL}/admin/hubs/${id}/image`, requestOptions).then(handleResponse)
}

function loadItinerarySchedules (id) {
  const requestOptions = {
    method: 'GET',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${BASE_URL}/admin/schedules/${id}`, requestOptions).then(handleResponse)
}
function saveItineraryNotes (id, notes) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ notes })
  }

  return fetch(`${BASE_URL}/admin/itineraries/${id}/edit_notes`, requestOptions)
    .then(handleResponse)
}

function editTruckingPrice (pricing) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ pricing })
  }

  return fetch(`${BASE_URL}/admin/trucking/${pricing.id}/edit`, requestOptions)
    .then(handleResponse)
}
function updateHubMandatoryCharges (id, charges) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ mandatoryCharge: charges })
  }

  return fetch(`${BASE_URL}/admin/hubs/${id}/update_mandatory_charges`, requestOptions)
    .then(handleResponse)
}

export const adminService = {
  getHubs,
  getHub,
  deleteTrip,
  getItineraries,
  deleteDocument,
  editTruckingPrice,
  deleteItinerary,
  uploadTrucking,
  getItinerary,
  getClient,
  updatePricing,
  getServiceCharges,
  getPricings,
  getShipment,
  newHubImage,
  loadItinerarySchedules,
  getSchedules,
  getTrucking,
  getClientPricings,
  getDashboard,
  autoGenSchedules,
  confirmShipment,
  getVehicleTypes,
  getShipments,
  getClients,
  saveItineraryNotes,
  getItineraryPricings,
  wizardHubs,
  wizardSCharge,
  wizardPricings,
  wizardOpenPricings,
  wizardTrucking,
  updateServiceCharge,
  newClient,
  activateHub,
  documentAction,
  saveNewHub,
  newRoute,
  getLayovers,
  saveNewTrucking,
  assignManager,
  viewTrucking,
  editShipmentPrice,
  editShipmentServicePrice,
  editShipmentTime,
  editLocalCharges,
  deleteHub,
  deletePricing,
  editHub,
  deleteClient,
  editCustomsFees,
  updateHubMandatoryCharges,
  assignDedicatedPricings,
  searchHubs,
  getAllHubs,
  getPricingsTest,
  searchShipments,
  deltaShipmentsPage,
  searchPricings,
  uploadDocument
}

export default adminService

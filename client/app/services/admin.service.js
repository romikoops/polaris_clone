import { Promise } from 'es6-promise-promise'
import { getFullApiHost } from '../constants/api.constants'
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

  return fetch(`${getFullApiHost()}/admin/hubs?page=${page || 1}${query}`, requestOptions)
    .then(handleResponse)
}
function getAllHubs () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/hubs/all/processed`, requestOptions)
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

  return fetch(`${getFullApiHost()}${url}`, requestOptions).then(handleResponse)
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

  return fetch(`${getFullApiHost()}/admin/search/hubs?page=${page || 1}${query}`, requestOptions)
    .then(handleResponse)
}
function searchShipments (text, target, page, perPage) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  let query = ''

  query += `query=${text}&page=${page || 1}&per_page=${perPage}`

  return fetch(`${getFullApiHost()}/admin/search/shipments/${target}?${query}`, requestOptions)
    .then(handleResponse)
}

function getItineraries () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/itineraries`, requestOptions).then(handleResponse)
}

function getItinerary (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/itineraries/${id}`, requestOptions).then(handleResponse)
}
function viewTrucking (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/trucking/${id}`, requestOptions).then(handleResponse)
}
function getLayovers (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/itineraries/${id}/layovers`, requestOptions)
    .then(handleResponse)
}

function getHub (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/hubs/${id}`, requestOptions).then(handleResponse)
}

function wizardHubs (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }
  const uploadUrl = `${getFullApiHost()}/admin/hubs/process_csv`

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
  const uploadUrl = `${getFullApiHost()}/admin/local_charges/process_csv`

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
  const uploadUrl = `${getFullApiHost()}/admin/pricings/train_and_ocean_pricings/process_csv`

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
    uploadUrl = `${getFullApiHost()}/admin/trucking/trucking_zip_pricings`
  } else if (type === 'city') {
    uploadUrl = `${getFullApiHost()}/admin/trucking/trucking_city_pricings`
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
  const uploadUrl = `${getFullApiHost()}/admin/open_pricings/train_and_ocean_pricings/process_csv`

  return fetch(uploadUrl, requestOptions).then(handleResponse)
}

function getServiceCharges () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/local_charges`, requestOptions).then(handleResponse)
}
function getShipments (_pages, perPage) {
  const pages = _pages || {
    open: 1,
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

  return fetch(`${getFullApiHost()}/admin/shipments?${query}`, requestOptions).then(handleResponse)
}
function deltaShipmentsPage (target, page, perPage) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const query = `page=${page || 1}&target=${target}&per_page=${perPage}`

  return fetch(`${getFullApiHost()}/admin/shipments/pages/delta_page_handler?${query}`, requestOptions).then(handleResponse)
}

function getDashboard () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/dashboard`, requestOptions).then(handleResponse)
}

function getShipment (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/shipments/${id}`, requestOptions).then(handleResponse)
}

function getItineraryPricings (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/route_pricings/${id}`, requestOptions)
    .then(handleResponse)
}

function confirmShipment (id, action) {
  const requestOptions = {
    method: 'PUT',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ shipment_action: action })
  }
  const url = `${getFullApiHost()}/admin/shipments/${id}`

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

  return fetch(`${getFullApiHost()}/admin/pricings?${pageQuery}`, requestOptions)
    .then(handleResponse)
}

function searchPricings (text, page, mot) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/search/pricings?page=${page || 1}
    &mot=${mot}&text=${text}`, requestOptions)
    .then(handleResponse)
}

function deletePricing (pricing) {
  const requestOptions = {
    method: 'DELETE',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/pricings/${pricing.id}`, requestOptions)
    .then(handleResponse)
}

function getClientPricings (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/client_pricings/${id}`, requestOptions)
    .then(handleResponse)
}

function getClients () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/clients`, requestOptions).then(handleResponse)
}

function getClient (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/clients/${id}`, requestOptions).then(handleResponse)
}

function getSchedules () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/schedules`, requestOptions).then(handleResponse)
}

function getTrucking () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/trucking`, requestOptions).then(handleResponse)
}

function getVehicleTypes (itineraryId) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/vehicle_types?itinerary_id=${itineraryId}`, requestOptions).then(handleResponse)
}

function autoGenSchedules (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }

  return fetch(`${getFullApiHost()}/admin/schedules/auto_generate`, requestOptions)
    .then(handleResponse)
}

function updatePricing (id, data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }

  return fetch(`${getFullApiHost()}/admin/pricings/update/${id}`, requestOptions)
    .then(handleResponse)
}
function assignDedicatedPricings (pricing, clientIds) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ pricing, clientIds })
  }

  return fetch(`${getFullApiHost()}/admin/pricings/assign_dedicated`, requestOptions)
    .then(handleResponse)
}
function getPricingsTest (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ data })
  }

  return fetch(`${getFullApiHost()}/admin/pricings/test/${data.itineraryId}`, requestOptions)
    .then(handleResponse)
}

function updateServiceCharge (id, data) {
  const requestOptions = {
    method: 'PUT',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ data })
  }

  return fetch(`${getFullApiHost()}/admin/local_charges/${id}`, requestOptions)
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

  return fetch(`${getFullApiHost()}/admin/clients`, requestOptions).then(handleResponse)
}

function activateHub (hubId) {
  const requestOptions = {
    method: 'PATCH',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/hubs/${hubId}/set_status`, requestOptions)
    .then(handleResponse)
}

function documentAction (docId, action) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(action)
  }

  return fetch(`${getFullApiHost()}/admin/documents/action/${docId}`, requestOptions)
    .then(handleResponse)
}

function deleteDocument (documentId) {
  const requestOptions = {
    method: 'DELETE',
    headers: authHeader()
  }

  return fetch(`${getFullApiHost()}/admin/documents/${documentId}`, requestOptions).then(handleResponse)
}

function saveNewHub (hub, address) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ hub, address })
  }

  return fetch(`${getFullApiHost()}/admin/hubs`, requestOptions).then(handleResponse)
}
function deleteHub (hubId) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getFullApiHost()}/admin/hubs/${hubId}/delete`, requestOptions)
    .then(handleResponse)
}

function deleteClient (id) {
  const requestOptions = {
    method: 'DELETE',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getFullApiHost()}/admin/clients/${id}`, requestOptions)
    .then(handleResponse)
}
function editHub (hubId, object) {
  const requestOptions = {
    method: 'PATCH',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(object)
  }

  return fetch(`${getFullApiHost()}/admin/hubs/${hubId}`, requestOptions)
    .then(handleResponse)
}
function newRoute (itinerary) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ itinerary })
  }

  return fetch(`${getFullApiHost()}/admin/itineraries`, requestOptions).then(handleResponse)
}
function saveNewTrucking (obj) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ obj })
  }

  return fetch(`${getFullApiHost()}/admin/trucking`, requestOptions).then(handleResponse)
}
function assignManager (obj) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ obj })
  }

  return fetch(`${getFullApiHost()}/admin/user_managers/assign`, requestOptions)
    .then(handleResponse)
}
function editShipmentPrice (id, priceObj) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ priceObj })
  }

  return fetch(`${getFullApiHost()}/admin/shipments/${id}/edit_price`, requestOptions)
    .then(handleResponse)
}
function editShipmentServicePrice (id, data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }

  return fetch(`${getFullApiHost()}/admin/shipments/${id}/edit_service_price`, requestOptions)
    .then(handleResponse)
}
function editLocalCharges (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ data })
  }

  return fetch(`${getFullApiHost()}/admin/local_charges/${data.id}/edit`, requestOptions)
    .then(handleResponse)
}
function editCustomsFees (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ data })
  }

  return fetch(`${getFullApiHost()}/admin/customs_fees/${data.id}/edit`, requestOptions)
    .then(handleResponse)
}
function editShipmentTime (id, timeObj) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ timeObj })
  }

  return fetch(`${getFullApiHost()}/admin/shipments/${id}/edit_time`, requestOptions)
    .then(handleResponse)
}
function deleteItinerary (id) {
  const requestOptions = {
    method: 'DELETE',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getFullApiHost()}/admin/itineraries/${id}`, requestOptions).then(handleResponse)
}
function deleteTrip (id) {
  const requestOptions = {
    method: 'DELETE',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getFullApiHost()}/admin/schedules/${id}`, requestOptions).then(handleResponse)
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

  return fetch(`${getFullApiHost()}${url}`, requestOptions).then(handleResponse)
}
function newHubImage (id, file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getFullApiHost()}/admin/hubs/${id}/image`, requestOptions).then(handleResponse)
}

function loadItinerarySchedules (id) {
  const requestOptions = {
    method: 'GET',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getFullApiHost()}/admin/schedules/${id}`, requestOptions).then(handleResponse)
}
function saveItineraryNotes (id, notes) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ notes })
  }

  return fetch(`${getFullApiHost()}/admin/itineraries/${id}/edit_notes`, requestOptions)
    .then(handleResponse)
}

function deleteItineraryNote (itineraryId, noteId) {
  const requestOptions = {
    method: 'DELETE',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getFullApiHost()}/admin/itineraries/${itineraryId}/notes/${noteId}`, requestOptions)
    .then(handleResponse)
}

function editTruckingPrice (pricing) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ pricing })
  }

  return fetch(`${getFullApiHost()}/admin/trucking/${pricing.id}/edit`, requestOptions)
    .then(handleResponse)
}
function updateHubMandatoryCharges (id, charges) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ mandatoryCharge: charges })
  }

  return fetch(`${getFullApiHost()}/admin/hubs/${id}/update_mandatory_charges`, requestOptions)
    .then(handleResponse)
}
function updateEmails (emails, tenant) {
  const requestOptions = {
    method: 'PATCH',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ tenant: { emails } })
  }

  return fetch(`${getApiHost()}/admin/tenants/${tenant.data.id}`, requestOptions)
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
  deleteItineraryNote,
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
  uploadDocument,
  updateEmails
}

export default adminService

import { Promise } from 'es6-promise-promise'
import { getTenantApiUrl } from '../constants/api.constants'
import { authHeader, toQueryString, toSnakeQueryString } from '../helpers'

const { fetch, FormData } = window

function handleResponse (response) {
  const promise = Promise
  if (!response.ok) {
    return promise.reject(response.statusText)
  }

  return response.json()
}

function getHubs (page, filters, sorted, pageSize) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const queryObj = {
    page,
    pageSize
  }

  if (filters) {
    filters.forEach((filter) => {
      queryObj[filter.id] = filter.value
    })
  }

  if (sorted) {
    sorted.forEach((filter) => {
      queryObj[`${filter.id}_desc`] = filter.desc
    })
  }

  const query = toSnakeQueryString(queryObj, true)

  return fetch(`${getTenantApiUrl()}/admin/hubs?${query}`, requestOptions)
    .then(handleResponse)
}

function getAllHubs () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/hubs/all/processed`, requestOptions)
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

  return fetch(`${getTenantApiUrl()}${url}`, requestOptions).then(handleResponse)
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

  return fetch(`${getTenantApiUrl()}/admin/search/hubs?page=${page || 1}${query}`, requestOptions)
    .then(handleResponse)
}
function searchShipments (text, target, page, perPage) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  let query = ''

  query += `query=${text}&page=${page || 1}&per_page=${perPage}`

  return fetch(`${getTenantApiUrl()}/admin/search/shipments/${target}?${query}`, requestOptions)
    .then(handleResponse)
}

function getItineraries () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/itineraries`, requestOptions).then(handleResponse)
}

function getItinerary (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/itineraries/${id}`, requestOptions).then(handleResponse)
}
function viewTrucking (args) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const pageString = `page=${args.page || 1}&page_size=${args.pageSize || 10}`
  let filterString = ''
  if (args.filters.length > 0) {
    args.filters.forEach((filter) => {
      filterString += `${filter.id}=${filter.value}&`
    })
  }

  return fetch(`${getTenantApiUrl()}/admin/trucking/${args.hubId}?${pageString}&${filterString}`, requestOptions)
    .then(handleResponse)
}
function getLayovers (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/itineraries/${id}/layovers`, requestOptions)
    .then(handleResponse)
}

function getHub (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/hubs/${id}`, requestOptions).then(handleResponse)
}
function getLocalCharges (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/local_charges/${id}/hub`, requestOptions).then(handleResponse)
}

function wizardHubs (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }
  const uploadUrl = `${getTenantApiUrl()}/admin/hubs/process_csv`

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
  const uploadUrl = `${getTenantApiUrl()}/admin/local_charges/process_csv`

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
  const uploadUrl = `${getTenantApiUrl()}/admin/pricings/train_and_ocean_pricings/process_csv`

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
    uploadUrl = `${getTenantApiUrl()}/admin/trucking/trucking_zip_pricings`
  } else if (type === 'city') {
    uploadUrl = `${getTenantApiUrl()}/admin/trucking/trucking_city_pricings`
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
  const uploadUrl = `${getTenantApiUrl()}/admin/open_pricings/train_and_ocean_pricings/process_csv`

  return fetch(uploadUrl, requestOptions).then(handleResponse)
}

function getServiceCharges () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/local_charges`, requestOptions).then(handleResponse)
}
function getShipments (_pages, perPage, params) {
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

  const queryString = params ? toQueryString(params, true) : ''

  return fetch(`${getTenantApiUrl()}/admin/shipments?${query}${queryString}`, requestOptions).then(handleResponse)
}
function deltaShipmentsPage (target, page, perPage, params) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const query = `page=${page || 1}&target=${target}&per_page=${perPage}`

  const queryString = params ? toQueryString(params, true) : ''

  return fetch(`${getTenantApiUrl()}/admin/shipments/pages/delta_page_handler?${query}${queryString}`, requestOptions)
    .then(handleResponse)
}

function getDashboard () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/dashboard`, requestOptions).then(handleResponse)
}

function getShipment (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/shipments/${id}`, requestOptions).then(handleResponse)
}

function getItineraryPricings (id, groupId) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const queryString = groupId ? `?group_id=${groupId}` : ''

  return fetch(`${getTenantApiUrl()}/admin/route_pricings/${id}${queryString}`, requestOptions)
    .then(handleResponse)
}

function getGroupPricings (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/group_pricings/${id}`, requestOptions)
    .then(handleResponse)
}

function confirmShipment (id, action) {
  const requestOptions = {
    method: 'PUT',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ shipment_action: action })
  }
  const url = `${getTenantApiUrl()}/admin/shipments/${id}`

  return fetch(url, requestOptions).then(handleResponse)
}

function getPricings (args) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const queryObj = args

  if (args.filters) {
    args.filters.forEach((filter) => {
      queryObj[filter.id] = filter.value
    })
  }
  if (args.sorted) {
    args.sorted.forEach((filter) => {
      queryObj[`${filter.id}_desc`] = filter.desc
    })
  }

  const query = toSnakeQueryString(queryObj, true)

  return fetch(`${getTenantApiUrl()}/admin/pricings?${query}`, requestOptions)
    .then(handleResponse)
}

function searchPricings (text, page, mot) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/search/pricings?page=${page || 1}
    &mot=${mot}&text=${text}`, requestOptions)
    .then(handleResponse)
}

function deletePricing (pricing) {
  const requestOptions = {
    method: 'DELETE',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/pricings/${pricing.id}`, requestOptions)
    .then(handleResponse)
}

function deleteLocalCharge (localChargeId) {
  const requestOptions = {
    method: 'DELETE',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/local_charges/${localChargeId}`, requestOptions)
    .then(handleResponse)
}

function getClientPricings (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/client_pricings/${id}`, requestOptions)
    .then(handleResponse)
}

function getClients () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/clients`, requestOptions).then(handleResponse)
}

function getClient (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/clients/${id}`, requestOptions).then(handleResponse)
}

function getSchedules () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/schedules`, requestOptions).then(handleResponse)
}

function getTrucking () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/trucking`, requestOptions).then(handleResponse)
}

function getVehicleTypes (itineraryId) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/vehicle_types?itinerary_id=${itineraryId}`, requestOptions).then(handleResponse)
}

function autoGenSchedules (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }

  return fetch(`${getTenantApiUrl()}/admin/schedules/auto_generate`, requestOptions)
    .then(handleResponse)
}

function updatePricing (id, data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }

  return fetch(`${getTenantApiUrl()}/admin/pricings/update/${id}`, requestOptions)
    .then(handleResponse)
}
function assignDedicatedPricings (pricing, clientIds) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ pricing, clientIds })
  }

  return fetch(`${getTenantApiUrl()}/admin/pricings/assign_dedicated`, requestOptions)
    .then(handleResponse)
}
function getPricingsTest (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ data })
  }

  return fetch(`${getTenantApiUrl()}/admin/pricings/test/${data.itineraryId}`, requestOptions)
    .then(handleResponse)
}

function updateServiceCharge (id, data) {
  const requestOptions = {
    method: 'PUT',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ data })
  }

  return fetch(`${getTenantApiUrl()}/admin/local_charges/${id}`, requestOptions)
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

  return fetch(`${getTenantApiUrl()}/admin/clients`, requestOptions).then(handleResponse)
}

function activateHub (hubId) {
  const requestOptions = {
    method: 'PATCH',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/hubs/${hubId}/set_status`, requestOptions)
    .then(handleResponse)
}

function documentAction (docId, action) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(action)
  }

  return fetch(`${getTenantApiUrl()}/admin/documents/action/${docId}`, requestOptions)
    .then(handleResponse)
}

function deleteDocument (documentId) {
  const requestOptions = {
    method: 'DELETE',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/documents/${documentId}`, requestOptions).then(handleResponse)
}

function saveNewHub (hub, address) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ hub, address })
  }

  return fetch(`${getTenantApiUrl()}/admin/hubs`, requestOptions).then(handleResponse)
}
function deleteHub (hubId) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getTenantApiUrl()}/admin/hubs/${hubId}/delete`, requestOptions)
    .then(handleResponse)
}

function deleteClient (id) {
  const requestOptions = {
    method: 'DELETE',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getTenantApiUrl()}/admin/clients/${id}`, requestOptions)
    .then(handleResponse)
}
function editHub (hubId, object) {
  const requestOptions = {
    method: 'PATCH',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(object)
  }

  return fetch(`${getTenantApiUrl()}/admin/hubs/${hubId}`, requestOptions)
    .then(handleResponse)
}
function newRoute (itinerary) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ itinerary })
  }

  return fetch(`${getTenantApiUrl()}/admin/itineraries`, requestOptions).then(handleResponse)
}
function saveNewTrucking (obj) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ obj })
  }

  return fetch(`${getTenantApiUrl()}/admin/trucking`, requestOptions).then(handleResponse)
}
function assignManager (obj) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ obj })
  }

  return fetch(`${getTenantApiUrl()}/admin/user_managers/assign`, requestOptions)
    .then(handleResponse)
}
function editShipmentPrice (id, priceObj) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ priceObj })
  }

  return fetch(`${getTenantApiUrl()}/admin/shipments/${id}/edit_price`, requestOptions)
    .then(handleResponse)
}
function editShipmentServicePrice (id, data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }

  return fetch(`${getTenantApiUrl()}/admin/shipments/${id}/edit_service_price`, requestOptions)
    .then(handleResponse)
}
function editLocalCharges (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ data })
  }

  return fetch(`${getTenantApiUrl()}/admin/local_charges/${data.id}/edit`, requestOptions)
    .then(handleResponse)
}
function editCustomsFees (data) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ data })
  }

  return fetch(`${getTenantApiUrl()}/admin/customs_fees/${data.id}/edit`, requestOptions)
    .then(handleResponse)
}
function editShipmentTime (id, timeObj) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ timeObj })
  }

  return fetch(`${getTenantApiUrl()}/admin/shipments/${id}/edit_time`, requestOptions)
    .then(handleResponse)
}
function deleteItinerary (id) {
  const requestOptions = {
    method: 'DELETE',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getTenantApiUrl()}/admin/itineraries/${id}`, requestOptions).then(handleResponse)
}
function deleteTrip (id) {
  const requestOptions = {
    method: 'DELETE',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getTenantApiUrl()}/admin/schedules/${id}`, requestOptions).then(handleResponse)
}

function uploadTrucking (url, file, group) {
  const formData = new FormData()
  formData.append('file', file)
  formData.append('group', group)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getTenantApiUrl()}${url}`, requestOptions).then(handleResponse)
}

function uploadAgents (file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getTenantApiUrl()}/admin/clients/agents`, requestOptions).then(handleResponse)
}

function newHubImage (id, file) {
  const formData = new FormData()
  formData.append('file', file)
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader() },
    body: formData
  }

  return fetch(`${getTenantApiUrl()}/admin/hubs/${id}/image`, requestOptions).then(handleResponse)
}

function loadItinerarySchedules (id) {
  const requestOptions = {
    method: 'GET',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getTenantApiUrl()}/admin/schedules/${id}`, requestOptions).then(handleResponse)
}
function saveItineraryNotes (id, notes) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ notes })
  }

  return fetch(`${getTenantApiUrl()}/admin/itineraries/${id}/edit_notes`, requestOptions)
    .then(handleResponse)
}

function deleteItineraryNote (itineraryId, noteId) {
  const requestOptions = {
    method: 'DELETE',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getTenantApiUrl()}/admin/itineraries/${itineraryId}/notes/${noteId}`, requestOptions)
    .then(handleResponse)
}

function editTruckingPrice (pricing) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ pricing })
  }

  return fetch(`${getTenantApiUrl()}/admin/trucking/${pricing.id}/edit`, requestOptions)
    .then(handleResponse)
}
function updateHubMandatoryCharges (id, charges) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ mandatoryCharge: charges })
  }

  return fetch(`${getTenantApiUrl()}/admin/hubs/${id}/update_mandatory_charges`, requestOptions)
    .then(handleResponse)
}
function disablePricing (args) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...args })
  }

  return fetch(`${getTenantApiUrl()}/admin/pricings/${args.pricing_id}/disable`, requestOptions)
    .then(handleResponse)
}
function updateEmails (emails, tenant) {
  const requestOptions = {
    method: 'PATCH',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ tenant: { emails } })
  }

  return fetch(`${getTenantApiUrl()}/admin/tenants/${tenant.id}`, requestOptions)
    .then(handleResponse)
}

export const adminService = {
  getHubs,
  getHub,
  disablePricing,
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
  updateEmails,
  getLocalCharges,
  uploadAgents,
  getGroupPricings,
  deleteLocalCharge
}

export default adminService

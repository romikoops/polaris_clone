import { Promise } from 'es6-promise-promise'
import { getTenantApiUrl } from '../constants/api.constants'
import { authHeader, toSnakeQueryString, toQueryString } from '../helpers'

const { fetch, FormData } = window

function handleResponse (response) {
  const promise = Promise
  if (!response.ok) {
    return promise.reject(response.statusText)
  }

  return response.json()
}

function getClientsForList (args) {
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

  return fetch(`${getTenantApiUrl()}/admin/clients?${query}`, requestOptions)
    .then(handleResponse)
}

function getGroupsForList (args) {
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

  return fetch(`${getTenantApiUrl()}/admin/groups?${query}`, requestOptions)
    .then(handleResponse)
}

function getGroupsAndMargins (args) {
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

  const query = toSnakeQueryString(queryObj, true)

  return fetch(`${getTenantApiUrl()}/admin/groups/with_margins?${query}`, requestOptions)
    .then(handleResponse)
}

function getMarginsForList (args) {
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

  const query = toSnakeQueryString(queryObj, true)

  return fetch(`${getTenantApiUrl()}/admin/margins?${query}`, requestOptions)
    .then(handleResponse)
}

function getLocalChargesForList (args) {
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
  const query = toSnakeQueryString(queryObj, true)

  return fetch(`${getTenantApiUrl()}/admin/local_charges?${query}`, requestOptions)
    .then(handleResponse)
}

function viewGroup (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/groups/${id}`, requestOptions)
    .then(handleResponse)
}

function viewClient (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/clients/${id}`, requestOptions)
    .then(handleResponse)
}

function viewCompany (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/companies/${id}`, requestOptions)
    .then(handleResponse)
}

function getMarginFormData (id) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/margins/form/data${id ? `?itinerary_id=${id}` : ''}`, requestOptions)
    .then(handleResponse)
}

function testMargins (args) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const query = toSnakeQueryString(args, true)

  return fetch(`${getTenantApiUrl()}/admin/margins/test/data?${query}`, requestOptions)
    .then(handleResponse)
}

function getFinerMarginDetails (args) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const query = toSnakeQueryString(args, true)

  return fetch(`${getTenantApiUrl()}/admin/margins/form/fee_data?${query}`, requestOptions)
    .then(handleResponse)
}

function createGroup (args) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...args })
  }

  return fetch(`${getTenantApiUrl()}/admin/groups`, requestOptions)
    .then(handleResponse)
}

function createCompany (args) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...args })
  }

  return fetch(`${getTenantApiUrl()}/admin/companies`, requestOptions)
    .then(handleResponse)
}

function createMargin (args) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...args })
  }

  return fetch(`${getTenantApiUrl()}/admin/margins`, requestOptions)
    .then(handleResponse)
}

function deleteMargin (id) {
  const requestOptions = {
    method: 'DELETE',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getTenantApiUrl()}/admin/margins/${id}`, requestOptions)
    .then(handleResponse)
}

function editGroupMembers (args) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...args })
  }

  return fetch(`${getTenantApiUrl()}/admin/groups/${args.id}/edit_members`, requestOptions)
    .then(handleResponse)
}

function editMemberships (args) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...args })
  }

  return fetch(`${getTenantApiUrl()}/admin/memberships/bulk_edit`, requestOptions)
    .then(handleResponse)
}

function editCompanyEmployees (args) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...args })
  }

  return fetch(`${getTenantApiUrl()}/admin/companies/${args.id}/edit_employees`, requestOptions)
    .then(handleResponse)
}

function updateMarginValues (args) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...args })
  }

  return fetch(`${getTenantApiUrl()}/admin/margins/update/multiple`, requestOptions)
    .then(handleResponse)
}
function membershipData (args) {
  const requestOptions = {
    method: 'GET',
    headers: { ...authHeader() }
  }
  const query = toQueryString(args, true)

  return fetch(`${getTenantApiUrl()}/admin/memberships/membership_data?${query}`, requestOptions)
    .then(handleResponse)
}

function getCompaniesForList (args) {
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

  return fetch(`${getTenantApiUrl()}/admin/companies?${query}`, requestOptions)
    .then(handleResponse)
}

function fetchTargetScope (args) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  const query = toSnakeQueryString(args, true)

  return fetch(`${getTenantApiUrl()}/admin/scopes/${args.target_id}?${query}`, requestOptions)
    .then(handleResponse)
}

function deleteGroup (id) {
  const requestOptions = {
    method: 'DELETE',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/groups/${id}`, requestOptions)
    .then(handleResponse)
}

function deleteCompany (id) {
  const requestOptions = {
    method: 'DELETE',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/companies/${id}`, requestOptions)
    .then(handleResponse)
}

export const clientsService = {
  getGroupsAndMargins,
  getClientsForList,
  membershipData,
  fetchTargetScope,
  updateMarginValues,
  getCompaniesForList,
  getGroupsForList,
  createGroup,
  viewGroup,
  viewCompany,
  editGroupMembers,
  getMarginFormData,
  getFinerMarginDetails,
  createMargin,
  getMarginsForList,
  editMemberships,
  viewClient,
  testMargins,
  deleteMargin,
  editCompanyEmployees,
  createCompany,
  deleteGroup,
  deleteCompany,
  getLocalChargesForList
}

export default clientsService

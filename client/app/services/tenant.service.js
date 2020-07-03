import { Promise } from 'es6-promise-promise'
import { getTenantApiUrl } from '../constants/api.constants'
import { authHeader } from '../helpers'

const { fetch } = window

function handleResponse (response) {
  const promise = Promise
  if (!response.ok) {
    return promise.reject(response.statusText)
  }

  return response.json()
}

function updateEmails (emails, tenant) {
  const requestOptions = {
    method: 'PATCH',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ tenant: { emails } })
  }

  return fetch(`${getTenantApiUrl()}/admin/organizations/${tenant.id}`, requestOptions)
    .then(handleResponse)
}

export const tenantService = {
  updateEmails
}

export default tenantService

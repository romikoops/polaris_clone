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

function getRemarks () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/admin/remarks`, requestOptions).then(handleResponse)
}

function addRemark (category, subcategory, body) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ category, subcategory, body })
  }

  return fetch(`${getTenantApiUrl()}/admin/remarks`, requestOptions)
    .then(handleResponse)
}

function updateRemarks (newRemark) {
  const requestOptions = {
    method: 'PATCH',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ remark: newRemark })
  }

  return fetch(`${getTenantApiUrl()}/admin/remarks/${newRemark.id}`, requestOptions)
    .then(handleResponse)
}

function deleteRemark (remarkId) {
  const requestOptions = {
    method: 'DELETE',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }

  return fetch(`${getTenantApiUrl()}/admin/remarks/${remarkId}`, requestOptions)
    .then(handleResponse)
}

export const remarkService = {
  addRemark,
  updateRemarks,
  deleteRemark,
  getRemarks
}
export default remarkService

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

export const documentService = {
  uploadPricings
}

export default documentService

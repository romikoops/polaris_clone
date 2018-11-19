import { authHeader } from '../helpers'
import { getTenantApiUrl } from '../constants/api.constants'

const { fetch } = window

export default function emailServerValidation (key, id, value, callback) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const query = `${key}=${value}`

  return fetch(`${getTenantApiUrl()}/contacts/validations/form?${query}`, requestOptions)
    .then(response => response.json())
    .then((response) => {
      if (response) {
        callback(response.data)
      }
    })
}

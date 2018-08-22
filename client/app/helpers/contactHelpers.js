import { authHeader } from '../helpers'
import { BASE_URL } from '../constants'

const { fetch } = window

export default function emailServerValidation (key, id, value, callback) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  const query = `${key}=${value}`

  return fetch(`${BASE_URL}/contacts/validations/form?${query}`, requestOptions)
    .then(response => response.json())
    .then((response) => {
      if (response) {
        callback(response.data)
      }
    })
}

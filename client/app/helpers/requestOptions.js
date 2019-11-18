import { authHeader } from '.'

export function requestOptions (method, headers = {}) {
  return {
    method: method.toUpperCase(),
    headers: { ...authHeader(), ...headers }
  }
}

export default requestOptions

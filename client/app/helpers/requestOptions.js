import { authHeader } from '.'

export function requestOptions (method, headers = {}, body = {}) {
  const upcaseMethod = method.toUpperCase()
  const options = {
    method: upcaseMethod,
    headers: { ...authHeader(), ...headers }
  }
  if (upcaseMethod !== 'GET') {
    options.body = body
  }

  return options
}

export default requestOptions

export function authHeader () {
  const aHeader = JSON.parse(window.localStorage.getItem('authHeader'))
  const sandbox = JSON.parse(window.localStorage.getItem('sandbox'))
  if (aHeader) {
    aHeader.sandbox = sandbox

    return aHeader
  }

  return {}
}

export default authHeader

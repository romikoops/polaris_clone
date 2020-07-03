const AUTH_STORE_KEY = 'authHeader'

export const authHeader = () => {
  const token = JSON.parse(localStorage.getItem(AUTH_STORE_KEY))

  if (!token) {
    return {}
  }
  return {
    Authorization: `${token.token_type} ${token.access_token}`
  }
}

export default authHeader

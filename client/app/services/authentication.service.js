import { Promise } from 'es6-promise-promise'
import { getTenantApiUrl, getApiHost } from '../constants/api.constants'
import { authHeader, cookieKey } from '../helpers'

const { fetch, localStorage } = window

function logout () {
  // remove user from local storage to log user out
  localStorage.removeItem(cookieKey())
  localStorage.removeItem('authHeader')
}

function handleResponse (response) {
  const promise = Promise
  if (!response.ok) {
    return promise.reject(response.statusText)
  }

  return response.json()
}

function toggleSandbox (id) {
  localStorage.setItem('sandbox', id)
}

function login (data) {
  const requestOptions = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: data.email,
      password: data.password,
      client_id: '935cf198dbdcacf265f614066763cf04aee20a1e465c7339fcf19ed7884cf26a',
      client_secret: '420f69ad7194efd9c6a29a3f964a6453c274de3557b987d7228bf5ed6fb028e2',
      scope: 'public', // {TODO} determine this from user scope
      grant_type: 'password'
    })
  }

  return fetch(`${getApiHost()}/oauth/token`, requestOptions)
    .then((response) => {
      if (!response.ok) {
        return Promise.reject(response.json())
      }
      return response.json()
    })
    .then((response) => {
      if (response) {
        localStorage.setItem('authHeader', JSON.stringify(response))
      }

      return response
    })
}

// TODO{H.Ezekiel} get refresh token after current token expires;
function getRefreshToken() {}

function getStoredUser () {
  const sortedUser = JSON.parse(localStorage.getItem(cookieKey()))

  return sortedUser || {}
}

function register (user) {
  const organizationId = localStorage.getItem('organizationId')
  const requestOptions = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ user: { ...user, organization_id: organizationId } })
  }

  return fetch(`${getTenantApiUrl()}/users`, requestOptions)
    .then((response) => {
      if (!response.ok) {
        return Promise.reject(response.json())
      }

      return response.json()
    })
    .then(({ data: token }) => {
      const payload = {
        scope: token.scope,
        token_type: token.token_type,
        access_token: token.access_token,
        refresh_token: token.refresh_token,
        created_at: token.created_at,
        expires_in: token.expires_in
      }
      localStorage.setItem('authHeader', JSON.stringify(payload))

      return token
    })
}

function updateUser (user, req) {
  const requestOptions = {
    method: 'PUT',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ update: req })
  }

  return fetch(`${getTenantApiUrl()}/users/${user.id}/update`, requestOptions)
    .then((response) => {
      if (!response.ok) {
        return Promise.reject(response.statusText)
      }

      return response.json()
    })
    .then((response) => {
      // login successful if there's a jwt token in the response
      if (response) {
        if (response.data.headers) {
          localStorage.setItem('authHeader', JSON.stringify(response.data.headers))
        }
        // store user details and jwt token in local storage to keep
        // user logged in between page refreshes
        localStorage.setItem(cookieKey(), JSON.stringify(response.data.user))
      }

      return response
    })
}

function changePassword (email, redirect) {
  const payload = {
    email,
    redirect_url: redirect
  }

  return fetch(`${getTenantApiUrl()}/password_resets`, {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  }).then(handleResponse)
}

const authenticationService = {
  logout,
  register,
  getStoredUser,
  updateUser,
  toggleSandbox,
  changePassword
}

export default authenticationService

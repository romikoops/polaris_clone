import { Promise } from 'es6-promise-promise'
import { getTenantApiUrl } from '../constants/api.constants'
import { authHeader } from '../helpers'
import getSubdomain from '../helpers/subdomain'

const { fetch, localStorage } = window

const subdomainKey = getSubdomain()
const cookieKey = `${subdomainKey}_user`
function logout () {
  // remove user from local storage to log user out
  localStorage.removeItem(cookieKey)
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
    body: JSON.stringify({ email: data.email, password: data.password })
  }

  return fetch(`${getTenantApiUrl()}/auth/sign_in`, requestOptions)
    .then((response) => {
      if (!response.ok) {
        return Promise.reject(response.json())
      }
      if (response.headers.get('access-token')) {
        const accessToken = response.headers.get('access-token')
        const client = response.headers.get('client')
        const expiry = response.headers.get('expiry')
        const tokenType = response.headers.get('token-type')
        const uid = response.headers.get('uid')
        const aHeader = {
          client,
          expiry,
          uid,
          'access-token': accessToken,
          'token-type': tokenType
        }
        localStorage.setItem('authHeader', JSON.stringify(aHeader))
      }
      return response.json()
    })
    .then((response) => {
      // login successful if there's a jwt token in the response
      if (response) {
        // store user details and jwt token in local storage to keep
        // user logged in between page refreshes
        localStorage.setItem(cookieKey, JSON.stringify(response.data))
      }

      return response
    })
}

function getStoredUser () {
  const sortedUser = JSON.parse(localStorage.getItem(cookieKey))
  return sortedUser || {}
}

function register (user) {
  const requestOptions = {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(user)
  }

  return fetch(`${getTenantApiUrl()}/auth/`, requestOptions)
    .then((response) => {
      if (!response.ok) {
        return Promise.reject(response.statusText)
      }

      if (response.headers.get('access-token')) {
        const accessToken = response.headers.get('access-token')
        const client = response.headers.get('client')
        const expiry = response.headers.get('expiry')
        const tokenType = response.headers.get('token-type')
        const uid = response.headers.get('uid')
        const aHeader = {
          client,
          expiry,
          uid,
          'access-token': accessToken,
          'token-type': tokenType
        }
        localStorage.setItem('authHeader', JSON.stringify(aHeader))
      }
      return response.json()
    })
    .then((response) => {
      // login successful if there's a jwt token in the response
      if (response) {
        // store user details and jwt token in local storage to keep
        // user logged in between page refreshes
        localStorage.setItem(cookieKey, JSON.stringify(response.data))
      }
      return response
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
        localStorage.setItem(cookieKey, JSON.stringify(response.data.user))
      }
      return response
    })
}

function changePassword (email, redirect) {
  const payload = {
    email,
    redirect_url: redirect
  }

  return fetch(`${getTenantApiUrl()}/auth/password`, {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  }).then(handleResponse)
}

const authenticationService = {
  login,
  logout,
  register,
  getStoredUser,
  updateUser,
  toggleSandbox,
  changePassword
}

export default authenticationService

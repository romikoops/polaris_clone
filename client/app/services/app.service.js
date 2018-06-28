import { Promise } from 'es6-promise-promise'
import { BASE_URL } from '../constants'
import { authHeader } from '../helpers'

const { fetch } = window

function handleResponse (response) {
  const promise = Promise
  const respJSON = response.json()
  if (!response.ok) {
    return promise.reject(respJSON)
  }

  return respJSON
}

function fetchCurrencies () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  return fetch(`${BASE_URL}/currencies/get`, requestOptions).then(handleResponse)
}

function refreshRates (base) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  return fetch(`${BASE_URL}/currencies/refresh/${base}`, requestOptions).then(handleResponse)
}

function fetchCurrenciesForBase (base) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }
  return fetch(`${BASE_URL}/currencies/base/${base}`, requestOptions).then(handleResponse)
}

function setCurrency (currency) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ currency })
  }
  const url = `${BASE_URL}/currencies/set`
  // FIXME: console.log(url)
  return fetch(url, requestOptions).then(handleResponse)
}
function toggleTenantCurrencyMode () {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }
  const url = `${BASE_URL}/admin/currencies/toggle_mode`
  // FIXME: console.log(url)
  return fetch(url, requestOptions).then(handleResponse)
}
function setTenantCurrencyRates (base, rates) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ base, rates })
  }
  const url = `${BASE_URL}/admin/currencies/set_rates`
  // FIXME: console.log(url)
  return fetch(url, requestOptions).then(handleResponse)
}

const appService = {
  fetchCurrencies,
  setCurrency,
  fetchCurrenciesForBase,
  refreshRates,
  toggleTenantCurrencyMode,
  setTenantCurrencyRates
}

export default appService

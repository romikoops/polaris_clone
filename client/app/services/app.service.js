import { Promise } from 'es6-promise-promise'
import { getApiHost, getTenantApiUrl, getTenantIndex } from '../constants/api.constants'
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

function setTenant () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getApiHost()}/`, requestOptions).then(handleResponse)
}

function setTenants () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantIndex()}/`, requestOptions).then(handleResponse)
}

function setNewTenant (tenantId) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantIndex()}/${tenantId}`, requestOptions).then(handleResponse)
}

function fetchCurrencies () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/currencies/get`, requestOptions).then(handleResponse)
}

function refreshRates (base) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/currencies/refresh/${base}`, requestOptions)
    .then(handleResponse)
}

function fetchCurrenciesForBase (base) {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/currencies/base/${base}`, requestOptions).then(handleResponse)
}

function setCurrency (currency) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ currency })
  }
  const url = `${getTenantApiUrl()}/currencies/set`
  // FIXME: console.log(url)

  return fetch(url, requestOptions).then(handleResponse)
}
function fetchCountries () {
  const requestOptions = {
    method: 'GET',
    headers: authHeader()
  }

  return fetch(`${getTenantApiUrl()}/countries`, requestOptions).then(handleResponse)
}
function toggleTenantCurrencyMode () {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' }
  }
  const url = `${getTenantApiUrl()}/admin/currencies/toggle_mode`
  // FIXME: console.log(url)

  return fetch(url, requestOptions).then(handleResponse)
}
function setTenantCurrencyRates (base, rates) {
  const requestOptions = {
    method: 'POST',
    headers: { ...authHeader(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ base, rates })
  }
  const url = `${getTenantApiUrl()}/admin/currencies/set_rates`
  // FIXME: console.log(url)

  return fetch(url, requestOptions).then(handleResponse)
}

const appService = {
  fetchCurrencies,
  setCurrency,
  fetchCountries,
  fetchCurrenciesForBase,
  refreshRates,
  setTenant,
  setTenants,
  setNewTenant,
  toggleTenantCurrencyMode,
  setTenantCurrencyRates
}

export default appService

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

const appService = {
  fetchCurrencies,
  setCurrency
}

export default appService

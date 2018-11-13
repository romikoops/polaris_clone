import { Promise } from 'es6-promise-promise'
import { push } from 'react-router-redux'
import { appConstants } from '../constants'
import getApiHost from '../constants/api.constants'
import { appService } from '../services'
import {
  shipmentActions,
  userActions,
  adminActions,
  authenticationActions,
  documentActions,
  tenantActions
} from './'
import getSubdomain from '../helpers/subdomain'

const { fetch } = window

function setTenant (tenantId) {
  function request () {
  }
  function success (payload) {
    return { type: 'TEST', payload }
  }
  function failure (error) {
  }

  return (dispatch) => {
    appService.setTenant(tenantId).then(
      (resp) => {
        dispatch(success(resp))
      },
      () => {
        // TODO
      }
    )
  }
}

function fetchCurrencies (type) {
  function request (currencyReq) {
    return { type: appConstants.FETCH_CURRENCIES_REQUEST, payload: currencyReq }
  }
  function success (currencyData) {
    return { type: appConstants.FETCH_CURRENCIES_SUCCESS, payload: currencyData }
  }
  function failure (error) {
    return { type: appConstants.FETCH_CURRENCIES_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request(type))
    appService.fetchCurrencies(type).then(
      (resp) => {
        const currData = resp.data
        dispatch(success(currData))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}
function fetchCountries () {
  function request (countryReq) {
    return { type: appConstants.FETCH_COUNTRIES_REQUEST, payload: countryReq }
  }
  function success (countryData) {
    return { type: appConstants.FETCH_COUNTRIES_SUCCESS, payload: countryData }
  }
  function failure (error) {
    return { type: appConstants.FETCH_COUNTRIES_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request())
    appService.fetchCountries().then(
      (resp) => {
        const currData = resp.data
        dispatch(success(currData))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}
function refreshRates (type) {
  function request (currencyReq) {
    return { type: appConstants.REFRESH_CURRENCIES_REQUEST, payload: currencyReq }
  }
  function success (currencyData) {
    return { type: appConstants.REFRESH_CURRENCIES_SUCCESS, payload: currencyData }
  }
  function failure (error) {
    return { type: appConstants.REFRESH_CURRENCIES_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request(type))
    appService.refreshRates(type).then(
      (resp) => {
        const currData = resp.data
        dispatch(success(currData))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function fetchCurrenciesForBase (base) {
  function request (currencyReq) {
    return { type: appConstants.FETCH_CURRENCIES_FOR_BASE_REQUEST, payload: currencyReq }
  }
  function success (currencyData) {
    return { type: appConstants.FETCH_CURRENCIES_FOR_BASE_SUCCESS, payload: currencyData }
  }
  function failure (error) {
    return { type: appConstants.FETCH_CURRENCIES_FOR_BASE_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request(base))
    appService.fetchCurrenciesForBase(base).then(
      (resp) => {
        const currData = resp.data
        dispatch(success(currData))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function setCurrency (type, req) {
  function request (currencyReq) {
    return { type: appConstants.SET_CURRENCY_REQUEST, payload: currencyReq }
  }
  function success (currencyData) {
    return { type: appConstants.SET_CURRENCY_SUCCESS, payload: currencyData }
  }
  function failure (error) {
    return { type: appConstants.SET_CURRENCY_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request(type))
    appService.setCurrency(type).then(
      (resp) => {
        dispatch(success(resp.data.rates))
        dispatch(authenticationActions.setUser({ data: resp.data.user }))
        if (req) {
          dispatch(shipmentActions.getOffers(req, false))
        }
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}
function toggleTenantCurrencyMode () {
  function request (currencyReq) {
    return { type: appConstants.SET_CURRENCY_REQUEST, payload: currencyReq }
  }
  function success (currencyData) {
    return { type: appConstants.SET_CURRENCY_SUCCESS, payload: currencyData }
  }
  function failure (error) {
    return { type: appConstants.SET_CURRENCY_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request())
    appService.toggleTenantCurrencyMode().then(
      (resp) => {
        dispatch(success(resp.data.rates))
        dispatch(tenantActions
          .receiveTenant(resp.data.tenant.subdomain, resp.data.tenant))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}
function setTenantCurrencyRates (base, rates) {
  function request (currencyReq) {
    return { type: appConstants.FETCH_CURRENCIES_REQUEST, payload: currencyReq }
  }
  function success (currencyData) {
    return { type: appConstants.FETCH_CURRENCIES_SUCCESS, payload: currencyData }
  }
  function failure (error) {
    return { type: appConstants.SET_CURRENCY_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request())
    appService.setTenantCurrencyRates(base, rates).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function requestTenant (subdomain) {
  return {
    type: appConstants.REQUEST_TENANT,
    subdomain
  }
}

function receiveTenant (subdomain, json) {
  return {
    type: appConstants.RECEIVE_TENANT,
    subdomain,
    data: json,
    receivedAt: Date.now()
  }
}
function receiveTenants (json) {
  return {
    type: appConstants.RECEIVE_TENANTS,
    payload: json,
    receivedAt: Date.now()
  }
}

function invalidateSubdomain (subdomain) {
  return {
    type: appConstants.INVALIDATE_SUBDOMAIN,
    subdomain
  }
}

function fetchTenant (subdomain) {
  function failure (error) {
    return { type: appConstants.RECEIVE_TENANT_ERROR, error }
  }

  return (dispatch) => {
    dispatch(requestTenant(subdomain))
    let subdomainToFetch
    if (!subdomain) {
      subdomainToFetch = getSubdomain()
    } else {
      subdomainToFetch = subdomain
    }

    return fetch(`${getApiHost()}/tenants/${subdomainToFetch}`)
      .then(response => response.json())
      .then(
        json => dispatch(receiveTenant(subdomainToFetch, json)),
        err => dispatch(failure(err))
      )
  }
}
function fetchTenants () {
  function failure (error) {
    return { type: appConstants.RECEIVE_TENANT_ERROR, error }
  }

  return dispatch => fetch(`${getApiHost()}/tenants`)
    .then(response => response.json())
    .then(json => dispatch(receiveTenants(json)), err => dispatch(failure(err)))
}
function shouldFetchTenant (state, subdomain) {
  const { tenant } = state
  if (!tenant.data || (Object.keys(tenant.data).length < 1) ||
  (tenant && tenant.data && tenant.data.subdomain !== subdomain)) {
    return true
  }
  if (tenant.isFetching) {
    return false
  }

  return tenant.didInvalidate
}

function fetchTenantIfNeeded (subdomain) {
  // Note that the function also receives getState()
  // which lets you choose what to dispatch next.

  // This is useful for avoiding a network request if
  // a cached value is already available.

  return (dispatch, getState) => {
    if (shouldFetchTenant(getState(), subdomain)) {
      // Dispatch a thunk from thunk!
      return dispatch(fetchTenant(subdomain))
    }

    // Let the calling code know there's nothing to wait for.
    return Promise.resolve()
  }
}
function setTheme (theme) {
  return { type: appConstants.SET_THEME, payload: theme }
}
function clearLoading () {
  return (dispatch) => {
    dispatch(shipmentActions.clearLoading())
    dispatch(userActions.clearLoading())
    dispatch(adminActions.clearLoading())
    dispatch(documentActions.clearLoading())
  }
}

function goTo (path) {
  return (dispatch) => {
    dispatch(push(path))
  }
}

export const appActions = {
  fetchCurrencies,
  fetchCountries,
  shouldFetchTenant,
  fetchTenantIfNeeded,
  invalidateSubdomain,
  setCurrency,
  clearLoading,
  setTenant,
  goTo,
  fetchTenants,
  setTheme,
  fetchCurrenciesForBase,
  refreshRates,
  toggleTenantCurrencyMode,
  setTenantCurrencyRates
}

export default appActions

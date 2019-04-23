import { push } from 'react-router-redux'
import { appConstants } from '../constants'
import { getApiHost } from '../constants/api.constants'
import { appService } from '../services'

import {
  shipmentActions,
  userActions,
  adminActions,
  authenticationActions,
  documentActions,
  tenantActions
} from '.'

const { fetch } = window

function setTenants () {
  function request () {
    return { type: appConstants.SET_TENANTS_REQUEST }
  }
  function success (payload) {
    return { type: appConstants.SET_TENANTS_SUCCESS, payload }
  }
  function failure (error) {
    return { type: appConstants.SET_TENANTS_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    appService.setTenants().then(
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

function overrideTenant (tenantId) {
  const { localStorage } = window

  function success (payload) {
    return { type: appConstants.OVERRIDE_TENANT_SUCCESS, payload }
  }

  return (dispatch) => {
    localStorage.setItem('tenantId', tenantId)
    dispatch(success(tenantId))

    dispatch(getTenant())
  }
}

function getTenantId () {
  const { localStorage } = window

  function request () {
    return { type: appConstants.SET_TENANT_ID_REQUEST }
  }

  function success (payload) {
    return { type: appConstants.SET_TENANT_ID_SUCCESS, payload }
  }

  function failure (error) {
    return { type: appConstants.SET_TENANT_ID_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)

    const tenantId = localStorage.getItem('tenantId')

    if (tenantId) {
      dispatch(success(tenantId))
      dispatch(getTenant())
    } else {
      appService.getTenantId().then(
        (resp) => {
          localStorage.setItem('tenantId', resp.data.tenant_id)

          dispatch(success(resp.data.tenant_id))
          dispatch(getTenant())
        },
        (error) => {
          error.then((data) => {
            dispatch(failure({ type: 'error', text: data.message }))
          })
        }
      )
    }
  }
}

function getTenant () {
  const { localStorage } = window

  function request () {
    return { type: appConstants.SET_TENANT_REQUEST }
  }

  function success (payload) {
    return { type: appConstants.SET_TENANT_SUCCESS, payload }
  }

  function failure (error) {
    return { type: appConstants.SET_TENANT_ERROR, error }
  }

  return (dispatch) => {
    const tenantId = localStorage.getItem('tenantId')

    dispatch(request)

    appService.getTenant(tenantId).then(
      (resp) => {
        dispatch(success(resp.data))
        dispatch(fetchCurrencies())
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function getScope () {
  function request () {
    return { type: appConstants.FETCH_SCOPE_REQUEST }
  }

  function success (payload) {
    return { type: appConstants.FETCH_SCOPE_SUCCESS, payload }
  }

  function failure (error) {
    return { type: appConstants.FETCH_SCOPE_ERROR, error }
  }

  return (dispatch) => {
  
    dispatch(request)

    appService.getScope().then(
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
    appService.fetchCurrencies().then(
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

function fetchTenants () {
  function failure (error) {
    return { type: appConstants.RECEIVE_TENANT_ERROR, error }
  }

  return dispatch => fetch(`${getApiHost()}/tenants`)
    .then(response => response.json())
    .then(json => dispatch(receiveTenants(json)), err => dispatch(failure(err)))
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
  clearLoading,
  fetchCountries,
  fetchCurrencies,
  fetchCurrenciesForBase,
  fetchTenants,
  getTenant,
  getTenantId,
  goTo,
  invalidateSubdomain,
  overrideTenant,
  refreshRates,
  setCurrency,
  setTenantCurrencyRates,
  setTenants,
  setTheme,
  toggleTenantCurrencyMode,
  getScope
}

export default appActions

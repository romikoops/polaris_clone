import { push } from 'react-router-redux'
import { get } from 'lodash'
import { appConstants } from '../constants'
import { appService } from '../services'
import { getApiHost } from '../constants/api.constants'
import { requestOptions } from '../helpers'
import {
  shipmentActions,
  userActions,
  adminActions,
  authenticationActions,
  documentActions,
  tenantActions
} from '.'

const { fetch } = window

// New Format (Action only)

function getTenantId () {
  const { localStorage } = window

  function request () {
    return { type: appConstants.SET_ORGANIZATION_ID_REQUEST }
  }

  function success (payload) {
    return { type: appConstants.SET_ORGANIZATION_ID_SUCCESS, payload }
  }

  function failure (error) {
    return { type: appConstants.SET_ORGANIZATION_ID_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request())

    const organizationId = localStorage.getItem('organizationId')

    if (organizationId && organizationId !== 'null') {
      dispatch(success(organizationId))

      return dispatch(getTenant())
    }

    return fetch(`${getApiHost()}/organizations/current`, requestOptions('get'))
      .then((resp) => resp.json())
      .then((res) => {
        const newTenantId = get(res, ['data', 'organization_id'], false)
        if (newTenantId) {
          localStorage.setItem('organizationId', newTenantId)
          dispatch(success(newTenantId))
          dispatch(getTenant())
        } else {
          dispatch(failure({ text: 'Null Id' }))
        }
      })
      .catch((_error) => {
        dispatch(failure({ text: 'Invalid Response' }))
      })
  }
}

// Legacy Format (Action + Service)

function setTenants () {
  function request () {
    return { type: appConstants.SET_ORGANIZATIONS_REQUEST }
  }
  function success (payload) {
    return { type: appConstants.SET_ORGANIZATIONS_SUCCESS, payload }
  }
  function failure (error) {
    return { type: appConstants.SET_ORGANIZATIONS_ERROR, error }
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

function overrideTenant (organizationId) {
  const { localStorage } = window

  function success (payload) {
    return { type: appConstants.OVERRIDE_ORGANIZATION_SUCCESS, payload }
  }

  return (dispatch) => {
    localStorage.setItem('organizationId', organizationId)
    dispatch(success(organizationId))

    dispatch(getTenant())
  }
}

function getTenant () {
  const { localStorage } = window

  function request () {
    return { type: appConstants.SET_ORGANIZATION_REQUEST }
  }

  function success (payload) {
    return { type: appConstants.SET_ORGANIZATION_SUCCESS, payload }
  }

  function failure (payload) {
    return { type: appConstants.SET_ORGANIZATION_ERROR, payload }
  }

  return (dispatch) => {
    const organizationId = localStorage.getItem('organizationId')

    dispatch(request)

    appService.getTenant(organizationId).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        if (error.then) {
          error.then((data) => {
            dispatch(failure({ type: 'error', text: data.message }))
          })
        } else {
          dispatch(failure({ type: 'FATAL', text: error.message || error }))
        }
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

    return appService.setCurrency(type).then(
      (resp) => {
        dispatch(success(resp.data.rates))
        dispatch(authenticationActions.setUser(resp.data.user))
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
          .receiveTenant(resp.data.tenant.slug, resp.data.tenant))
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
    type: appConstants.RECEIVE_ORGANIZATIONS,
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
    return { type: appConstants.RECEIVE_ORGANIZATION_ERROR, error }
  }

  return dispatch => fetch(`${getApiHost()}/organizations`)
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

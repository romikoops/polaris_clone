import fetch from 'isomorphic-fetch'
import { Promise } from 'es6-promise-promise'
import * as Sentry from '@sentry/browser'
import { tenantConstants } from '../constants'
import { tenantService } from '../services/tenant.service'
import { alertActions } from './'
import getApiHost from '../constants/api.constants'

function requestTenant (subdomain) {
  return {
    type: tenantConstants.REQUEST_TENANT,
    subdomain
  }
}
function logOut () {
  return {
    type: tenantConstants.CLEAR_TENANT,
    subdomain: ''
  }
}

function receiveTenant (subdomain, json) {
  Sentry.configureScope((scope) => {
    scope.setTag('tenant', subdomain)
  })

  return {
    type: tenantConstants.RECEIVE_TENANT,
    subdomain,
    data: json,
    receivedAt: Date.now()
  }
}

function invalidateSubdomain (subdomain) {
  return {
    type: tenantConstants.INVALIDATE_SUBDOMAIN,
    subdomain
  }
}

function fetchTenant (subdomain) {
  function failure (error) {
    return {
      type: tenantConstants.RECEIVE_TENANT_ERROR,
      error
    }
  }

  return (dispatch) => {
    dispatch(requestTenant(subdomain))

    return fetch(`${getApiHost()}/tenants/${subdomain}`)
      .then(response => response.json())
      .then(
        json => dispatch(receiveTenant(subdomain, json)),
        err => dispatch(failure(err))
      )
  }
}

function shouldFetchTenant (state, subdomain) {
  const tenant = state[subdomain]
  if (!tenant) {
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

function updateEmails (newEmails, tenant) {
  function request (tenantData) {
    return {
      type: tenantConstants.UPDATE_EMAILS_REQUEST,
      tenantData
    }
  }
  function success (emails) {
    return {
      type: tenantConstants.UPDATE_EMAILS_SUCCESS,
      payload: emails
    }
  }
  function failure (error) {
    return { type: tenantConstants.UPDATE_EMAILS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(newEmails, tenant))

    tenantService.updateEmails(newEmails, tenant).then(
      (resp) => {
        const { emails } = resp.data
        dispatch(success(emails))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function updateReduxStore (payload) {
  return dispatch => dispatch({ type: 'GENERAL_UPDATE', payload })
}

const tenantActions = {
  requestTenant,
  logOut,
  receiveTenant,
  invalidateSubdomain,
  fetchTenant,
  fetchTenantIfNeeded,
  shouldFetchTenant,
  updateEmails,
  updateReduxStore
}

export default tenantActions

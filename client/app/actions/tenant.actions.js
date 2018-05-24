import fetch from 'isomorphic-fetch'
import {
  Promise
} from 'es6-promise-promise'
import {
  BASE_URL,
  tenantConstants
} from '../constants'

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
    return fetch(`${BASE_URL}/tenants/${subdomain}`)
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
const tenantActions = {
  requestTenant,
  logOut,
  receiveTenant,
  invalidateSubdomain,
  fetchTenant,
  shouldFetchTenant,
  fetchTenantIfNeeded
}

export default tenantActions

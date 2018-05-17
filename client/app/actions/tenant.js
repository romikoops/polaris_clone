import fetch from 'isomorphic-fetch'
import { Promise } from 'es6-promise-promise'
import { BASE_URL } from '../constants'

export const REQUEST_TENANT = 'REQUEST_TENANT'
export const RECEIVE_TENANT = 'RECEIVE_TENANT'
export const SET_THEME = 'SET_THEME'
export const RECEIVE_TENANT_ERROR = 'RECEIVE_TENANT_ERROR'
export const INVALIDATE_SUBDOMAIN = 'INVALIDATE_SUBDOMAIN'
export const CLEAR_TENANT = 'CLEAR_TENANT'

const requestTenant = subdomain => ({
  type: REQUEST_TENANT,
  subdomain
})
export const logOut = () => ({
  type: CLEAR_TENANT,
  subdomain: ''
})

const receiveTenant = (subdomain, json) => ({
  type: RECEIVE_TENANT,
  subdomain,
  data: json,
  receivedAt: Date.now()
})

export const invalidateSubdomain = subdomain => ({
  type: INVALIDATE_SUBDOMAIN,
  subdomain
})

const fetchTenant = (subdomain) => {
  function failure (error) {
    return { type: RECEIVE_TENANT_ERROR, error }
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

const shouldFetchTenant = (state, subdomain) => {
  const tenant = state[subdomain]
  if (!tenant) {
    return true
  }
  if (tenant.isFetching) {
    return false
  }
  return tenant.didInvalidate
}

export const fetchTenantIfNeeded = subdomain =>
  // Note that the function also receives getState()
  // which lets you choose what to dispatch next.

  // This is useful for avoiding a network request if
  // a cached value is already available.

  (dispatch, getState) => {
    if (shouldFetchTenant(getState(), subdomain)) {
      // Dispatch a thunk from thunk!
      return dispatch(fetchTenant(subdomain))
    }

    // Let the calling code know there's nothing to wait for.
    return Promise.resolve()
  }

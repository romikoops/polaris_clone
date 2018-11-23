export const REQUEST_TENANT = 'REQUEST_TENANT'
export const RECEIVE_TENANT = 'RECEIVE_TENANT'
export const SET_THEME = 'SET_THEME'
export const RECEIVE_TENANT_ERROR = 'RECEIVE_TENANT_ERROR'
export const INVALIDATE_SUBDOMAIN = 'INVALIDATE_SUBDOMAIN'
export const CLEAR_TENANT = 'CLEAR_TENANT'

export const logOut = () => ({
  type: CLEAR_TENANT,
  subdomain: ''
})

export const invalidateSubdomain = subdomain => ({
  type: INVALIDATE_SUBDOMAIN,
  subdomain
})

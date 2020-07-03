export const REQUEST_ORGANIZATION = 'REQUEST_ORGANIZATION'
export const RECEIVE_ORGANIZATION = 'RECEIVE_ORGANIZATION'
export const SET_THEME = 'SET_THEME'
export const RECEIVE_ORGANIZATION_ERROR = 'RECEIVE_ORGANIZATION_ERROR'
export const INVALIDATE_SUBDOMAIN = 'INVALIDATE_SUBDOMAIN'
export const CLEAR_ORGANIZATION = 'CLEAR_ORGANIZATION'

export const logOut = () => ({
  type: CLEAR_ORGANIZATION,
  subdomain: ''
})

export const invalidateSubdomain = subdomain => ({
  type: INVALIDATE_SUBDOMAIN,
  subdomain
})

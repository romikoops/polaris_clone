import * as tenantConstants from '../constants/tenant.constants'

export const tenant = (
  state = {
    isFetching: false,
    didInvalidate: false,
    data: {}
  },
  action
) => {
  switch (action.type) {
    case tenantConstants.INVALIDATE_SUBDOMAIN:
      return {
        ...state,
        didInvalidate: true
      }
    case tenantConstants.REQUEST_TENANT:
      return {
        ...state,
        isFetching: true,
        didInvalidate: false
      }
    case tenantConstants.RECEIVE_TENANT:
      return {
        ...state,
        isFetching: false,
        loading: true,
        didInvalidate: false,
        data: action.data,
        lastUpdated: action.receivedAt
      }
    case tenantConstants.RECEIVE_TENANT_ERROR:
      return {
        ...state,
        isFetching: false
      }
    case tenantConstants.CLEAR_TENANT:
      return {}
    case tenantConstants.SET_THEME: {
      return {
        ...state,
        data: {
          ...state.data,
          theme: action.payload
        }
      }
    }
    case tenantConstants.CLEAR_LOADING: {
      debugger // eslint-disable-line no-debugger

      return {
        ...state,
        isFetching: false
      }
    }
    default:
      return state
  }
}

export const selectedSubdomain = (state = '', action) => {
  switch (action.type) {
    case tenantConstants.SELECT_SUBDOMAIN:
      return action.subdomain
    default:
      return state
  }
}

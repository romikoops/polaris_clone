import * as tenantActions from '../actions/tenant'

export const tenant = (
  state = {
    isFetching: false,
    didInvalidate: false,
    data: {}
  },
  action
) => {
  switch (action.type) {
    case tenantActions.INVALIDATE_SUBDOMAIN:
      return {
        ...state,
        didInvalidate: true
      }
    case tenantActions.REQUEST_TENANT:
      return {
        ...state,
        isFetching: true,
        didInvalidate: false
      }
    case tenantActions.RECEIVE_TENANT:
      return {
        ...state,
        isFetching: false,
        loading: true,
        didInvalidate: false,
        data: action.data,
        lastUpdated: action.receivedAt
      }
    case tenantActions.RECEIVE_TENANT_ERROR:
      return {
        ...state,
        isFetching: false
      }
    case tenantActions.CLEAR_TENANT:
      return {}
    case tenantActions.SET_THEME: {
      return {
        ...state,
        data: {
          ...state.data,
          theme: action.payload
        }
      }
    }
    case tenantConstants.CLEAR_LOADING: {
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
    case tenantActions.SELECT_SUBDOMAIN:
      return action.subdomain
    default:
      return state
  }
}

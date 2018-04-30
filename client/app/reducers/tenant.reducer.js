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
      return Object.assign({}, state, {
        didInvalidate: true
      })
    case tenantActions.REQUEST_TENANT:
      return Object.assign({}, state, {
        isFetching: true,
        didInvalidate: false
      })
    case tenantActions.RECEIVE_TENANT:
      return Object.assign({}, state, {
        isFetching: false,
        didInvalidate: false,
        data: action.data,
        lastUpdated: action.receivedAt
      })
    case tenantActions.RECEIVE_TENANT_ERROR:
      return Object.assign({}, state, {
        isFetching: false
      })
    case tenantActions.SET_THEME: {
      return {
        ...state,
        data: {
          ...state.data,
          theme: action.payload
        }
      }
    }
    default:
      return state
  }
}

export const selectedSubdomain = (state = 'greencarrier', action) => {
  switch (action.type) {
    case tenantActions.SELECT_SUBDOMAIN:
      return action.subdomain
    default:
      return state
  }
}

import { tenantConstants } from '../constants'

export const tenant = (
  state = {
    isFetching: false,
    didInvalidate: false,
    data: {
      savedEmailSuccess: false
    }
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
    case tenantConstants.UPDATE_EMAILS_REQUEST:
      return {
        ...state,
        savedEmailSuccess: false
      }
    case tenantConstants.UPDATE_EMAILS_SUCCESS: {
      return {
        ...state,
        data: {
          ...state.data,
          emails: action.payload
        },
        savedEmailSuccess: true
      }
    }
    case tenantConstants.UPDATE_EMAILS_FAILURE:
      return state
    case tenantConstants.CLEAR_LOADING: {
      return {
        ...state,
        isFetching: false
      }
    }
    case 'GENERAL_UPDATE': {
      return {
        ...state,
        ...action.payload
      }
    }
    default:
      return state
  }
}

export const selectedSubdomain = (state = '', action) => {
  switch (action.type) {
    case tenantConstants.SELECT_SUBDOMAIN:
      return action.slug
    default:
      return state
  }
}

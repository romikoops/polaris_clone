import { authenticationConstants } from '../constants'
import { getSubdomain } from '../helpers/subdomain'

const subdomainKey = getSubdomain()
const cookieKey = `${subdomainKey}_user`

const localStorage = window.localStorage || { getItem (key) { return null } }
const user = JSON.parse(localStorage.getItem(cookieKey))

const initialState = user ? { loggedIn: true, user } : {}

export default function (state = initialState, action) {
  if (typeof state !== 'object') {
    throw new Error('invalid state')
  }

  if (!action || !action.type) {
    return state
  }

  switch (action.type) {
    case authenticationConstants.LOGIN_REQUEST:
      return {
        loggingIn: true,
        user: action.user
      }
    case authenticationConstants.LOGIN_SUCCESS:
      return {
        loggedIn: true,
        user: action.user
      }
    case authenticationConstants.LOGIN_FAILURE:
      return {}

    case authenticationConstants.UPDATE_USER_REQUEST:
      return {
        loggedIn: true,
        registering: true,
        user: action.user
      }
    case authenticationConstants.UPDATE_USER_SUCCESS:
      return {
        loggedIn: true,
        registered: true,
        user: action.user
      }
    case authenticationConstants.UPDATE_USER_FAILURE:
      return {}

    case authenticationConstants.REGISTRATION_REQUEST:
      return {
        loading: true,
        registering: true,
        user: action.user
      }
    case authenticationConstants.REGISTRATION_SUCCESS:
      return {
        loggedIn: true,
        registered: true,
        user: action.user
      }
    case authenticationConstants.REGISTRATION_FAILURE:
      return {}
    case authenticationConstants.LOGOUT:
      return {}
    case authenticationConstants.SET_USER:
      return {
        ...state,
        user: action.user
      }
    default:
      return state
  }
}

import { authenticationConstants } from '../constants'
import { getSubdomain } from '../helpers/subdomain'

const subdomainKey = getSubdomain()
const cookieKey = `${subdomainKey}_user`

const localStorage = window.localStorage || { getItem (key) { return null } }
const userCookie = localStorage.getItem(cookieKey)
const user = (typeof (userCookie) !== 'undefined') && userCookie !== 'undefined' ? JSON.parse(userCookie) : {}

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
        ...state,
        loginAttempt: false,
        loggingIn: true
      }
    case authenticationConstants.LOGIN_SUCCESS:
      return {
        user: action.user,
        loggedIn: true
      }
    case authenticationConstants.LOGIN_FAILURE:
      return {
        ...(action.loginFailure.persistState ? state : {}),
        error: action.loginFailure.error,
        loginAttempt: true,
        loggingIn: false
      }
    case authenticationConstants.UPDATE_USER_REQUEST:
      return {
        ...state,
        loggedIn: true,
        registering: true
      }
    case authenticationConstants.UPDATE_USER_SUCCESS:
      return {
        loggedIn: true,
        registered: true,
        user: action.user
      }
    case authenticationConstants.UPDATE_USER_FAILURE:
      return {
        ...state,
        registering: false,
        registrationAttempt: true
      }
    case authenticationConstants.REGISTRATION_REQUEST:
      return {
        loading: !!action.target,
        registering: !action.user.guest
      }
    case authenticationConstants.REGISTRATION_SUCCESS:
      return {
        loggedIn: true,
        registered: true,
        user: action.user
      }
    case authenticationConstants.REGISTRATION_FAILURE:
      return {
        registrationAttempt: true
      }
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

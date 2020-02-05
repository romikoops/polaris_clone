import i18next from 'i18next'
import { authenticationConstants } from '../constants'
import { cookieKey } from '../helpers'

const localStorage = window.localStorage || { getItem (key) { return null } }

const userCookie = localStorage.getItem(cookieKey())
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
    case authenticationConstants.SHOW_LOGIN:
      return {
        ...state,
        showModal: true,
        ...action.payload
      }
    case authenticationConstants.CLOSE_LOGIN:
      return {
        ...state,
        loginAttempt: false,
        registrationAttempt: false,
        showModal: false
      }
    case authenticationConstants.LOGIN_REQUEST:
      return {
        ...state,
        loginAttempt: false,
        loggingIn: true,
        showModal: true
      }
    case authenticationConstants.LOGIN_SUCCESS:
      return {
        user: action.user,
        loggedIn: true,
        showModal: false,
        logginIn: false,
        registrationAttempt: false,
        loginAttempt: false
      }
    case authenticationConstants.LOGIN_FAILURE:
      return {
        ...(action.loginFailure.persistState ? state : {}),
        error: { message: i18next.t('errors:invalidCredentials') },
        loginAttempt: true,
        loggingIn: false,
        showModal: true
      }
    case authenticationConstants.UPDATE_USER_REQUEST: {
      return {
        ...state,
        registering: action.payload
      }
    }
    case authenticationConstants.UPDATE_USER_SUCCESS:
      return {
        ...state,
        showModal: false,
        registering: false,
        loggedIn: true,
        registered: true,
        user: action.user,
        registrationAttempt: false,
        loginAttempt: false
      }
    case authenticationConstants.UPDATE_USER_FAILURE: {
      const newState = {
        ...state,
        registering: false,
        registrationAttempt: true
      }

      if (action.payload) {
        newState.error = { message: i18next.t('errors:emailTaken') }
      }

      return newState
    }

    case authenticationConstants.TOGGLE_SANDBOX_SUCCESS:
      return {
        ...state,
        user: action.payload
      }
    case authenticationConstants.REGISTRATION_REQUEST:
      return {
        ...state,
        loading: !!action.target,
        registering: !action.user.guest
      }
    case authenticationConstants.REGISTRATION_SUCCESS:
      return {
        ...state,
        registering: false,
        showModal: false,
        loggedIn: true,
        registered: true,
        user: action.user,
        registrationAttempt: false,
        loginAttempt: false
      }
    case authenticationConstants.REGISTRATION_FAILURE:
      return {
        ...state,
        error: { message: i18next.t('errors:emailTaken') },
        loading: false,
        registering: false,
        registrationAttempt: true
      }
    case authenticationConstants.LOGOUT:
      return {}
    case authenticationConstants.SET_USER:
      return {
        ...state,
        user: action.user
      }
    case authenticationConstants.ADMIN_CREATE_SHIPMENT_ATTEMPT: {
      return {
        ...state,
        error: { message: i18next.t('errors:adminCreateShipmentAttempt') },
        loginAttempt: true,
        loggingIn: false,
        showModal: false
      }
    }
    case authenticationConstants.CHANGE_PASSWORD_REQUEST: {
      return {
        ...state,
        passwordEmailSent: false,
        passwordEmailRequested: true
      }
    }
    case authenticationConstants.CHANGE_PASSWORD_SUCCESS: {
      return {
        ...state,
        passwordEmailSent: true,
        passwordEmailRequested: false
      }
    }
    case authenticationConstants.SAML_USER_SUCCESS: {
      return {
        ...state,
        user: action.payload,
        loggedIn: true
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

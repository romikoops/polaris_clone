import { push } from 'react-router-redux'
import * as Sentry from '@sentry/browser'
import { authenticationConstants } from '../constants'
import { authenticationService } from '../services'
import { alertActions, shipmentActions, adminActions, userActions, tenantActions } from './'
import getSubdomain from '../helpers/subdomain'

const { localStorage } = window
const subdomainKey = getSubdomain()
const cookieKey = `${subdomainKey}_user`
function logout (closeWindow) {
  function lo () {
    localStorage.removeItem('state')
    localStorage.removeItem(cookieKey)

    return { type: authenticationConstants.LOGOUT }
  }

  return (dispatch) => {
    if (closeWindow) {
      setTimeout(() => {
        window.close()
      }, 1000)
    }
    dispatch(adminActions.logOut())
    dispatch(userActions.logOut())
    dispatch(shipmentActions.logOut())
    dispatch(tenantActions.logOut())
    authenticationService.logout()
    dispatch(lo())
  }
}

function showLogin (args) {
  return { type: authenticationConstants.SHOW_LOGIN, payload: args }
}

function closeLogin () {
  return { type: authenticationConstants.CLOSE_LOGIN, payload: null }
}

function login (data) {
  function request (user) {
    return { type: authenticationConstants.LOGIN_REQUEST, user }
  }
  function success (user) {
    return { type: authenticationConstants.LOGIN_SUCCESS, user }
  }
  function failure (loginFailure) {
    return { type: authenticationConstants.LOGIN_FAILURE, loginFailure }
  }

  return (dispatch) => {
    dispatch(request({ email: data.email, password: data.password }))
    authenticationService.login(data).then(
      (response) => {
        const shipmentReq = data.req
        dispatch(success(response.data))

        if (shipmentReq) {
          shipmentReq.user_id = response.data.id
          dispatch(shipmentActions.chooseOffer(shipmentReq))
        } else if (
          ['admin', 'super_admin', 'sub_admin'].includes(response.data.role.name) && !data.noRedirect
        ) {
          dispatch(adminActions.getDashboard(true))
        } else if (['shipper', 'agent', 'agency_manager'].includes(response.data.role.name) && !data.noRedirect) {
          dispatch(push('/account'))
        } else {
          dispatch(closeLogin())
        }
      },
      (error) => {
        error.then((errorData) => {
          dispatch(failure({
            error: errorData,
            persistState: !!data.req || !!data.noRedirect
          }))
        })
      }
    )
  }
}

function register (user, target) {
  function request (userRequest) {
    return { type: authenticationConstants.REGISTRATION_REQUEST, user: userRequest, target }
  }
  function success (response) {
    return { type: authenticationConstants.REGISTRATION_SUCCESS, user: response.data }
  }
  function failure (error) {
    return { type: authenticationConstants.REGISTRATION_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(user))

    authenticationService.register(user).then(
      (response) => {
        dispatch(success(response))
        if (user.guest) {
          target && dispatch(push(target))
        } else if (response.data.role.name === 'admin') {
          dispatch(push('/admin'))
        } else if (response.data.role.name === 'shipper') {
          dispatch(push('/account'))
        }
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function setUser (user) {
  window.localStorage.setItem(cookieKey, JSON.stringify(user.data))
  Sentry.configureScope((scope) => {
    scope.setUser({ id: user.data.id, email: user.data.email })
  })

  return { type: authenticationConstants.SET_USER, user: user.data }
}

function updateUser (user, req, shipmentReq) {
  function request (payload) {
    return { type: authenticationConstants.UPDATE_USER_REQUEST, payload }
  }
  function success (response) {
    return { type: authenticationConstants.UPDATE_USER_SUCCESS, user: response.data.user }
  }
  function failure (error) {
    return { type: authenticationConstants.UPDATE_USER_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(!!shipmentReq))

    authenticationService.updateUser(user, req).then(
      (response) => {
        dispatch(success(response))
        if (shipmentReq) {
          dispatch(shipmentActions.chooseOffer(shipmentReq))
        }
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function goTo (path, newTab) {
  if (newTab) {
    return () => window.open(path, '_blank')
  }

  return (dispatch) => {
    dispatch(push(path))
  }
}

export const authenticationActions = {
  login,
  logout,
  register,
  updateUser,
  setUser,
  goTo,
  showLogin,
  closeLogin
}

export default authenticationActions

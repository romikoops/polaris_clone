import { push } from 'react-router-redux'
import { authenticationConstants, getTenantApiUrl } from '../constants'
import { authenticationService } from '../services'
import {
  alertActions, shipmentActions, adminActions, userActions, tenantActions, clientsActions, appActions
} from '.'

import { requestOptions, cookieKey } from '../helpers'

const { localStorage, fetch } = window

function logout (closeWindow) {
  function lo () {
    localStorage.removeItem('state')
    localStorage.removeItem(cookieKey())

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
    dispatch(clientsActions.logOut())
    authenticationService.logout()
    dispatch(lo())
    dispatch(appActions.getScope())
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
  function adminCreateShipmentAttempt () {
    return { type: authenticationConstants.ADMIN_CREATE_SHIPMENT_ATTEMPT }
  }

  return (dispatch) => {
    dispatch(request({ email: data.email, password: data.password }))
    authenticationService.login(data).then(
      (response) => {
        const shipmentReq = data.req
        dispatch(success(response.data))
        dispatch(setUser({ data: response.data }))
        dispatch(shipmentActions.checkLoginOnBookingProcess())

        if (data.redirectUrl) {
          dispatch(appActions.goTo(data.redirectUrl))

          return
        }

        if (shipmentReq) {
          if (['shipper', 'agent'].includes(response.data.role.name)) {
            shipmentReq.user_id = response.data.id
            const { action } = shipmentReq
            delete shipmentReq.action
            if (action === 'getOffers') {
              dispatch(shipmentActions.getOffers(shipmentReq, true))
            } else if (action === 'refreshQuotes') {
              dispatch(shipmentActions.refreshQuotes(shipmentReq.shipmentId))
            } else {
              dispatch(shipmentActions.chooseOffer(shipmentReq))
            }
          } else {
            dispatch(adminCreateShipmentAttempt())
            dispatch(adminActions.getDashboard(true))
          }
        } else if (
          ['admin', 'super_admin', 'sub_admin'].includes(response.data.role.name) && !data.noRedirect
        ) {
          dispatch(adminActions.getDashboard(true))
        } else if (['shipper', 'agent', 'agency_manager'].includes(response.data.role.name) && !data.noRedirect) {
          dispatch(push('/account'))
        } else {
          dispatch(closeLogin())
        }
        dispatch(appActions.getScope())
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

function registerGuestOrAuthenticate (tenant, target = '') {
  return (tenant.scope.closed_shop)
    ? showLogin(target)
    : registerGuest(tenant, target)
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

function registerGuest (tenant, target = '/') {
  const unixTimeStamp = new Date().getTime().toString()
  const randNum = Math.floor(Math.random() * 100).toString()
  const randSuffix = unixTimeStamp + randNum
  const email = `guest${randSuffix}@${tenant.slug}.itsmycargo.shop`

  const guestUser = {
    email,
    password: 'guestpassword',
    password_confirmation: 'guestpassword',
    first_name: 'Guest',
    last_name: '',
    tenant_id: tenant.id,
    guest: true
  }

  return register(guestUser, target)
}

function setUser (user) {
  localStorage.setItem(cookieKey(), JSON.stringify(user.data))

  return { type: authenticationConstants.SET_USER, user: user.data }
}

function updateUser (user, req, shipmentReq) {
  function request (payload) {
    return { type: authenticationConstants.UPDATE_USER_REQUEST, payload }
  }
  function success (response) {
    return { type: authenticationConstants.UPDATE_USER_SUCCESS, user: response.data.user }
  }
  function failure (payload) {
    return { type: authenticationConstants.UPDATE_USER_FAILURE, payload }
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
        dispatch(failure(!!shipmentReq))
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

function changePassword (email, redirect) {
  function request (payload) {
    return { type: authenticationConstants.CHANGE_PASSWORD_REQUEST, payload }
  }
  function success (response) {
    return { type: authenticationConstants.CHANGE_PASSWORD_SUCCESS, response }
  }
  function failure (payload) {
    return { type: authenticationConstants.CHANGE_PASSWORD_FAILURE, payload }
  }

  return (dispatch) => {
    dispatch(request(email))

    authenticationService.changePassword(email, redirect).then(
      (response) => {
        dispatch(success(response))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function toggleSandbox (id) {
  function request () {
    return { type: authenticationConstants.TOGGLE_SANDBOX_REQUEST }
  }

  function success (response) {
    const payload = response.data

    return { type: authenticationConstants.TOGGLE_SANDBOX_SUCCESS, payload }
  }

  function failure (error) {
    return { type: authenticationConstants.TOGGLE_SANDBOX_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    authenticationService.toggleSandbox(id).then(
      (response) => {
        dispatch(success(response))
      },
      error => dispatch(failure(error))
    )
  }
}

function updateReduxStore (payload) {
  return dispatch => dispatch({ type: 'GENERAL_UPDATE', payload })
}

function postSamlActions (payload) {
  function request (userData) {
    return { type: authenticationConstants.SAML_USER_REQUEST, payload: userData }
  }
  function success (userData) {
    setUser(userData)

    return { type: authenticationConstants.SAML_USER_SUCCESS, payload: userData }
  }
  function failure (error) {
    return { type: authenticationConstants.SAML_USER_FAILURE, error }
  }
  const { userId, headers, tenantId } = payload
  localStorage.setItem('authHeader', JSON.stringify(headers))
  localStorage.setItem('tenantId', tenantId)

  return (dispatch) => {
    dispatch(request())

    return fetch(`${getTenantApiUrl()}/users/${userId}/show`, requestOptions('GET'))
      .then(resp => resp.json())
      .then((response) => {
        dispatch(success(response))
        dispatch(userActions.getDashboard(userId, true))
      })
      .catch((error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      })
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
  closeLogin,
  changePassword,
  updateReduxStore,
  toggleSandbox,
  registerGuest,
  registerGuestOrAuthenticate,
  postSamlActions
}

export default authenticationActions

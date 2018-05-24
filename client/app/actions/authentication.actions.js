import { push } from 'react-router-redux'
import { authenticationConstants } from '../constants'
import { authenticationService } from '../services'
import { alertActions, shipmentActions, adminActions, userActions, tenantActions } from './'
import { getSubdomain } from '../helpers/subdomain'

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
          shipmentReq.shipment.user_id = response.data.id
          dispatch(shipmentActions.chooseOffer(shipmentReq))
        } else if (
          (response.data.role_id === 1 && !data.noRedirect) ||
          (response.data.role_id === 3 && !data.noRedirect) ||
          (response.data.role_id === 4 && !data.noRedirect)
        ) {
          dispatch(push('/admin/dashboard'))
        } else if (response.data.role_id === 2 && !data.noRedirect) {
          dispatch(push('/account'))
        }
      },
      (error) => {
        error.then((errorData) => {
          dispatch(failure({
            error: errorData,
            persistState: !!data.req
          }))
        })
      }
    )
  }
}

function register (user, redirect) {
  function request (userRequest) {
    return { type: authenticationConstants.REGISTRATION_REQUEST, user: userRequest }
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
        dispatch(alertActions.success('Registration successful'))
        if (redirect) {
          dispatch(push('/booking'))
        } else if (response.data.role_id === 1) {
          dispatch(push('/admin'))
        } else if (response.data.role_id === 2) {
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
  return { type: authenticationConstants.SET_USER, user: user.data }
}

function updateUser (user, req, shipmentReq) {
  function request (userRequest) {
    return { type: authenticationConstants.UPDATE_USER_REQUEST, user: userRequest }
  }
  function success (response) {
    return { type: authenticationConstants.UPDATE_USER_SUCCESS, user: response.data.user }
  }
  function failure (error) {
    return { type: authenticationConstants.UPDATE_USER_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(user))

    authenticationService.updateUser(user, req).then(
      (response) => {
        dispatch(success(response))
        if (shipmentReq) {
          dispatch(shipmentActions.chooseOffer(shipmentReq))
          dispatch(alertActions.success('Registration successful'))
        } else {
          dispatch(alertActions.success('Update successful'))
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
  goTo
}

export default authenticationActions

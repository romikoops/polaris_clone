import { push } from 'react-router-redux'
import { userConstants } from '../constants'
import { userService } from '../services'
import { history } from '../helpers'
import { alertActions, authenticationActions } from './'

function getAll (redirect) {
  function request () {
    return { type: userConstants.GETALL_REQUEST }
  }
  function success (response) {
    const payload = response.data
    return { type: userConstants.GETALL_SUCCESS, payload }
  }
  function failure (error) {
    return { type: userConstants.GETALL_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.getAll().then(
      (response) => {
        if (redirect) {
          dispatch(push('/account/users'))
        }
        dispatch(success(response))
      },
      error => dispatch(failure(error))
    )
  }
}

// prefixed function name with underscore because delete is a reserved word in javascript
// eslint-disable-next-line no-underscore-dangle
function _delete (id) {
  function request (reqId) {
    return { type: userConstants.DELETE_REQUEST, reqId }
  }
  function success (respId) {
    return { type: userConstants.DELETE_SUCCESS, respId }
  }
  function failure (failId, error) {
    return { type: userConstants.DELETE_FAILURE, failId, error }
  }

  return (dispatch) => {
    dispatch(request(id))
    userService.delete(id).then(
      (userData) => {
        dispatch(success(userData.id))
      },
      (error) => {
        dispatch(failure(id, error))
      }
    )
  }
}

function getLocations (user, redirect) {
  function request () {
    return { type: userConstants.GETLOCATIONS_REQUEST }
  }
  function success (response) {
    const payload = response.data
    return { type: userConstants.GETLOCATIONS_SUCCESS, payload }
  }
  function failure (error) {
    return { type: userConstants.GETLOCATIONS_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.getLocations(user).then(
      (response) => {
        if (redirect) {
          dispatch(push('/account/locations'))
        }
        dispatch(success(response))
      },
      error => dispatch(failure(error))
    )
  }
}

function optOut (userId, target) {
  function request () {
    return { type: userConstants.OPT_OUT_REQUEST }
  }
  function success (response) {
    const payload = response.data
    return { type: userConstants.OPT_OUT_SUCCESS, payload }
  }
  function failure (error) {
    return { type: userConstants.OPT_OUT_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.optOut(userId, target).then(
      (response) => {
        dispatch(success(response))
        debugger // eslint-disable-line
        dispatch(authenticationActions.setUser(response.data))
      },
      error => dispatch(failure(error))
    )
  }
}

function destroyLocation (userId, locationId, redirect) {
  function request () {
    return { type: userConstants.DESTROYLOCATION_REQUEST }
  }
  function success (response) {
    const payload = response.data
    return { type: userConstants.DESTROYLOCATION_SUCCESS, payload }
  }
  function failure (error) {
    return { type: userConstants.DESTROYLOCATION_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.destroyLocation(userId, locationId).then(
      (response) => {
        if (redirect) {
          dispatch(push('/account/locations'))
        }
        dispatch(success(response))
      },
      error => dispatch(failure(error))
    )
  }
}

function makePrimary (userId, locationId, redirect) {
  function request () {
    return { type: userConstants.MAKEPRIMARY_REQUEST }
  }
  function success (response) {
    const payload = response.data
    return { type: userConstants.MAKEPRIMARY_SUCCESS, payload }
  }
  function failure (error) {
    return { type: userConstants.MAKEPRIMARY_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.makePrimary(userId, locationId).then(
      (response) => {
        if (redirect) {
          dispatch(push('/account/dashboard'))
        }
        dispatch(success(response))
      },
      error => dispatch(failure(error))
    )
  }
}

function getShipments (redirect) {
  function request (shipmentData) {
    return { type: userConstants.GET_SHIPMENTS_REQUEST, payload: shipmentData }
  }
  function success (shipmentData) {
    return { type: userConstants.GET_SHIPMENTS_SUCCESS, payload: shipmentData }
  }
  function failure (error) {
    return { type: userConstants.GET_SHIPMENTS_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.getShipments().then(
      (data) => {
        dispatch(alertActions.success('Fetching Shipments successful'))
        if (redirect) {
          dispatch(push('/account/shipments'))
        }

        dispatch(success(data))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getHubs (id) {
  function request (hubData) {
    return { type: userConstants.GET_HUBS_REQUEST, payload: hubData }
  }
  function success (hubData) {
    return { type: userConstants.GET_HUBS_SUCCESS, payload: hubData }
  }
  function failure (error) {
    return { type: userConstants.GET_HUBS_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.getHubs(id).then(
      (data) => {
        dispatch(alertActions.success('Fetching Hubs successful'))

        dispatch(success(data))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getShipment (id, redirect) {
  function request (shipmentData) {
    return { type: userConstants.USER_GET_SHIPMENT_REQUEST, payload: shipmentData }
  }
  function success (shipmentData) {
    return { type: userConstants.USER_GET_SHIPMENT_SUCCESS, payload: shipmentData }
  }
  function failure (error) {
    return { type: userConstants.USER_GET_SHIPMENT_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.getShipment(id).then(
      (data) => {
        dispatch(alertActions.success('Fetching Shipment successful'))
        if (redirect) {
          dispatch(push(`/account/shipments/view/${id}`))
        }
        dispatch(success(data))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getDashboard (id, redirect) {
  function request (dashData) {
    return { type: userConstants.GET_DASHBOARD_REQUEST, payload: dashData }
  }
  function success (dashData) {
    return { type: userConstants.GET_DASHBOARD_SUCCESS, payload: dashData }
  }
  function failure (error) {
    return { type: userConstants.GET_DASHBOARD_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.getDashboard(id).then(
      (data) => {
        dispatch(alertActions.success('Fetching Dashboard successful'))
        if (redirect) {
          dispatch(push('/account'))
        }
        dispatch(success(data))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function deleteDocument (id) {
  function request (deleteId) {
    return { type: userConstants.DELETE_DOCUMENT_REQUEST, payload: deleteId }
  }
  function success (deleteId) {
    return { type: userConstants.DELETE_DOCUMENT_SUCCESS, payload: deleteId }
  }
  function failure (error) {
    return { type: userConstants.DELETE_DOCUMENT_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.deleteDocument(id).then(
      (data) => {
        dispatch(alertActions.success('Deleting Document successful'))
        dispatch(success(id))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function uploadDocument (doc, type, url) {
  function request (file) {
    return { type: userConstants.UPLOAD_DOCUMENT_REQUEST, payload: file }
  }
  function success (file) {
    return { type: userConstants.UPLOAD_DOCUMENT_SUCCESS, payload: file.data }
  }
  function failure (error) {
    return { type: userConstants.UPLOAD_DOCUMENT_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.uploadDocument(doc, type, url).then(
      (data) => {
        dispatch(alertActions.success('Uploading Document successful'))
        dispatch(success(data))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getContact (id, redirect) {
  function request (contentData) {
    return { type: userConstants.GET_CONTACT_REQUEST, payload: contentData }
  }
  function success (contentData) {
    return { type: userConstants.GET_CONTACT_SUCCESS, payload: contentData }
  }
  function failure (error) {
    return { type: userConstants.GET_CONTACT_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.getContact(id).then(
      (data) => {
        dispatch(alertActions.success('Fetching Contact successful'))
        if (redirect) {
          dispatch(push(`/account/contacts/${id}`))
        }

        dispatch(success(data))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function updateContact (data, redirect) {
  function request (contactData) {
    return { type: userConstants.UPDATE_CONTACT_REQUEST, payload: contactData }
  }
  function success (contactData) {
    return { type: userConstants.UPDATE_CONTACT_SUCCESS, payload: contactData }
  }
  function failure (error) {
    return { type: userConstants.UPDATE_CONTACT_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.updateContact(data).then(
      (newData) => {
        dispatch(alertActions.success('Fetching Contact successful'))
        if (redirect) {
          dispatch(push(`/account/contacts/${newData.id}`))
        }
        dispatch(success(newData.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function newUserLocation (userId, data) {
  function request (userlocData) {
    return { type: userConstants.NEW_USER_LOCATION_REQUEST, payload: userlocData }
  }
  function success (userlocData) {
    return { type: userConstants.NEW_USER_LOCATION_SUCCESS, payload: userlocData }
  }
  function failure (error) {
    return { type: userConstants.NEW_USER_LOCATION_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.newUserLocation(userId, data).then(
      (newData) => {
        dispatch(alertActions.success('Saving User Location successful'))
        dispatch(success(newData.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function editUserLocation (userId, data) {
  function request (userlocData) {
    return { type: userConstants.EDIT_USER_LOCATION_REQUEST, payload: userlocData }
  }
  function success (userlocData) {
    return { type: userConstants.EDIT_USER_LOCATION_SUCCESS, payload: userlocData }
  }
  function failure (error) {
    return { type: userConstants.EDIT_USER_LOCATION_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.editUserLocation(userId, data).then(
      (newData) => {
        dispatch(alertActions.success('Saving User Location successful'))
        dispatch(success(newData.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function newContact (data) {
  function request (newContactData) {
    return { type: userConstants.NEW_CONTACT_REQUEST, payload: newContactData }
  }
  function success (newContactData) {
    return { type: userConstants.NEW_CONTACT_SUCCESS, payload: newContactData }
  }
  function failure (error) {
    return { type: userConstants.NEW_CONTACT_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.newContact(data).then(
      (newData) => {
        dispatch(alertActions.success('Saving New Contact successful'))
        dispatch(success(newData))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function newAlias (data) {
  function request (newAliasData) {
    return { type: userConstants.NEW_ALIAS_REQUEST, payload: newAliasData }
  }
  function success (newAliasData) {
    return { type: userConstants.NEW_ALIAS_SUCCESS, payload: newAliasData }
  }
  function failure (error) {
    return { type: userConstants.NEW_ALIAS_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.newAlias(data).then(
      (newData) => {
        dispatch(alertActions.success('Saving New Alias successful'))
        dispatch(success(newData))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function deleteAlias (aliasId) {
  function request (newAliasData) {
    return { type: userConstants.DELETE_ALIAS_REQUEST, payload: newAliasData }
  }
  function success (newAliasData) {
    return { type: userConstants.DELETE_ALIAS_SUCCESS, payload: newAliasData }
  }
  function failure (error) {
    return { type: userConstants.DELETE_ALIAS_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.deleteAlias(aliasId).then(
      (data) => {
        dispatch(alertActions.success('Deleting Alias successful'))
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function deleteContactAddress (addressId) {
  function request (delAddress) {
    return { type: userConstants.DELETE_CONTACT_ADDRESS_REQUEST, payload: delAddress }
  }
  function success (delAddress) {
    return { type: userConstants.DELETE_CONTACT_ADDRESS_SUCCESS, payload: delAddress }
  }
  function failure (error) {
    return { type: userConstants.DELETE_CONTACT_ADDRESS_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.deleteContactAddress(addressId).then(
      (data) => {
        dispatch(alertActions.success('Deleting Contact Address successful'))
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function saveAddressEdit (address) {
  function request (addressData) {
    return { type: userConstants.UPDATE_CONTACT_ADDRESS_REQUEST, payload: addressData }
  }
  function success (addressData) {
    return { type: userConstants.UPDATE_CONTACT_ADDRESS_SUCCESS, payload: addressData }
  }
  function failure (error) {
    return { type: userConstants.UPDATE_CONTACT_ADDRESS_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    userService.saveAddressEdit(address).then(
      (data) => {
        dispatch(alertActions.success('Editing Address successful'))
        dispatch(success(data.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function clearLoading () {
  return { type: userConstants.CLEAR_LOADING, payload: null }
}

function goTo (path) {
  return (dispatch) => {
    dispatch(push(path))
  }
}
function goBack () {
  return () => {
    history.goBack()
  }
}
function logOut () {
  return { type: userConstants.USER_LOG_OUT, payload: null }
}

export const userActions = {
  getLocations,
  destroyLocation,
  makePrimary,
  getDashboard,
  deleteDocument,
  uploadDocument,
  getHubs,
  getShipments,
  getShipment,
  goTo,
  getAll,
  getContact,
  goBack,
  updateContact,
  newUserLocation,
  newContact,
  newAlias,
  deleteAlias,
  saveAddressEdit,
  clearLoading,
  deleteContactAddress,
  delete: _delete,
  logOut,
  editUserLocation,
  optOut
}

export default userActions

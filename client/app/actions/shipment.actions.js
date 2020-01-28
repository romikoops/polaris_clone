import { Promise } from 'es6-promise-promise'
import { push } from 'react-router-redux'
import { find, get } from 'lodash'
import { getTenantApiUrl } from '../constants/api.constants'
import { Base64decode } from '../helpers/Base64'
import { shipmentConstants } from '../constants'
import { shipmentService } from '../services'
import { requestOptions, deepSnakefyKeys, queryStringToObj } from '../helpers'
import {
  alertActions, userActions, appActions, errorActions, bookingProcessActions
} from '.'

const { fetch } = window

// New Format action only
function getOffers (data, redirect) {
  function request (shipmentData) {
    return {
      type: shipmentConstants.GET_OFFERS_REQUEST,
      shipmentData
    }
  }
  function success (shipmentData) {
    return {
      type: shipmentConstants.GET_OFFERS_SUCCESS,
      shipmentData
    }
  }
  function failure (error) {
    return { type: shipmentConstants.GET_OFFERS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(data))

    return fetch(
      `${getTenantApiUrl()}/shipments/${get(data, 'shipment.id')}/get_offers`,
      requestOptions('POST', { 'Content-Type': 'application/json' }, JSON.stringify(deepSnakefyKeys(data)))
    )
      .then(resp => resp.json())
      .then((resp) => {
        const responseData = JSON.parse(resp.data)
        if (resp.success) {
          dispatch(success(responseData))
          if (redirect) {
            dispatch(push(`/booking/${get(responseData, 'shipment.id')}/choose_offer`))
          }
        } else {
          dispatch(failure({
            type: 'error',
            text: get(responseData, 'message') || get(responseData, 'error')
          }))
          const errorToRender = {
            data: responseData,
            componentName: 'RouteSection',
            side: 'center'
          }
          dispatch(errorActions.setError(errorToRender))
          if (resp.error) console.error(resp.exception)
        }
      })
  }
}

function setShipmentContacts (data) {
  function request (shipmentData) {
    return {
      type: shipmentConstants.SET_SHIPMENT_CONTACTS_REQUEST,
      shipmentData
    }
  }
  function success (shipmentData) {
    return {
      type: shipmentConstants.SET_SHIPMENT_CONTACTS_SUCCESS,
      shipmentData
    }
  }
  function failure (error) {
    return { type: shipmentConstants.SET_SHIPMENT_CONTACTS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(data))

    return fetch(
      `${getTenantApiUrl()}/shipments/${data.shipment.id}/update_shipment`,
      requestOptions('POST', { 'Content-Type': 'application/json' }, JSON.stringify(data))
    )
      .then(resp => resp.json())
      .then((resp) => {
        if (!resp.success) {
          dispatch(failure(resp.message))

          return
        }

        const shipmentData = resp.data
        dispatch(success(shipmentData))
        dispatch(push(`/booking/${shipmentData.shipment.id}/finish_booking`))
      })
  }
}

// Old format
function newShipment (type, redirect, reused) {
  function request (shipmentData, isReused) {
    return { type: shipmentConstants.NEW_SHIPMENT_REQUEST, shipmentData, isReused }
  }
  function success (shipmentData) {
    return { type: shipmentConstants.NEW_SHIPMENT_SUCCESS, shipmentData }
  }
  function failure (error) {
    return { type: shipmentConstants.NEW_SHIPMENT_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(type, reused))
    shipmentService.newShipment(type).then(
      (resp) => {
        const shipmentData = resp.data
        dispatch(success(shipmentData))
        if (redirect) {
          dispatch(push(`/booking/${shipmentData.shipment.id}/shipment_details`))
        }
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function newAhoyShipment (params) {
  const { loadType, direction } = params
  let { originId, destinationId } = params

  function request (shipmentData, isReused = false) {
    return { type: shipmentConstants.SHIPMENT_NEW_AHOY_REQUEST, shipmentData, isReused }
  }

  function success (shipmentData) {
    return { type: shipmentConstants.SHIPMENT_NEW_AHOY_SUCCESS, shipmentData }
  }

  function failure (error) {
    return { type: shipmentConstants.SHIPMENT_NEW_AHOY_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(params))

    shipmentService.newShipment(params).then(
      (resp) => {
        const shipmentData = resp.data

        originId = parseInt(originId, 10)
        destinationId = parseInt(destinationId, 10)

        const itineraryData = find(shipmentData.routes, route => route.origin.hubId === originId && route.destination.hubId === destinationId)

        if (itineraryData) {
          shipmentData.shipment.origin = itineraryData.origin
          shipmentData.shipment.destination = itineraryData.destination
        }

        dispatch(success(shipmentData))
        dispatch(bookingProcessActions.updateShipment('loadType', loadType))
        dispatch(bookingProcessActions.updateShipment('direction', direction))
        dispatch(bookingProcessActions.updateShipment('origin', shipmentData.shipment.origin))
        dispatch(bookingProcessActions.updateShipment('destination', shipmentData.shipment.destination))
        dispatch(bookingProcessActions.updateShipment('ahoyRequest', true))

        dispatch(push(`/booking/${shipmentData.shipment.id}/shipment_details`))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function checkAhoyShipment (routerLocation) {
  if (!routerLocation || routerLocation.pathname !== '/ahoy') {
    return { type: shipmentConstants.SHIPMENT_CHECK_AHOY, payload: {} }
  }

  const params = Base64decode(routerLocation.search.substring(1))
  const queryString = queryStringToObj(params)

  const {
    direction,
    originId,
    destinationId
  } = queryString

  const loadType = queryString.loadType === 'fcl' ? 'container' : 'cargo_item'

  if (!loadType || !direction || !originId || !destinationId) {
    return { type: shipmentConstants.SHIPMENT_CHECK_AHOY, payload: {} }
  }

  return (dispatch) => {
    dispatch({
      type: shipmentConstants.SHIPMENT_NEW_AHOY,
      payload: {
        loadType, direction, originId, destinationId
      }
    })
    dispatch(push('/booking/'))
  }
}

function reuseShipment (shipment) {
  function request (shipmentData) {
    return { type: shipmentConstants.REUSE_SHIPMENT_REQUEST, payload: shipmentData }
  }
  const newShipmentRequest = {
    loadType: shipment.shipment.load_type,
    direction: shipment.shipment.direction
  }

  return (dispatch) => {
    dispatch(request(shipment))
    dispatch(newShipment(newShipmentRequest, true, true))
  }
}

function getOffersForNewDate (data, redirect) {
  function request (shipmentData) {
    return {
      type: shipmentConstants.GET_NEW_DATE_OFFERS_REQUEST,
      shipmentData
    }
  }
  function success (shipmentData) {
    return {
      type: shipmentConstants.GET_NEW_DATE_OFFERS_SUCCESS,
      shipmentData
    }
  }
  function failure (error) {
    return { type: shipmentConstants.GET_NEW_DATE_OFFERS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(data))
    shipmentService.getOffers(data).then(
      (resp) => {
        const shipmentData = resp.data
        dispatch(success(shipmentData))
        if (redirect) {
          dispatch(push(`/booking/${shipmentData.shipment.id}/choose_offer`))
        }
      },
      (error) => {
        error.then((newData) => {
          dispatch(failure({
            type: 'error',
            text: newData.message || newData.error
          }))
          if (newData.error) console.error(newData.exception)
        })
      }
    )
  }
}

function chooseOffer (data) {
  function request (shipmentData) {
    return {
      type: shipmentConstants.CHOOSE_OFFER_REQUEST,
      shipmentData
    }
  }
  function success (shipmentData) {
    return {
      type: shipmentConstants.CHOOSE_OFFER_SUCCESS,
      shipmentData
    }
  }
  function failure (error) {
    return { type: shipmentConstants.CHOOSE_OFFER_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(data))

    shipmentService.chooseOffer(data).then(
      (resp) => {
        const shipmentData = resp.data
        dispatch(success(shipmentData))
        dispatch(push(`/booking/${shipmentData.shipment.id}/final_details`))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function sendQuotes (data) {
  function request (shipmentData) {
    return {
      type: shipmentConstants.SEND_QUOTES_REQUEST,
      shipmentData
    }
  }
  function success (shipmentData) {
    return {
      type: shipmentConstants.SEND_QUOTES_SUCCESS,
      shipmentData
    }
  }
  function failure (error) {
    return { type: shipmentConstants.SEND_QUOTES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(data))

    shipmentService.sendQuotes(data).then(
      (resp) => {
        const shipmentData = resp.data
        dispatch(success(shipmentData))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function requestShipment (id) {
  function request (shipmentData) {
    return {
      type: shipmentConstants.REQUEST_SHIPMENT_REQUEST,
      shipmentData
    }
  }
  function success (shipmentData) {
    return {
      type: shipmentConstants.REQUEST_SHIPMENT_SUCCESS,
      shipmentData
    }
  }
  function failure (error) {
    return { type: shipmentConstants.REQUEST_SHIPMENT_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(id))

    shipmentService.requestShipment(id).then(
      (resp) => {
        const shipmentData = resp.data
        dispatch(success(shipmentData))
        dispatch(push(`/booking/${id}/thank_you`))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getAll () {
  function request () {
    return { type: shipmentConstants.GETALL_REQUEST }
  }
  function success (shipments) {
    return { type: shipmentConstants.GETALL_SUCCESS, shipments }
  }
  function failure (error) {
    return { type: shipmentConstants.GETALL_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    shipmentService
      .getAll()
      .then(shipments => dispatch(success(shipments)), error => dispatch(failure(error)))
  }
}

function getShipments () {
  function request () {
    return { type: shipmentConstants.GETALL_REQUEST }
  }
  function success (shipments) {
    return { type: shipmentConstants.GETALL_SUCCESS, shipments }
  }
  function failure (error) {
    return { type: shipmentConstants.GETALL_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    shipmentService
      .getAll()
      .then(shipments => dispatch(success(shipments)), error => dispatch(failure(error)))
  }
}

function getShipment (id) {
  function request (reqId) {
    return { type: shipmentConstants.GET_SHIPMENT_REQUEST, reqId }
  }
  function success (shipment) {
    return { type: shipmentConstants.GET_SHIPMENT_SUCCESS, shipment }
  }
  function failure (error) {
    return { type: shipmentConstants.GET_SHIPMENT_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    shipmentService
      .getShipment(id)
      .then(shipment => dispatch(success(shipment)), error => dispatch(failure(error)))
  }
}

// prefixed function name with underscore because delete is a reserved word in javascript
// eslint-disable-next-line no-underscore-dangle
function _delete (id) {
  function request (reqId) {
    return { type: shipmentConstants.DELETE_REQUEST, reqId }
  }
  function success (respId) {
    return { type: shipmentConstants.DELETE_SUCCESS, respId }
  }
  function failure (newId, error) {
    return { type: shipmentConstants.DELETE_FAILURE, id: newId, error }
  }

  return (dispatch) => {
    dispatch(request(id))
    shipmentService.delete(id).then(
      (newUserData) => {
        dispatch(success(newUserData.id))
      },
      (error) => {
        dispatch(failure(id, error))
      }
    )
  }
}

function fetchShipment (id) {
  function request (shipId) {
    return { type: shipmentConstants.FETCH_SHIPMENT_REQUEST, shipId }
  }
  function success (shipId, data) {
    return { type: shipmentConstants.FETCH_SHIPMENT_SUCCESS, shipId, data }
  }
  function failure (shipId, error) {
    return {
      type: shipmentConstants.FETCH_SHIPMENT_FAILURE,
      shipId,
      error
    }
  }

  return (dispatch) => {
    dispatch(request(id))

    return window
      .fetch(`http://localhost:3000/shipments/${id}`)
      .then(response => response.json())
      .then(
        json => dispatch(success(id, json)),
        (error) => {
          dispatch(failure(id, error))
        }
      )
  }
}

function shouldFetchShipment (state, id) {
  const shipment = state.shipment.data
  if (!shipment) {
    return true
  }
  if (shipment && shipment.id !== id) {
    return true
  }
  if (shipment.isFetching) {
    return false
  }

  return shipment.didInvalidate
}
function fetchShipmentIfNeeded (id) {
  // Note that the function also receives getState()
  // which lets you choose what to dispatch next.

  // This is useful for avoiding a network request if
  // a cached value is already available.

  return (dispatch, getState) => {
    if (shouldFetchShipment(getState(), id)) {
      // Dispatch a thunk from thunk!
      return dispatch(getShipment(id))
    }

    // Let the calling code know there's nothing to wait for.
    return Promise.resolve()
  }
}

function uploadDocument (doc, type, url) {
  function request (file) {
    return { type: shipmentConstants.SHIPMENT_UPLOAD_DOCUMENT_REQUEST, payload: file }
  }
  function success (file) {
    return { type: shipmentConstants.SHIPMENT_UPLOAD_DOCUMENT_SUCCESS, payload: file.data }
  }
  function failure (error) {
    return { type: shipmentConstants.SHIPMENT_UPLOAD_DOCUMENT_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    shipmentService.uploadDocument(doc, type, url).then(
      (data) => {
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
    return { type: shipmentConstants.SHIPMENT_DELETE_DOCUMENT_REQUEST, payload: deleteId }
  }
  function success (deleteId) {
    return { type: shipmentConstants.SHIPMENT_DELETE_DOCUMENT_SUCCESS, payload: deleteId }
  }
  function failure (error) {
    return { type: shipmentConstants.SHIPMENT_DELETE_DOCUMENT_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    shipmentService.deleteDocument(id).then(
      () => {
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
function getNotes (noteIds) {
  function request (noteData) {
    return { type: shipmentConstants.SHIPMENT_GET_NOTES_REQUEST, payload: noteData }
  }
  function success (noteData) {
    return { type: shipmentConstants.SHIPMENT_GET_NOTES_SUCCESS, payload: noteData }
  }
  function failure (error) {
    return { type: shipmentConstants.SHIPMENT_GET_NOTES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    shipmentService.getNotes(noteIds).then(
      (response) => {
        dispatch(success(response.data))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function getLastAvailableDate (params) {
  function request (payload) {
    return { type: shipmentConstants.SHIPMENT_GET_LAST_AVAILABLE_DATE_REQUEST, payload }
  }
  function success (payload) {
    return { type: shipmentConstants.SHIPMENT_GET_LAST_AVAILABLE_DATE_SUCCESS, payload }
  }
  function failure (error) {
    return { type: shipmentConstants.SHIPMENT_GET_LAST_AVAILABLE_DATE_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    shipmentService.getLastAvailableDate(params).then(
      (response) => {
        dispatch(success(response.data.lastAvailableDate))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function updateCurrency (currency, req) {
  return (dispatch) => {
    dispatch(appActions.setCurrency(currency, req))
    // setTimeout(() => {
    //   dispatch(getOffers(req, false))
    //   dispatch(alertActions.success('Updating Currency successful'))
    // }, 500)
  }
}

function updateContact (req) {
  function request () {
    return { type: shipmentConstants.SHIPMENT_UPDATE_CONTACT_REQUEST }
  }
  function success (contactData) {
    return { type: shipmentConstants.SHIPMENT_UPDATE_CONTACT_SUCCESS, payload: contactData.data }
  }
  function failure (error) {
    return { type: shipmentConstants.SHIPMENT_UPDATE_CONTACT_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    shipmentService.updateContact(req).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function getSchedulesForResult (req) {
  function request () {
    return { type: shipmentConstants.SHIPMENT_GET_SCHEDULES_REQUEST }
  }
  function success (scheduleData) {
    return { type: shipmentConstants.SHIPMENT_GET_SCHEDULES_SUCCESS, payload: scheduleData.data }
  }
  function failure (error) {
    return { type: shipmentConstants.SHIPMENT_GET_SCHEDULES_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    shipmentService.getSchedulesForResult(req).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function toDashboard (id) {
  return (dispatch) => {
    dispatch(userActions.getDashboard(id, true))
  }
}

function clearLoading () {
  return { type: shipmentConstants.CLEAR_LOADING, payload: null }
}
function setError (payload) {
  return { type: shipmentConstants.SET_ERROR, payload }
}

function logOut () {
  return {
    type: shipmentConstants.CLEAR_SHIPMENTS,
    payload: null
  }
}

function goTo (path) {
  return (dispatch) => {
    dispatch(push(path))
  }
}

function checkLoginOnBookingProcess () {
  function request (payload) {
    return { type: shipmentConstants.CHECK_LOGIN_ON_BP_REQUEST, payload }
  }
  function success (response) {
    return { type: shipmentConstants.CHECK_LOGIN_ON_BP_SUCCESS, response }
  }
  function failure (payload) {
    return { type: shipmentConstants.CHECK_LOGIN_ON_BP_FAILURE, payload }
  }

  return (dispatch, getState) => {
    const { bookingData } = getState()
    if (!bookingData || !bookingData.activeShipment) {
      return
    }

    dispatch(request())
    shipmentService.updateShipmentUser(bookingData.activeShipment).then(
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

export const shipmentActions = {
  reuseShipment,
  newShipment,
  chooseOffer,
  sendQuotes,
  getOffers,
  setShipmentContacts,
  fetchShipment,
  getShipments,
  uploadDocument,
  getShipment,
  deleteDocument,
  shouldFetchShipment,
  fetchShipmentIfNeeded,
  getAll,
  goTo,
  getNotes,
  toDashboard,
  clearLoading,
  requestShipment,
  updateCurrency,
  logOut,
  getOffersForNewDate,
  updateContact,
  delete: _delete,
  setError,
  getSchedulesForResult,
  getLastAvailableDate,
  checkAhoyShipment,
  newAhoyShipment,
  checkLoginOnBookingProcess
}

export default shipmentActions

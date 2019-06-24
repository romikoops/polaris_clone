import { bookingProcessService } from '../services'

function resetStore () {
  return { type: 'RESET_BP_STORE' }
}

function updateShipment (key, value) {
  return { type: 'UPDATE_BP_SHIPMENT', payload: { [key]: value } }
}

function updateModals (key) {
  return { type: 'UPDATE_BP_MODALS', payload: key }
}

function addCargoUnit (cargoUnit) {
  return { type: 'ADD_CARGO_UNIT', payload: cargoUnit }
}

function deleteCargoUnit (index) {
  return { type: 'DELETE_CARGO_UNIT', payload: index }
}

function updatePageData (page, payload) {
  return { type: 'UPDATE_PAGE_DATA', page, payload }
}

function updateCargoUnit (index) {
  return { type: 'UPDATE_CARGO_UNIT', payload: index }
}

function getContacts (args) {
  function request (contact) {
    return { type: 'GET_BOOKING_CONTACTS_REQUEST', payload: contact }
  }
  function success (contact) {
    return { type: 'GET_BOOKING_CONTACTS_SUCCESS', payload: contact }
  }
  function failure (error) {
    return { type: 'GET_BOOKING_CONTACTS_CLEAR', error }
  }

  return (dispatch) => {
    dispatch(request())

    bookingProcessService.getContacts(args).then(
      (response) => {
        dispatch(success(response.data))
      },
      (error) => {
        dispatch(failure(error))
      }
    )
  }
}

export const shipmentDetailsActions = {
  resetStore,
  updateShipment,
  addCargoUnit,
  updatePageData,
  updateModals,
  updateCargoUnit,
  deleteCargoUnit,
  getContacts
}

export default shipmentDetailsActions

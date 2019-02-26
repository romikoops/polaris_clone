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

export const shipmentDetailsActions = {
  resetStore,
  updateShipment,
  addCargoUnit,
  updatePageData,
  updateModals,
  updateCargoUnit,
  deleteCargoUnit
}

export default shipmentDetailsActions

function updateShipment (key, value) {
  return { type: 'UPDATE_BP_SHIPMENT', payload: { [key]: value } }
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


export const shipmentDetailsActions = {
  updateShipment,
  addCargoUnit,
  deleteCargoUnit,
  updatePageData,
}

export default shipmentDetailsActions

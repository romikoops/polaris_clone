import { bookingSummaryConstants } from '../constants'

function update (data) {
  const payload = {
    totalVolume: 0,
    totalWeight: 0,
    nexuses: {
      origin: '',
      destination: ''
    },
    hubs: {
      origin: '',
      destination: ''
    },
    trucking: {
      pre_carriage: { trucktype: '' },
      on_carriage: { trucktype: '' }
    },
    modeOfTransport: '',
    loadType: ''
  }
  if (!data) {
    return dispatch => dispatch({ type: bookingSummaryConstants.UPDATE, payload })
  }

  if (data.modeOfTransport) {
    const { modeOfTransport } = data
    return (dispatch) => {
      dispatch({ type: bookingSummaryConstants.UPDATE, payload: { modeOfTransport } })
    }
  }

  if (data.shipment.load_type === 'container') {
    data.containers.forEach((container) => {
      payload.totalWeight += container.quantity * container.payload_in_kg
    })
  } else if (data.aggregated) {
    payload.totalVolume = data.aggregatedCargo.volume
    payload.totalWeight = data.aggregatedCargo.weight
  } else {
    data.cargoItems.forEach((cargoItem) => {
      payload.totalVolume += cargoItem.quantity * ['x', 'y', 'z'].reduce((product, coordinate) => (
        product * cargoItem[`dimension_${coordinate}`]
      ), 1) / 1000000
      payload.totalWeight += cargoItem.quantity * cargoItem.payload_in_kg
    })
  }

  payload.selectedDay = data.selectedDay
  payload.cities = {
    origin: data.origin.city,
    destination: data.destination.city
  }
  payload.hubs = {
    origin: data.origin.hub_name,
    destination: data.destination.hub_name
  }
  payload.trucking = data.shipment.trucking
  payload.loadType = data.shipment.load_type

  return dispatch => dispatch({ type: bookingSummaryConstants.UPDATE, payload })
}

const bookingSummaryActions = {
  update
}

export default bookingSummaryActions

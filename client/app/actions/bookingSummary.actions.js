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
    }
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
    console.log('TBD')
  } else {
    data.cargoItems.forEach((cargoItem) => {
      payload.totalVolume += cargoItem.quantity * ['x', 'y', 'z'].reduce((product, coordinate) => (
        product * cargoItem[`dimension_${coordinate}`]
      ), 1) / 1000000
      payload.totalWeight += cargoItem.quantity * cargoItem.payload_in_kg
    })
    payload.selectedDay = data.selectedDay
    payload.nexuses = {
      origin: data.origin.nexusName,
      destination: data.destination.nexusName
    }
    payload.hubs = {
      origin: data.origin.hub_name,
      destination: data.destination.hub_name
    }
    payload.trucking = data.shipment.trucking
  }
  return dispatch => dispatch({ type: bookingSummaryConstants.UPDATE, payload })
}

const bookingSummaryActions = {
  update
}

export default bookingSummaryActions

import { bookingSummaryConstants } from '../constants'

function update (data) {
  console.log(data)
  if (data.modeOfTransport) {
    const { modeOfTransport } = data
    return (dispatch) => {
      dispatch({ type: bookingSummaryConstants.UPDATE, payload: { modeOfTransport } })
    }
  }

  const payload = {
    totalVolume: 0,
    totalWeight: 0,
    hubs: {
      origin: '',
      destination: ''
    },
    trucking: {
      pre_carriage: { trucktype: '' },
      on_carriage: { trucktype: '' }
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

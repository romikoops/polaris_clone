import { bookingSummaryConstants } from '../constants'

export default function update (data) {
  const payload = {
    totalVolume: 0,
    totalWeight: 0,
    hubs: {
      origin: '',
      destination: ''
    }
  }
  if (data.shipment.load_type === 'container') {
    console.log('TBD')
  } else {
    data.cargoItems.forEach((cargoItem) => {
      payload.totalVolume += cargoItem.quantity * ['x', 'y', 'z'].reduce((product, coordinate) => (
        product * cargoItem[`dimension_${coordinate}`]
      ), 1) / 1000000
      payload.totalWeight += cargoItem.payload_in_kg
    })
    payload.selectedDay = data.selectedDay
    payload.hubs = {
      origin: data.origin.hub_name,
      destination: data.destination.hub_name
    }
  }
  return dispatch => dispatch({ type: bookingSummaryConstants.UPDATE, payload })
}

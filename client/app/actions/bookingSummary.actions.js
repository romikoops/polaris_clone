import { bookingSummaryConstants } from '../constants'
import { get } from 'lodash'

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
  const loadType = get(data, ['shipment', 'load_type'], null)
  if (loadType === 'container' && data.containers) {
    data.containers.forEach((container) => {
      payload.totalWeight += container.quantity * container.payload_in_kg
    })
  } else if (data.aggregated) {
    payload.totalVolume = data.aggregatedCargo.volume
    payload.totalWeight = data.aggregatedCargo.weight
  } else if (loadType === 'cargo_item' && data.cargoItems) {
    data.cargoItems.forEach((cargoItem) => {
      payload.totalVolume += cargoItem.quantity * ['x', 'y', 'z'].reduce((product, coordinate) => (
        product * cargoItem[`dimension_${coordinate}`]
      ), 1) / 1000000
      payload.totalWeight += cargoItem.quantity * cargoItem.payload_in_kg
    })
  }

  if (data.shipment) {
    payload.trucking = data.shipment.trucking
    payload.loadType = data.shipment.load_type
  }

  payload.selectedDay = data.selectedDay
  payload.cities = {}
  if (data.origin)  payload.cities.origin = data.origin.city
  if (data.destination)  payload.cities.destination = data.destination.city
  payload.nexuses = {}
  if (data.origin)  payload.nexuses.origin = data.origin.nexus_name
  if (data.destination)  payload.nexuses.destination = data.destination.nexus_name

  return dispatch => dispatch({ type: bookingSummaryConstants.UPDATE, payload })
}

const bookingSummaryActions = {
  update
}

export default bookingSummaryActions

import configureStore from 'redux-mock-store'
import thunk from 'redux-thunk'
import bookingSummaryActions from './bookingSummary.actions'
import bookingSummaryConstants from '../constants/bookingSummary.constants'

const middlewares = [thunk]
const mockStore = configureStore(middlewares)

describe('booking summary actions', () => {
  const store = mockStore({})

  const data = {
    shipment: {
      load_type: 'cargo_item'
    },
    cargoItems: [{
      width: 10.0,
      length: 10.0,
      height: 10.0,
      quantity: 2,
      payload_in_kg: 100
    }]
  }

  const payload = {
    cities: {},
    hubs: {
      destination: '',
      origin: ''
    },
    loadType: 'cargo_item',
    modeOfTransport: '',
    nexuses: {},
    selectedDay: undefined,
    totalVolume: 0.002,
    totalWeight: 200,
    trucking: undefined
  }

  it('updates a shipment', () => {
    expect.assertions(1)
    const expectedActions = [
      { type: bookingSummaryConstants.UPDATE, payload }
    ]

    store.dispatch(bookingSummaryActions.update(data))
    expect(store.getActions()).toEqual(expectedActions)
  })
})

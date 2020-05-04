import { get } from 'lodash'
import { maxDimensionsToApply } from '../components/ShipmentDetails/mocks'
import reducer from './shipment.reducer'
import { shipmentConstants } from '../constants'

describe('shipment.reducer', () => {
  test('exports a (reducer) function', () => {
    expect(reducer).toBeType('function')
  })

  test('it handles REFRESH_MAX_DIMENSIONS_REQUEST', () => {
    const payload = { test: 1 }
    const initialState = { test: 2 }
    const resultState = reducer(initialState, {
      type: shipmentConstants.REFRESH_MAX_DIMENSIONS_REQUEST,
      payload
    })
    expect(resultState).toEqual(initialState)
  })
  test('it handles REFRESH_MAX_DIMENSIONS_SUCCESS with forGroup = false', () => {
    const payload = {
      maxDimensions: {
        ocean: { ...maxDimensionsToApply, payloadInKg: 1000 }
      },
      maxAggregateDimensions: {
        ocean: { ...maxDimensionsToApply, payloadInKg: 30000 }
      }
    }
    const initialState = {
      response: {
        stage1: {
          shipment: { id: 1 },
          maxDimensions: {},
          maxAggregateDimensions: {}
        }
      }
    }
    const resultState = reducer(initialState, {
      type: shipmentConstants.REFRESH_MAX_DIMENSIONS_SUCCESS,
      payload
    })
    expect(get(resultState, ['response', 'stage1', 'maxDimensions'])).toEqual(payload.maxDimensions)
    expect(get(resultState, ['response', 'stage1', 'maxAggregateDimensions'])).toEqual(payload.maxAggregateDimensions)
  })
})

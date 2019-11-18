import { get } from 'lodash'
import { v4 } from 'uuid'
import reducer from './admin.reducer'
import { adminConstants } from '../constants'

describe('admin.reducer', () => {
  test('exports a (reducer) function', () => {
    expect(reducer).toBeType('function')
  })

  test('it handles DELETE_PRICING_SUCCESS with forGroup = true', () => {
    const dummyPricing = {
      id: 123,
      group_id: v4(),
      tenant_id: 1,
      itinerary_id: 2
    }
    const initialState = { 
      pricings: { 
        show: {
          [dummyPricing.itinerary_id]: {
            pricings: [ dummyPricing ]
          },
          [dummyPricing.group_id]: {
            pricings: [ dummyPricing ]
          }
        }
      }
    }
    const resultState = reducer(initialState, { 
      type: adminConstants.DELETE_PRICING_SUCCESS,
      payload: { 
        fromGroup: true,
        pricing: dummyPricing
      }
    })
    expect(get(resultState, ['pricings', 'show', dummyPricing.group_id, 'pricings'])).toEqual([])
  })
  test('it handles DELETE_PRICING_SUCCESS with forGroup = false', () => {
    const dummyPricing = {
      id: 123,
      group_id: v4(),
      tenant_id: 1,
      itinerary_id: 2
    }
    const initialState = { 
      pricings: { 
        show: {
          [dummyPricing.itinerary_id]: {
            pricings: [ dummyPricing ]
          },
          [dummyPricing.group_id]: {
            pricings: [ dummyPricing ]
          }
        }
      }
    }
    const resultState = reducer(initialState, { 
      type: adminConstants.DELETE_PRICING_SUCCESS,
      payload: { 
        fromGroup: false,
        pricing: dummyPricing
      }
    })
    expect(get(resultState, ['pricings', 'show', dummyPricing.itinerary_id, 'pricings'])).toEqual([])
  })
})

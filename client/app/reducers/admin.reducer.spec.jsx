import { get } from 'lodash';
import { v4 } from 'uuid';
import { adminConstants } from '../constants';
import reducer from './admin.reducer';

describe('admin.reducer', () => {
  test('exports a (reducer) function', () => {
    expect(reducer).toBeType('function')
  })

  test('it handles DELETE_PRICING_SUCCESS with forGroup = true', () => {
    const dummyPricing = {
      id: 123,
      group_id: v4(),
      organization_id: 1,
      itinerary_id: 2
    }
    const initialState = {
      pricings: {
        show: {
          [dummyPricing.itinerary_id]: {
            pricings: [dummyPricing]
          },
          [dummyPricing.group_id]: {
            pricings: [dummyPricing]
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
      organization_id: 1,
      itinerary_id: 2
    }
    const initialState = {
      pricings: {
        show: {
          [dummyPricing.itinerary_id]: {
            pricings: [dummyPricing]
          },
          [dummyPricing.group_id]: {
            pricings: [dummyPricing]
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

  test('it handles ACTIVATE_HUB_SUCCESS', () => {
    const initialState = {
      hubs: { hubsData: [{ id: 1, hub_status: 'active' }] },
      hub: { hub: { id: 1, hub_status: 'active' } },
      loading: true
    }

    const resultState = reducer(initialState, {
      type: adminConstants.ACTIVATE_HUB_SUCCESS,
      payload: { data: { id: 1, hub_status: 'inactive' } }
    })

    expect(resultState.hubs.hubsData[0].hub_status).toEqual('inactive')
    expect(resultState.loading).toBeFalsy()
    expect(resultState.hub.hub.hub_status).toEqual('inactive')
  })
})

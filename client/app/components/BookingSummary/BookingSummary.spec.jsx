import configureMockStore from 'redux-mock-store'
import { Provider } from 'react-redux'
import '../../mocks/libraries/react-redux'
import '../../mocks/libraries/react-router-dom'

import * as React from 'react'
import { render, mount } from 'enzyme'
import { theme, scope } from '../../mocks/index'

import BookingSummary from './BookingSummary'

const mockStore = configureMockStore()

const propsBase = {
  theme,
  modeOfTransport: 'FOO_MODE_OF_TRANSPORT',
  totalWeight: 100,
  totalVolume: 200,
  nexuses: {
    destination: 'FOO_NEXUSES_DESTINATION',
    origin: 'FOO_NEXUSES_ORIGIN'
  },
  cities: {
    origin: 'FOO_ORIGIN_CITY',
    destination: 'FOO_DESTINATION_CITY'
  },
  hubs: {
    origin: 'FOO_ORIGIN_HUB',
    destination: 'FOO_DESTINATION_HUB'
  },
  trucking: {
    onCarriage: { truckType: 'FOO_ON_CARRIAGE' },
    preCarriage: { truckType: 'FOO_PRE_CARRIAGE' }
  },
  scope
}

test('render render', () => {
  expect(render(<BookingSummary {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(render(<BookingSummary {...props} />)).toMatchSnapshot()
})

test('modeOfTransport is falsy', () => {
  const props = {
    ...propsBase,
    modeOfTransport: null
  }
  expect(render(<BookingSummary {...props} />)).toMatchSnapshot()
})

test('trucking.onCarriage is empty object', () => {
  const props = {
    ...propsBase,
    trucking: {
      preCarriage: { truckType: 'FOO_PRE_CARRIAGE' },
      onCarriage: { }
    }
  }
  expect(render(<BookingSummary {...props} />)).toMatchSnapshot()
})

test('trucking.preCarriage is empty object', () => {
  const props = {
    ...propsBase,
    trucking: {
      onCarriage: { truckType: 'FOO_ON_CARRIAGE' },
      preCarriage: { }
    }
  }
  expect(render(<BookingSummary {...props} />)).toMatchSnapshot()
})

test('loadType is cargo_item', () => {
  const props = {
    ...propsBase,
    loadType: 'cargo_item'
  }
  expect(render(<BookingSummary {...props} />)).toMatchSnapshot()
})

describe('BookingSummary', () => {
  let wrapper,
    store

  beforeEach(() => {
    const initialState = {
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
    store = mockStore(initialState)
    wrapper = mount(
      <Provider store={store}>
        <BookingSummary {...propsBase} />
      </Provider>
    )
  })

  it('render with shipment state', () => {
    expect(wrapper).toMatchSnapshot()
  })
})

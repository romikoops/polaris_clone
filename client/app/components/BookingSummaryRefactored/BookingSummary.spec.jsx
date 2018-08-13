import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../mocks'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
jest.mock('react-router-dom', () => ({
  withRouter: x => x
}))
jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
// eslint-disable-next-line
import BookingSummary from './BookingSummary'

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
    on_carriage: { truck_type: 'FOO_ON_CARRIAGE' },
    pre_carriage: { truck_type: 'FOO_PRE_CARRIAGE' }
  }
}

test('shallow render', () => {
  expect(shallow(<BookingSummary {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<BookingSummary {...props} />)).toMatchSnapshot()
})

test('modeOfTransport is falsy', () => {
  const props = {
    ...propsBase,
    modeOfTransport: null
  }
  expect(shallow(<BookingSummary {...props} />)).toMatchSnapshot()
})

test('trucking.on_carriage is empty object', () => {
  const props = {
    ...propsBase,
    trucking: {
      pre_carriage: { truck_type: 'FOO_PRE_CARRIAGE' },
      on_carriage: { }
    }
  }
  expect(shallow(<BookingSummary {...props} />)).toMatchSnapshot()
})

test('trucking.pre_carriage is empty object', () => {
  const props = {
    ...propsBase,
    trucking: {
      on_carriage: { truck_type: 'FOO_ON_CARRIAGE' },
      pre_carriage: { }
    }
  }
  expect(shallow(<BookingSummary {...props} />)).toMatchSnapshot()
})

test('loadType is cargo_item', () => {
  const props = {
    ...propsBase,
    loadType: 'cargo_item'
  }
  expect(shallow(<BookingSummary {...props} />)).toMatchSnapshot()
})

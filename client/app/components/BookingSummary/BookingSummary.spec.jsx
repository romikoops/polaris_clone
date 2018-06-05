import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../mocks'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
jest.mock('react-router-dom', () => ({
  withRouter: x => x
}))
jest.mock('uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
// eslint-disable-next-line
import BookingSummary from './BookingSummary'

const propsBase = {
  theme,
  modeOfTransport: 'FOO_MODE_OF_TRANSPORT',
  totalWeight: 100,
  totalVolume: 200,
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

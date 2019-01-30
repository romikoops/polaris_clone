import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, user, internalUser
} from '../../mocks'

import AdminSchedules from './AdminSchedules'

jest.mock('../../helpers', () => ({
  filters: x => x,
  capitalize: x => x
}))
jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

const hub = {
  data: {
    name: 'FOO_NAME',
    hub_code: 'FOO_HUB_CODE'
  },
  name: 'FOO_HUB_NAME'
}
const secondHub = {
  data: {
    name: 'BAR_NAME',
    hub_code: 'BAR_HUB_CODE'
  },
  name: 'BAR_HUB_NAME'
}
const propsBase = {
  theme,
  schedule: {
    id: 555777,
    eta: '2018-12-01T12:14:08+01:00',
    hub_route_key: '0-1'
  },
  hubs: [hub, secondHub],
  scheduleData: {
    routes: [],
    mapData: [],
    detailedItineraries: [],
    itineraryIds: [],
    itineraries: [{ modes_of_transport: 'air' }]
  },
  document: { viewer: null },
  itineraries: { filter: identity },
  adminDispatch: identity,
  setCurrentUrl: identity,
  documentDispatch: {},
  scope: {
    modes_of_transport: { air: 'Air' }
  },
  match: {
    url: 'URL'
  },
  user
}

test('shallow render', () => {
  expect(shallow(<AdminSchedules {...propsBase} />)).toMatchSnapshot()
})

test('state.showList is false', () => {
  const wrapper = shallow(<AdminSchedules {...propsBase} />)
  wrapper.setState({ showList: false })
  expect(wrapper).toMatchSnapshot()
})

test('scheduleData is falsy', () => {
  const props = {
    ...propsBase,
    scheduleData: null
  }
  expect(shallow(<AdminSchedules {...props} />)).toMatchSnapshot()
})

test('document.viewer is truthy', () => {
  const props = {
    ...propsBase,
    document: { viewer: {} }
  }
  expect(shallow(<AdminSchedules {...props} />)).toMatchSnapshot()
})

test('user.internal is truthy', () => {
  const props = {
    ...propsBase,
    user: internalUser
  }
  expect(shallow(<AdminSchedules {...props} />)).toMatchSnapshot()
})

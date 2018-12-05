import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, route, hub, tenant
} from '../../mocks'

import AdminRoutes from './AdminRoutes'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

const propsBase = {
  theme,
  allHubs: [hub],
  adminDispatch: {
    getRoute: identity,
    newRoute: identity
  },
  dispatch: identity,
  setCurrentUrl: identity,
  history: {},
  route,
  routes: [route],
  mapData: [],
  hubHash: {},
  loading: false,
  itinerary: {},
  itineraries: [],
  tenant,
  match: { url: 'URL' }
}

test('shallow render', () => {
  expect(shallow(<AdminRoutes {...propsBase} />)).toMatchSnapshot()
})

test('state.newRoute is true', () => {
  const wrapper = shallow(<AdminRoutes {...propsBase} />)
  wrapper.setState({ newRoute: true })
  expect(wrapper).toMatchSnapshot()
})

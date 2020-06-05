import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, tenant } from '../../../mock'

import AdminRoutesIndex from './AdminRoutesIndex'
jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
const propsBase = {
  theme,
  loading: false,
  adminDispatch: {
    getRoutes: identity,
    getItineraries: identity
  },
  toggleNewRoute: identity,
  itineraries: [
    {
      id: 1,
      name: 'Gothenburg - Shanghai',
      transshipment: 'direct',
      mode_of_transport: 'air'
    }
  ],
  tenant
}

test('shallow render', () => {
  expect(shallow(<AdminRoutesIndex {...propsBase} />)).toMatchSnapshot()
})

test('itineraries is falsy', () => {
  const props = {
    ...propsBase,
    itineraries: null
  }
  expect(shallow(<AdminRoutesIndex {...props} />)).toMatchSnapshot()
})

import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, tenant } from '../../mocks'

import AdminRoutesIndex from './AdminRoutesIndex'

const propsBase = {
  theme,
  loading: false,
  adminDispatch: {
    getRoutes: identity,
    getItineraries: identity
  },
  toggleNewRoute: identity,
  itineraries: {
    filter: identity
  },
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

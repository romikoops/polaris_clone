import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, shipments, user } from '../../mocks'

jest.mock('uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
jest.mock('../TextHeading/TextHeading', () => ({
  // eslint-disable-next-line react/prop-types
  TextHeading: ({ children }) => <div>{children}</div>
}))
// eslint-disable-next-line import/first
import { UserShipments } from './UserShipments'

const propsBase = {
  theme,
  setNav: identity,
  userDispatch: {
    getShipment: identity
  },
  loading: false,
  user,
  hubs: [],
  shipments
}

test('shallow render', () => {
  expect(shallow(<UserShipments {...propsBase} />)).toMatchSnapshot()
})

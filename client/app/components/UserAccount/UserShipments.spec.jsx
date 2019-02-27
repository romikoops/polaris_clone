import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, shipments, user } from '../../mocks/index'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
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

test.skip('shallow render', () => {
  expect(shallow(<UserShipments {...propsBase} />)).toMatchSnapshot()
})

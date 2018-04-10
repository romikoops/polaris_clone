import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, user, shipments, location } from '../../mocks'

jest.mock('../../helpers', () => ({
  gradientTextGenerator: x => x
}))
jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
jest.mock('./UserMergedShipHeaders', () => ({
  // eslint-disable-next-line react/prop-types
  UserMergedShipHeaders: ({ children }) => <div>{children}</div>
}))
jest.mock('./UserMergedShipment', () => ({
  // eslint-disable-next-line react/prop-types
  UserMergedShipment: ({ children }) => <div>{children}</div>
}))
jest.mock('./index.jsx', () => ({
  // eslint-disable-next-line react/prop-types
  UserLocations: ({ children }) => <div>{children}</div>
}))
jest.mock('../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: ({ props }) => <button {...props} />
}))
jest.mock('../TextHeading/TextHeading', () => ({
  // eslint-disable-next-line react/prop-types
  TextHeading: ({ children }) => <div>{children}</div>
}))
jest.mock('../Admin/AdminSearchables', () => ({
  // eslint-disable-next-line react/prop-types
  AdminSearchableClients: ({ children }) => <div>{children}</div>
}))
jest.mock('../Carousel/Carousel', () => ({
  // eslint-disable-next-line react/prop-types
  Carousel: ({ children }) => <div>{children}</div>
}))
// eslint-disable-next-line import/first
import { UserDashboard } from './UserDashboard'

const propsBase = {
  theme,
  setNav: identity,
  userDispatch: {
    getShipment: identity,
    goTo: identity
  },
  seeAll: identity,
  user,
  hubs: {},
  dashboard: {
    shipments,
    pricings: {},
    contacts: [],
    locations: [location]
  }
}

test('shallow render', () => {
  expect(shallow(<UserDashboard {...propsBase} />)).toMatchSnapshot()
})

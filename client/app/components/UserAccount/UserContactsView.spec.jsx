import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, contact, identity, match } from '../../mocks'

/**
 * ISSUE props.userDispatch.getContact is not declared in prop types
 */

jest.mock('../../helpers', () => ({
  gradientTextGenerator: x => x
}))
jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
jest.mock('../Admin', () => ({
  // eslint-disable-next-line react/prop-types
  AdminAddressTile: ({ children }) => <div>{children}</div>
}))
jest.mock('../Admin/AdminSearchables', () => ({
  // eslint-disable-next-line react/prop-types
  AdminSearchableShipments: ({ children }) => <div>{children}</div>
}))
jest.mock('../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: ({ props }) => <button {...props} />
}))
// eslint-disable-next-line import/first
import { UserContactsView } from './UserContactsView'

const shipment = {
  schedule_set: [{ hub_route_key: 'foo-bar' }]
}
const contactData = {
  contact,
  shipments: [shipment],
  location: identity
}

const propsBase = {
  theme,
  loading: false,
  match,
  hubs: [{}],
  contactData,
  userDispatch: {
    goBack: identity,
    getContact: identity
  }
}

test('shallow render', () => {
  expect(shallow(<UserContactsView {...propsBase} />)).toMatchSnapshot()
})

test('props.loading is true', () => {
  const props = {
    ...propsBase,
    loading: true
  }
  expect(shallow(<UserContactsView {...props} />)).toMatchSnapshot()
})

test('props.contactData is falsy', () => {
  const props = {
    ...propsBase,
    contactData: undefined
  }
  expect(shallow(<UserContactsView {...props} />)).toMatchSnapshot()
})

test('props.contactData.location is falsy', () => {
  const props = {
    ...propsBase,
    contactData: {
      ...contactData,
      location: undefined
    }
  }
  expect(shallow(<UserContactsView {...props} />)).toMatchSnapshot()
})

test('state.editBool is true', () => {
  const wrapper = shallow(<UserContactsView {...propsBase} />)
  wrapper.setState({ editBool: true })

  expect(wrapper).toMatchSnapshot()
})

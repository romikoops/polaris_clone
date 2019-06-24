import * as React from 'react'
import { shallow } from 'enzyme'
import { contact, theme, identity } from '../../mocks/index'

import AddressBook from './AddressBook'

const propsBase = {
  contacts: [contact],
  theme,
  autofillContact: identity
}
jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
test('shallow render', () => {
  expect(shallow(<AddressBook {...propsBase} />)).toMatchSnapshot()
})

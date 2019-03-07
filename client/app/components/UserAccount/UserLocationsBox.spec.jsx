import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, firstAddress, secondAddress } from '../../mocks/index'

import UserLocationsBox from './UserLocationsBox'

const propsBase = {
  addresses: [firstAddress, secondAddress],
  makePrimary: identity,
  toggleActiveView: identity,
  destroyAddress: identity,
  editLocation: identity,
  gradient: {},
  cols: 3
}

test('shallow render', () => {
  expect(shallow(<UserLocationsBox {...propsBase} />)).toMatchSnapshot()
})

test('state.page > 10', () => {
  const wrapper = shallow(<UserLocationsBox {...propsBase} />)
  wrapper.setState({ page: 11 })
  expect(wrapper).toMatchSnapshot()
})

import * as React from 'react'
import { shallow } from 'enzyme'
import {
  theme, identity, gMaps, address
} from '../../mocks/index'

import EditLocation from './EditLocation'

const propsBase = {
  theme,
  toggleActiveView: identity,
  saveLocation: identity,
  gMaps,
  geocodedAddress: 'GEO_ADDRESS',
  address
}

test('shallow render', () => {
  expect(shallow(<EditLocation {...propsBase} />)).toMatchSnapshot()
})

test('state.autocomplete.address is truthy', () => {
  const wrapper = shallow(<EditLocation {...propsBase} />)
  wrapper.setState({
    autocomplete: {
      address: 'ADDRESS'
    }
  })
  expect(wrapper).toMatchSnapshot()
})

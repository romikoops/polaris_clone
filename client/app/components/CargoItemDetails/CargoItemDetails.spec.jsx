import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, firstCargoItem } from '../../mocks'

import CargoItemDetails from './CargoItemDetails'

const propsBase = {
  item: firstCargoItem,
  index: 1,
  viewHSCodes: false,
  theme,
  hsCodes: []
}

test('shallow render', () => {
  expect(shallow(<CargoItemDetails {...propsBase} />)).toMatchSnapshot()
})

test('viewHSCodes is true', () => {
  const props = {
    ...propsBase,
    viewHSCodes: true
  }
  expect(shallow(<CargoItemDetails {...props} />)).toMatchSnapshot()
})

test('theme.colors is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<CargoItemDetails {...props} />)).toMatchSnapshot()
})

test('state.viewer is true', () => {
  const wrapper = shallow(<CargoItemDetails {...propsBase} />)
  wrapper.setState({ viewer: true })
  expect(wrapper).toMatchSnapshot()
})

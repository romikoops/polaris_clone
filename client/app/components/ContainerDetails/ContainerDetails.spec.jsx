import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, firstCargoItem } from '../../mocks'

import ContainerDetails from './ContainerDetails'

const propsBase = {
  item: firstCargoItem,
  index: 3,
  hsCodes: [],
  theme,
  viewHSCodes: false
}

test('shallow render', () => {
  expect(shallow(<ContainerDetails {...propsBase} />)).toMatchSnapshot()
})

test('viewHSCodes is true', () => {
  const props = {
    ...propsBase,
    viewHSCodes: true
  }
  expect(shallow(<ContainerDetails {...props} />)).toMatchSnapshot()
})

test('state.viewer is true', () => {
  const wrapper = shallow(<ContainerDetails {...propsBase} />)
  wrapper.setState({ viewer: true })

  expect(wrapper).toMatchSnapshot()
})

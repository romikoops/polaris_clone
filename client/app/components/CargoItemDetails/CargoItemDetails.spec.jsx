import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../mocks'

jest.mock('../HsCodes/HsCodeViewer', () => ({
  // eslint-disable-next-line react/prop-types
  HsCodeViewer: ({ children }) => <div>{children}</div>
}))
// eslint-disable-next-line import/first
import { CargoItemDetails } from './CargoItemDetails'

const propsBase = {
  item: {
    payload_in_kg: 56,
    chargeable_weight: 60,
    dimension_x: 111,
    dimension_y: 37,
    dimension_z: 70,
    hs_codes: []
  },
  index: 1,
  viewHSCodes: false,
  theme,
  hsCodes: []
}

test('shallow render', () => {
  expect(shallow(<CargoItemDetails {...propsBase} />)).toMatchSnapshot()
})

test('props.viewHSCodes is true', () => {
  const props = {
    ...propsBase,
    viewHSCodes: true
  }
  expect(shallow(<CargoItemDetails {...props} />)).toMatchSnapshot()
})

test('props.theme.colors is falsy', () => {
  const props = {
    ...propsBase,
    theme: {}
  }
  expect(shallow(<CargoItemDetails {...props} />)).toMatchSnapshot()
})

test('state.viewer is true', () => {
  const wrapper = shallow(<CargoItemDetails {...propsBase} />)
  wrapper.setState({ viewer: true })

  expect(wrapper).toMatchSnapshot()
})

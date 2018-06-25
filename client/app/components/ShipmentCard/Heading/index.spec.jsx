import * as React from 'react'
import { shallow } from 'enzyme'
import ShipmentCardHeading from './'
import { theme, identity } from '../../../mocks'

const propsBase = {
  text: 'FOO',
  collapsed: false,
  theme,
  handleCollapser: identity
}

test('shallow rendering', () => {
  expect(shallow(<ShipmentCardHeading {...propsBase} />)).toMatchSnapshot()
})

test('collapsed is true', () => {
  const props = {
    ...propsBase,
    collapsed: true
  }
  expect(shallow(<ShipmentCardHeading {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<ShipmentCardHeading {...props} />)).toMatchSnapshot()
})

import * as React from 'react'
import { shallow } from 'enzyme'
import CarriageToggle from '.'
import { theme } from '../../mocks'

const propsBase = {
  theme,
  carriage: 'pre',
  checked: true,
  onChange: null
}

test('with empty props', () => {
  expect(shallow(<CarriageToggle />)).toMatchSnapshot()
})

test('happy path', () => {
  expect(shallow(<CarriageToggle {...propsBase} />)).toMatchSnapshot()
})

test('carriage is on', () => {
  const props = {
    ...propsBase,
    carriage: 'on'
  }
  expect(shallow(<CarriageToggle {...props} />)).toMatchSnapshot()
})

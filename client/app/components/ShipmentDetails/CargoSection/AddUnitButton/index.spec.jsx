import * as React from 'react'
import { shallow } from 'enzyme'
import AddUnitButton from '.'
import { theme } from '../../mocks'

const propsBase = {
  theme,
  onClick: null
}

test('with empty props', () => {
  expect(shallow(<AddUnitButton />)).toMatchSnapshot()
})

test('happy path', () => {
  expect(shallow(<AddUnitButton {...propsBase} />)).toMatchSnapshot()
})

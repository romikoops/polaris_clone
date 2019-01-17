import * as React from 'react'
import { shallow } from 'enzyme'
import { ChargableProperties } from '.'
import {
  t, scope, availableMots, cargoItem, maxDimensionsToApply
} from '../../../../mocks'

const propsBase = {
  t,
  cargoItem,
  availableMots,
  scope,
  maxDimensions: maxDimensionsToApply
}

test('with empty props', () => {
  expect(() => shallow(<ChargableProperties />)).toThrow()
})

test('happy path', () => {
  expect(shallow(<ChargableProperties {...propsBase} />)).toMatchSnapshot()
})

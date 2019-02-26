import * as React from 'react'
import { shallow } from 'enzyme'
import ChargeableProperties from '.'
import {
  t, scope, availableMots, allMots, cargoItem, maxDimensionsToApply
} from '../../../../mocks'

const propsBase = {
  t,
  cargoItem,
  availableMots,
  allMots,
  scope,
  maxDimensions: maxDimensionsToApply
}

test('with empty props', () => {
  expect(() => shallow(<ChargeableProperties />)).toThrow()
})

test('happy path', () => {
  expect(shallow(<ChargeableProperties {...propsBase} />)).toMatchSnapshot()
})

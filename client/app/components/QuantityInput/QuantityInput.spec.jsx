import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../mocks'

import QuantityInput from './QuantityInput'

const propsBase = {
  cargoItem: {},
  i: 1,
  handleDelta: identity,
  nextStageAttempt: false
}

test('shallow rendering', () => {
  expect(shallow(<QuantityInput {...propsBase} />)).toMatchSnapshot()
})

test('with cargoItem.quantity', () => {
  const props = {
    ...propsBase,
    cargoItem: { quantity: 3 }
  }

  expect(shallow(<QuantityInput {...props} />)).toMatchSnapshot()
})

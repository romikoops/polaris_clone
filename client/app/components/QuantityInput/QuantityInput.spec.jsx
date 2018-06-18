import * as React from 'react'
import { shallow as shallowMethod } from 'enzyme'
import { identity } from '../../mocks'

import QuantityInput from './QuantityInput'

const propsBase = {
  cargoItem: {},
  i: 1,
  handleDelta: identity,
  nextStageAttempt: false
}

const createShallow = propsInput => shallowMethod(<QuantityInput {...propsInput} />)

test('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})

test('with cargoItem.quantity', () => {
  const props = {
    ...propsBase,
    cargoItem: { quantity: 3 }
  }

  expect(createShallow(props)).toMatchSnapshot()
})

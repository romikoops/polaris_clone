import * as React from 'react'
import { shallow } from 'enzyme'
import {
  airDimensions,
  firstCargoItem,
  generalDimensions,
  identity,
  theme,
  turnFalsy
} from '../../mocks'

import ShipmentAggregatedCargo from './ShipmentAggregatedCargo'

const propsBase = {
  theme,
  aggregatedCargo: firstCargoItem,
  handleDelta: identity,
  nextStageAttempt: false,
  maxDimensions: {
    general: generalDimensions,
    air: airDimensions
  },
  availableMotsForRoute: ['air']
}

test('shallow rendering', () => {
  expect(shallow(<ShipmentAggregatedCargo {...propsBase} />)).toMatchSnapshot()
})

test('airDimensions.payloadInKg is falsy', () => {
  const props = turnFalsy(
    propsBase,
    'maxDimensions.air.payloadInKg'
  )
  expect(shallow(<ShipmentAggregatedCargo {...props} />)).toMatchSnapshot()
})

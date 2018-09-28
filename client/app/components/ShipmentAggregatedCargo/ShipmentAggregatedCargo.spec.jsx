import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'
// eslint-disable-next-line
import ShipmentAggregatedCargo from './ShipmentAggregatedCargo'

const propsBase = {
  theme,
  aggregatedCargo: {
    volume: 10,
    weight: 100
  },
  handleDelta: identity,
  nextStageAttempt: false,
  maxDimensions: {
    general: {
      dimensionX: '0',
      dimensionY: '0',
      dimensionZ: '0',
      payloadInKg: '0',
      chargeableWeight: '0'
    },
    air: {
      dimensionX: '0',
      dimensionY: '0',
      dimensionZ: '0',
      payloadInKg: '1000',
      chargeableWeight: '1000'
    }
  },
  availableMotsForRoute: ['ocean', 'air']
}

test('shallow rendering', () => {
  expect(shallow(<ShipmentAggregatedCargo {...propsBase} />)).toMatchSnapshot()
})

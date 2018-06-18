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
  nextStageAttempt: false
}

test('shallow rendering', () => {
  expect(shallow(<ShipmentAggregatedCargo {...propsBase} />)).toMatchSnapshot()
})

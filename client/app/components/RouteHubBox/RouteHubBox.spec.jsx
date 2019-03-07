import '../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, shipment } from '../../mocks/index'

import RouteHubBox from './RouteHubBox'

const propsBase = {
  theme,
  shipment
}

test('shallow rendering', () => {
  expect(shallow(<RouteHubBox {...propsBase} />)).toMatchSnapshot()
})

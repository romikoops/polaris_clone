import * as React from 'react'
import { shallow } from 'enzyme'

import AdminRequestedShipments from './AdminRequestedShipments'

const propsBase = {
  requested: [
    <div />,
    <div />
  ]
}

test('shallow render', () => {
  expect(shallow(<AdminRequestedShipments {...propsBase} />)).toMatchSnapshot()
})

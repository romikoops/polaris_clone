import * as React from 'react'
import { shallow } from 'enzyme'
import TruckingTooltip from './TruckingTooltip'

const propsBase = {
  truckingOptions: { mandatory: true },
  scope: { carriage_options: { on_carriage: {}, pre_carriage: {} } },
  carriage: 'Carriage',
  hubName: 'HubName',
  direction: '',
  truckingBoolean: true
}

const wrapper = shallow(<TruckingTooltip {...propsBase} />)

test('Data Tip returns correct string', () => {
  const div = (wrapper.find('.toggle_box_overlay'))
  expect(div.contains(<div className="toggle_box_overlay" data-tip="Carriage is not available in HubName" />)).toEqual(true)
})

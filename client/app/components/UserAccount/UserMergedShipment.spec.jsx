import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { identity } from '../../mocks/index'
import { UserMergedShipment } from './UserMergedShipment'

const propsBase = {
  viewShipment: identity,
  ship: {
    origin_hub: { name: 'FOO_ORIGIN' },
    destination_hub: { name: 'FOO_DESTINATION' },
    imc_reference: 'FOO_IMC',
    status: 'FOO_STATUS',
    incoterm: 'FOO_INCOTERM'
  }
}

test('shallow render', () => {
  expect(shallow(<UserMergedShipment {...propsBase} />)).toMatchSnapshot()
})

test('props.viewShipment is called', () => {
  const props = {
    ...propsBase,
    viewShipment: jest.fn()
  }
  const wrapper = mount(<UserMergedShipment {...props} />)

  const clickableDiv = wrapper.find('.pointy').first()
  clickableDiv.simulate('click')

  expect(props.viewShipment).toHaveBeenCalled()
})

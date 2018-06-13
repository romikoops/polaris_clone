import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { identity } from '../../mocks'
import { UserMergedShipment } from './UserMergedShipment'

const propsBase = {
  viewShipment: identity,
  ship: {
    originHub: 'FOO_ORIGIN',
    destinationHub: 'FOO_DESTINATION',
    imc_reference: 'FOO_IMC',
    status: 'FOO_STATUS',
    incoterm: 'FOO_INCOTERM'
  }
}

test.skip('shallow render', () => {
  expect(shallow(<UserMergedShipment {...propsBase} />)).toMatchSnapshot()
})

test.skip('props.viewShipment is called', () => {
  const props = {
    ...propsBase,
    viewShipment: jest.fn()
  }
  const wrapper = mount(<UserMergedShipment {...props} />)

  const clickableDiv = wrapper.find('.pointy').first()
  clickableDiv.simulate('click')

  expect(props.viewShipment).toHaveBeenCalled()
})

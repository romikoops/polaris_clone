import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, containers } from '../../mocks'
import ShipmentContainers from './ShipmentContainers'

const propsBase = {
  theme,
  addContainer: identity,
  containers,
  deleteItem: identity,
  handleDelta: identity,
  nextStageAttempt: false,
  scope: {
    dangerous_goods: false
  },
  toggleModal: identity
}

test('shallow rendering', () => {
  expect(
    shallow(<ShipmentContainers {...propsBase} />)
  ).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(
    shallow(<ShipmentContainers {...props} />)
  ).toMatchSnapshot()
})

test('scope.dangerous_goods is true', () => {
  const props = {
    ...propsBase,
    scope: {
      dangerous_goods: true
    }
  }
  expect(
    shallow(<ShipmentContainers {...props} />)
  ).toMatchSnapshot()
})

test('addContainer is called', () => {
  const props = {
    ...propsBase,
    addContainer: jest.fn()
  }
  const wrapper = shallow(<ShipmentContainers {...props} />)

  const clickableDiv = wrapper.find('.add_unit_wrapper > div').first()
  clickableDiv.simulate('click')

  expect(props.addContainer).toHaveBeenCalled()

  expect(wrapper.state().firstRenderInputs).toEqual(true)
})

test('deleteItem is called', () => {
  const props = {
    ...propsBase,
    deleteItem: jest.fn()
  }
  const wrapper = shallow(<ShipmentContainers {...props} />)
  const icon = wrapper.find('i').first()

  expect(props.deleteItem).not.toHaveBeenCalled()
  icon.simulate('click')
  expect(props.deleteItem).toHaveBeenCalled()
})

test('firstRenderInputs is called', () => {
  const props = {
    ...propsBase,
    setFirstRenderInputs: jest.fn()
  }
  const wrapper = shallow(<ShipmentContainers {...props} />)

  wrapper.instance().setFirstRenderInputs(false)
  expect(wrapper.state().firstRenderInputs).toEqual(false)
})

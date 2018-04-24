import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { theme, identity } from '../../mocks'

jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
jest.mock('../Checkbox/Checkbox', () => ({
  // eslint-disable-next-line react/prop-types
  Checkbox: ({ children }) => <div>{children}</div>
}))
jest.mock('../NamedSelect/NamedSelect', () => ({
  // eslint-disable-next-line react/prop-types
  NamedSelect: ({ children }) => <div>{children}</div>
}))
jest.mock('../Tooltip/Tooltip', () => ({
  // eslint-disable-next-line react/prop-types
  Tooltip: ({ children }) => <div>{children}</div>
}))
// eslint-disable-next-line import/first
import { ShipmentContainers } from './ShipmentContainers'

const createWrapper = propsInput => mount(<ShipmentContainers {...propsInput} />)

const baseContainer = {
  payload_in_kg: 11,
  tareWeight: 15,
  quantity: 3,
  dangerous_goods: false
}

const propsBase = {
  theme,
  addContainer: identity,
  containers: [baseContainer],
  deleteItem: identity,
  handleDelta: identity,
  nextStageAttempt: false,
  scope: {
    dangerous_goods: false
  },
  toggleModal: identity
}

const createShallow = propsInput => shallow(<ShipmentContainers {...propsInput} />)

test('shallow rendering', () => {
  expect(createShallow(propsBase)).toMatchSnapshot()
})

test('props.nextStageAttempt is true', () => {
  const props = {
    ...propsBase,
    nextStageAttempt: true
  }
  expect(createShallow(props)).toMatchSnapshot()
})

test('props.scope.dangerous_goods is true', () => {
  const props = {
    ...propsBase,
    scope: {
      dangerous_goods: true
    }
  }
  expect(createShallow(props)).toMatchSnapshot()
})

test('props.containers has dangerous_goods as true', () => {
  const props = {
    ...propsBase,
    containers: [{
      ...baseContainer,
      dangerous_goods: true
    }]
  }
  expect(createShallow(props)).toMatchSnapshot()
})

test('props.addContainer is called', () => {
  const props = {
    ...propsBase,
    addContainer: jest.fn()
  }
  const wrapper = createWrapper(props)
  const clickableDiv = wrapper.find('.add_unit').first()

  expect(props.addContainer).not.toHaveBeenCalled()
  clickableDiv.simulate('click')
  expect(props.addContainer).toHaveBeenCalled()
})

test('props.deleteItem is called', () => {
  const props = {
    ...propsBase,
    deleteItem: jest.fn()
  }
  const wrapper = createWrapper(props)
  const icon = wrapper.find('i').first()

  expect(props.deleteItem).not.toHaveBeenCalled()
  icon.simulate('click')
  expect(props.deleteItem).toHaveBeenCalled()
})

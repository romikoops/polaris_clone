import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { theme, identity } from '../../mocks'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
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

test('nextStageAttempt is true', () => {
  const props = {
    ...propsBase,
    nextStageAttempt: true
  }
  expect(createShallow(props)).toMatchSnapshot()
})

test('scope.dangerous_goods is true', () => {
  const props = {
    ...propsBase,
    scope: {
      dangerous_goods: true
    }
  }
  expect(createShallow(props)).toMatchSnapshot()
})

test('containers.dangerous_goods is true', () => {
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
  const clickableDiv = wrapper.find('.add_unit_wrapper > div').first()
  clickableDiv.simulate('click')

  expect(props.addContainer).toHaveBeenCalled()

  expect(wrapper.state().firstRenderInputs).toEqual(true)
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

test('firstRenderInputs fn sets the state to the boolean that it is passed', () => {
  const props = {
    ...propsBase,
    setFirstRenderInputs: jest.fn()
  }
  const wrapper = createWrapper(props)

  wrapper.instance().setFirstRenderInputs(false)
  expect(wrapper.state().firstRenderInputs).toEqual(false)
})

// not working yet
test('handleContainerQ modifies Props', () => {
  const props = {
    ...propsBase,
    handleContainerQ: jest.fn()
  }

  const wrapper = createWrapper(props)

  wrapper.instance().handleContainerQ(identity)
  expect(wrapper.props().handleDelta).toEqual(identity)
})

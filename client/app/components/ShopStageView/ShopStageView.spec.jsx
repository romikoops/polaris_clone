import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { identity, tenant, theme } from '../../mocks'
// eslint-disable-next-line no-named-as-default
import ShopStageView from './ShopStageView'

jest.mock('react-redux', () => ({
  connect: (x, y) => Component => Component
}))

const createWrapper = propsInput => mount(<ShopStageView {...propsInput} />)

const propsBase = {
  theme,
  tenant,
  setStage: identity,
  currentStage: 1,
  shopType: 'FOO_SHOP_TYPE',
  disabledClick: false,
  cookieDispatch: {
    updateCookieHeight: jest.fn()
  },
  store: {
    getState: jest.fn(),
    subscribe: jest.fn()
  },
  storeDispatch: jest.fn(),
  appDispatch: jest.fn()
}

test('shallow rendering', () => {
  expect(shallow(<ShopStageView {...propsBase} />)).toMatchSnapshot()
})

test('props.setStage is called', () => {
  const props = {
    ...propsBase,
    currentStage: 3,
    setStage: jest.fn()
  }
  const wrapper = createWrapper(props)
  const pastStages = wrapper.find('.shop_stage_past')

  expect(pastStages).toHaveLength(2)

  expect(props.setStage).not.toHaveBeenCalled()
  pastStages.first().simulate('click')
  expect(props.setStage).toHaveBeenCalled()
})

test('setStage is not called when disabledClick is true', () => {
  const props = {
    ...propsBase,
    currentStage: 3,
    disabledClick: true,
    setStage: jest.fn()
  }
  const wrapper = createWrapper(props)
  const pastStages = wrapper.find('.shop_stage_past')

  expect(pastStages).toHaveLength(2)

  expect(props.setStage).not.toHaveBeenCalled()
  pastStages.first().simulate('click')
  expect(props.setStage).not.toHaveBeenCalled()
})

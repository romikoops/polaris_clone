import '../../mocks/libraries/react-redux'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  identity, tenant, theme, change
} from '../../mocks'

import ShopStageView from './ShopStageView'

const propsBase = {
  theme,
  tenant,
  hasNextStage: false,
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

test('hasNextStage is true', () => {
  const props = {
    ...propsBase,
    hasNextStage: true
  }
  expect(shallow(<ShopStageView {...props} />)).toMatchSnapshot()
})

test('tenant.scope is falsy', () => {
  const props = change(
    propsBase,
    'tenant.scope',
    {}
  )
  expect(shallow(<ShopStageView {...props} />)).toMatchSnapshot()
})

test('theme.bookingProcessImage is truthy', () => {
  const props = change(
    propsBase,
    'theme.bookingProcessImage',
    'BOOKING_PROCESS_IMAGE'
  )
  expect(shallow(<ShopStageView {...props} />)).toMatchSnapshot()
})

test('state.showHelp is true', () => {
  const wrapper = shallow(<ShopStageView {...propsBase} />)
  wrapper.setState({ showHelp: true })
  expect(wrapper).toMatchSnapshot()
})

test.skip('setStage is called', () => {
  const props = {
    ...propsBase,
    currentStage: 3,
    setStage: jest.fn()
  }
  const wrapper = shallow(<ShopStageView {...props} />)
  const pastStages = wrapper.find('.shop_stage_past')

  expect(pastStages).toHaveLength(2)
  expect(props.setStage).not.toHaveBeenCalled()

  pastStages.first().simulate('click')
  expect(props.setStage).toHaveBeenCalled()
})

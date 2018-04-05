import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { identity, theme } from '../../mocks'

jest.mock('../../helpers', () => ({
  gradientGenerator: x => x,
  gradientTextGenerator: x => x
}))
// eslint-disable-next-line import/first
import { ShopStageView } from './ShopStageView'

const createWrapper = propsInput => mount(<ShopStageView {...propsInput} />)

const propsBase = {
  theme,
  setStage: identity,
  currentStage: 1,
  shopType: 'FOO_SHOP_TYPE',
  disabledClick: false
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

import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { identity, theme } from '../../mocks/index'

import StageTimeline from './StageTimeline'

const createWrapper = propsInput => mount(<StageTimeline {...propsInput} />)

const propsBase = {
  theme,
  stages: ['0', '1', '2'],
  setStage: identity,
  currentStageIndex: 0
}

test('shallow rendering', () => {
  expect(shallow(<StageTimeline {...propsBase} />)).toMatchSnapshot()
})

test('setStage is called', () => {
  const props = {
    ...propsBase,
    setStage: jest.fn()
  }
  const wrapper = createWrapper(props)
  const selector = 'div[className="layout-column layout-align-start-center flex-none"]'
  const clickableDiv = wrapper.find(selector).first()

  expect(props.setStage).not.toHaveBeenCalled()
  clickableDiv.simulate('click')
  expect(props.setStage).toHaveBeenCalled()
})

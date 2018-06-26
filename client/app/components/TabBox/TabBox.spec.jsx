import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { TabBox } from './TabBox'

const propsBase = {
  tabs: ['FOO', 'BAR'],
  components: [React.createElement('div')]
}

test('shallow rendering', () => {
  expect(shallow(<TabBox {...propsBase} />)).toMatchSnapshot()
})

test('this.changeTab is called', () => {
  const wrapper = mount(<TabBox {...propsBase} />)
  expect(wrapper.state().tab).toBe(0)
  const clickableDiv = wrapper.find('.tabdiv > div').last()
  clickableDiv.simulate('click')

  expect(wrapper.state().tab).toBe(1)
})

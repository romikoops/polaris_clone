import * as React from 'react'
import { mount, shallow } from 'enzyme'
import {
  theme, identity, hsCodes, firstCargoItem
} from '../../mocks/index'
import HsCodeViewer from './HsCodeViewer'

const propsBase = {
  theme,
  close: identity,
  item: firstCargoItem,
  hsCodes
}

test('shallow render', () => {
  expect(shallow(<HsCodeViewer {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<HsCodeViewer {...props} />)).toMatchSnapshot()
})

test('viewer[hs] is truthy', () => {
  const wrapper = shallow(<HsCodeViewer {...propsBase} />)
  /**
   * `viewer` has such value because `firstCargoItem` has `hs_codes: [4]`
   */
  wrapper.setState({
    viewer: [
      false,
      false,
      false,
      false,
      true
    ]
  })
  expect(wrapper).toMatchSnapshot()
})

test('close is called', () => {
  const props = {
    ...propsBase,
    close: jest.fn()
  }
  const wrapper = mount(<HsCodeViewer {...props} />)
  const clickableDiv = wrapper.find('.flex-10').first()

  expect(props.close).not.toHaveBeenCalled()
  clickableDiv.simulate('click')
  expect(props.close).toHaveBeenCalled()
})

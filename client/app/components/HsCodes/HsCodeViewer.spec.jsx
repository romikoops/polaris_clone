import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { theme, identity } from '../../mocks'
// eslint-disable-next-line import/no-named-as-default
import HsCodeViewer from './HsCodeViewer'

const propsBase = {
  theme,
  close: identity,
  item: {
    hs_codes: []
  },
  hsCodes: []
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

test('props.close is called', () => {
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

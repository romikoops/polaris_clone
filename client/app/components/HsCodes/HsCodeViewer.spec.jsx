import * as React from 'react'
import { mount } from 'enzyme'
// eslint-disable-next-line import/no-named-as-default
import HsCodeViewer from './HsCodeViewer'

const props = {
  theme: null,
  close: jest.fn(),
  item: {
    hs_codes: []
  },
  hsCodes: []
}

const wrapper = mount(<HsCodeViewer {...props} />)

test('props.close is called upon click', () => {
  const clickableDiv = wrapper.find('.flex-10').first()

  expect(props.close).not.toHaveBeenCalled()
  clickableDiv.simulate('click')
  expect(props.close).toHaveBeenCalled()
})

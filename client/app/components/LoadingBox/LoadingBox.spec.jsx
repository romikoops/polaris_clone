import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../mocks'

import LoadingBox from './LoadingBox'

const propsBase = {
  theme
}

test('shallow render', () => {
  expect(shallow(<LoadingBox theme={theme} />)).toMatchSnapshot()
})

test('theme has logo', () => {
  const newTheme = {
    ...theme,
    logo: 'LOGO'
  }
  expect(shallow(<LoadingBox theme={newTheme} />)).toMatchSnapshot()
})

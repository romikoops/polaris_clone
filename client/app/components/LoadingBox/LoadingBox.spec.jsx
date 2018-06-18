import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../mocks'

// eslint-disable-next-line
import LoadingBox from './LoadingBox'

const propsBase = {
  theme,
  text: 'FOO_TEXT'
}

test('shallow render', () => {
  expect(shallow(<LoadingBox {...propsBase} />)).toMatchSnapshot()
})

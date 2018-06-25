import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../mocks'

// eslint-disable-next-line
import Modal from './Modal'

const propsBase = {
  component: ({ children }) => <div>{children}</div>,
  parentToggle: identity,
  minHeight: '55px',
  horizontalPadding: '33px',
  verticalPadding: '22px'
}

test('shallow render', () => {
  expect(shallow(<Modal {...propsBase} />)).toMatchSnapshot()
})

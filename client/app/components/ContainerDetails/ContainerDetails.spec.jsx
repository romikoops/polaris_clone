import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../mocks'

jest.mock('../HsCodes/HsCodeViewer', () => ({
  // eslint-disable-next-line react/prop-types
  HsCodeViewer: ({ children }) => <div>{children}</div>
}))
// eslint-disable-next-line
import ContainerDetails from './ContainerDetails'

const propsBase = {
  item: {
    payload_in_kg: 134,
    size_class: 'FOO_SIZE_CLASS',
    quantity: 5
  },
  index: 3,
  hsCodes: [],
  theme,
  viewHSCodes: false
}

test('shallow render', () => {
  expect(shallow(<ContainerDetails {...propsBase} />)).toMatchSnapshot()
})

test('props.viewHSCodes is true', () => {
  const props = {
    ...propsBase,
    viewHSCodes: true
  }
  expect(shallow(<ContainerDetails {...props} />)).toMatchSnapshot()
})

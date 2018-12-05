import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, client } from '../../mocks'

import AdminClientCardIndex from './AdminClientCardIndex'

const propsBase = {
  theme,
  clients: [],
  viewClient: identity
}

test('shallow render', () => {
  expect(shallow(<AdminClientCardIndex {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminClientCardIndex {...props} />)).toMatchSnapshot()
})

test('clients is truthy', () => {
  const props = {
    ...propsBase,
    clients: [client]
  }
  expect(shallow(<AdminClientCardIndex {...props} />)).toMatchSnapshot()
})

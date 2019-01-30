import * as React from 'react'
import { shallow } from 'enzyme'
import { user } from '../../mocks'

import NavDropdown from './NavDropdown'

const linkOption = {
  key: 'LINK_OPTION_KEY',
  text: 'LINK_OPTION_TEXT',
  fontAwesomeIcon: 'LINK_OPTION_ICON'
}

const propsBase = {
  user,
  dropDownText: 'FOO_TEXT',
  linkOptions: [linkOption],
  invert: false
}

test('shallow rendering', () => {
  expect(shallow(<NavDropdown {...propsBase} />)).toMatchSnapshot()
})

test('dropDownText is falsy', () => {
  const props = {
    ...propsBase,
    dropDownText: null
  }
  expect(shallow(<NavDropdown {...props} />)).toMatchSnapshot()
})

test('user is falsy', () => {
  const props = {
    ...propsBase,
    user: null
  }
  expect(shallow(<NavDropdown {...props} />)).toMatchSnapshot()
})

test('linkOption provides url', () => {
  const props = {
    ...propsBase,
    linkOptions: [{
      ...linkOption,
      url: 'LINK_OPTION_URL'
    }]
  }

  expect(shallow(<NavDropdown {...props} />)).toMatchSnapshot()
})

test('missing fontAwesomeIcon', () => {
  const props = {
    ...propsBase,
    linkOptions: [{
      ...linkOption,
      url: 'LINK_OPTION_URL',
      fontAwesomeIcon: null
    }]
  }
  expect(shallow(<NavDropdown {...props} />)).toMatchSnapshot()
})

import * as React from 'react'
import { shallow } from 'enzyme'

// eslint-disable-next-line
import NavDropdown from './NavDropdown'

const linkOptionBase = {
  key: 'FOO_KEY',
  text: 'BAR_TEXT',
  fontAwesomeIcon: 'FOO_FA'
}

const linkOption = {
  ...linkOptionBase,
  url: 'FOO_URL'
}

const propsBase = {
  dropDownText: 'FOO_TEXT',
  linkOptions: [linkOption],
  invert: false
}

test('shallow rendering', () => {
  expect(shallow(<NavDropdown {...propsBase} />)).toMatchSnapshot()
})

test('when linkOptions doesn\'t provide url', () => {
  const props = {
    ...propsBase,
    linkOptions: [linkOptionBase]
  }

  expect(shallow(<NavDropdown {...props} />)).toMatchSnapshot()
})

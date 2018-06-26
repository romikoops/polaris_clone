import * as React from 'react'
import { shallow, mount } from 'enzyme'

// eslint-disable-next-line
import { NavDropdown } from './NavDropdown'

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

test('click calls listOption.select', () => {
  const props = {
    ...propsBase,
    linkOptions: [{
      ...linkOptionBase,
      select: jest.fn()
    }]
  }

  const dom = mount(<NavDropdown {...props} />)
  const clickableDiv = dom.find('.dropdowncontent > div').first()

  expect(props.linkOptions[0].select).not.toHaveBeenCalled()
  clickableDiv.simulate('click')
  expect(props.linkOptions[0].select).toHaveBeenCalled()
})

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

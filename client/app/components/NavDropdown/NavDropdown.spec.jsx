import * as React from 'react'
import { shallow as shallowMethod, mount } from 'enzyme'

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

let shallow

const createWrapper = propsInput => mount(<NavDropdown {...propsInput} />)
const createShallow = propsInput => shallowMethod(<NavDropdown {...propsInput} />)

beforeEach(() => {
  shallow = createShallow(propsBase)
})

test('click calls listOption.select', () => {
  const props = {
    ...propsBase,
    linkOptions: [{
      ...linkOptionBase,
      select: jest.fn()
    }]
  }

  const dom = createWrapper(props)
  const clickableDiv = dom.find('.dropdowncontent > div').first()

  expect(props.linkOptions[0].select).not.toHaveBeenCalled()
  clickableDiv.simulate('click')
  expect(props.linkOptions[0].select).toHaveBeenCalled()
})

test('shallow rendering', () => {
  expect(shallow).toMatchSnapshot()
})

test('when linkOptions doesn\'t provide url', () => {
  const props = {
    ...propsBase,
    linkOptions: [linkOptionBase]
  }
  const dom = createShallow(props)

  expect(dom).toMatchSnapshot()
})

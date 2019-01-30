import * as React from 'react'
import { mount, shallow } from 'enzyme'
import {
  theme, contact, firstAddress, identity, change
} from '../../mocks'

import ContactCard from '.'

const propsBase = {
  contactData: {
    contact,
    address: firstAddress
  },
  theme,
  select: identity,
  contactType: 'CONTACT_TYPE',
  removeFunc: null,
  popOutHover: false
}

test('shallow render', () => {
  expect(shallow(<ContactCard {...propsBase} />)).toMatchSnapshot()
})

test('contactData.address is falsy', () => {
  const props = change(
    propsBase,
    'contactData.address',
    {}
  )
  expect(shallow(<ContactCard {...props} />)).toMatchSnapshot()
})

test('select is called upon click', () => {
  const props = {
    ...propsBase,
    select: jest.fn()
  }
  const dom = mount(<ContactCard {...props} />)
  const clickableDiv = dom.find('div.contact_card').first()
  clickableDiv.simulate('click')

  expect(props.select).toHaveBeenCalled()
})

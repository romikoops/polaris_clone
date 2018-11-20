import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { theme, user, identity } from '../../mocks'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
// eslint-disable-next-line
import ContactCard from './'

const editedUser = {
  ...user,
  firstName: user.first_name,
  lastName: user.last_name
}

const propsBase = {
  contactData: {
    contact: editedUser,
    address: {}
  },
  theme,
  select: identity,
  contactType: '',
  removeFunc: null,
  popOutHover: false
}

test('shallow render', () => {
  expect(shallow(<ContactCard {...propsBase} />)).toMatchSnapshot()
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

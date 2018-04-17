import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { theme, user, identity } from '../../mocks'

jest.mock('react-truncate', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <span>{children}</span>)

// eslint-disable-next-line
import ContactCard from './ContactCard'

const editedUser = {
  ...user,
  firstName: user.first_name,
  lastName: user.last_name
}

const propsBase = {
  contactData: {
    contact: editedUser,
    location: {}
  },
  theme,
  select: identity,
  contactType: '',
  removeFunc: null,
  popOutHover: false
}

let wrapper

const createWrapper = propsInput => mount(<ContactCard {...propsInput} />)

beforeEach(() => {
  wrapper = createWrapper(propsBase)
})

test('shallow render', () => {
  expect(shallow(<ContactCard {...propsBase} />)).toMatchSnapshot()
})

test('props.select is called upon click', () => {
  const props = {
    ...propsBase,
    select: jest.fn()
  }
  const dom = createWrapper(props)
  const clickableDiv = dom.find('div.contact_card').first()

  expect(props.select).not.toHaveBeenCalled()
  clickableDiv.simulate('click')
  expect(props.select).toHaveBeenCalled()
})

test('remove icon is visible when passing props.removeFunc', () => {
  const props = {
    ...propsBase,
    removeFunc: jest.fn()
  }
  const dom = createWrapper(props)

  const removeDefault = wrapper.find('.contact_card > i')
  const remove = dom.find('.contact_card > i')

  expect(removeDefault).toHaveLength(0)
  expect(remove).toHaveLength(1)
})

test('click on remove icon calls props.removeFunc', () => {
  const props = {
    ...propsBase,
    removeFunc: jest.fn()
  }
  const dom = createWrapper(props)

  const remove = dom.find('.contact_card > i').first()

  expect(props.removeFunc).not.toHaveBeenCalled()
  remove.simulate('click')
  expect(props.removeFunc).toHaveBeenCalled()
})

test('correctly render contact details', () => {
  const name = wrapper.find('.contact_header').first().text()
  const email = wrapper.find('.contact_details p').first().text()
  const phone = wrapper.find('.contact_details p').at(1).text()

  expect(name.includes(user.first_name)).toBeTruthy()
  expect(name.includes(user.last_name)).toBeTruthy()
  expect(email.includes(user.email)).toBeTruthy()
  expect(phone.includes(user.phone)).toBeTruthy()
})

test('location', () => {
  const locationProp = {
    geocodedAddress: 'FOO_GEO',
    fullAddress: 'FOO_FULL_ADDRESS'
  }
  const props = {
    ...propsBase,
    contactData: {
      ...propsBase.contactData,
      location: locationProp
    }
  }
  const withLocation = createWrapper(props)

  const defaultLocation = wrapper.find('p.flex-100').last().text()
  const location = withLocation.find('p.flex-100').last().text()

  expect(defaultLocation).toBe('')
  expect(location).toBe(locationProp.geocodedAddress)
})

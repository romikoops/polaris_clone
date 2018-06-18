import * as React from 'react'
import { mount, shallow } from 'enzyme'
import Contact from './Contact'
import { user, location } from '../../mocks'

const propsBase = {
  contact: { data: user },
  contactType: '',
  textStyle: {}
}

let wrapper

const createWrapper = propsInput => mount(<Contact {...propsInput} />)

beforeEach(() => {
  wrapper = createWrapper(propsBase)
})

test('shallow render', () => {
  expect(shallow(<Contact {...propsBase} />)).toMatchSnapshot()
})

test('props.textStyle', () => {
  const props = {
    ...propsBase,
    textStyle: { background: '#449' }
  }
  const withStyle = createWrapper(props)

  const icon = withStyle.find('i').first()
  const style = icon.prop('style')

  expect(style).toEqual(props.textStyle)
})

const selector = 'p[className="contact_text flex-100"]'

test('props.contact name', () => {
  const name = wrapper.find(selector).at(0).text()
  const expectedName = `${user.first_name} ${user.last_name}`

  expect(name).toBe(expectedName)
})

test('props.contact company', () => {
  const company = wrapper.find(selector).at(1).text()

  expect(company).toBe(user.company_name)
})

test('props.contact email', () => {
  const email = wrapper.find(selector).at(2).text()

  expect(email).toBe(user.email)
})

test('props.contact phone', () => {
  const phone = wrapper.find(selector).at(3).text()

  expect(phone).toBe(user.phone)
})

test('when props.contact.location is missing', () => {
  const address = wrapper.find('address')

  expect(address.text()).toBe(' ')
})

test('when props.contact.location is present', () => {
  const props = {
    ...propsBase,
    contact: {
      ...propsBase.contact,
      location
    }
  }

  const withLocation = createWrapper(props)
  const address = withLocation.find('address').first().text()

  expect(address.includes(location.street)).toBeTruthy()
  expect(address.includes(location.street_number)).toBeTruthy()
  expect(address.includes(location.zip_code)).toBeTruthy()
  expect(address.includes(location.country)).toBeTruthy()
})

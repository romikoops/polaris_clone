import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../../../../mocks'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter++

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
// eslint-disable-next-line
import ContactSetterBodyNotifyeeContactsContactCard from './'

const propsBase = {
  onClick: identity
}

test('shallow render', () => {
  const Component = <ContactSetterBodyNotifyeeContactsContactCard {...propsBase} />

  expect(shallow(Component)).toMatchSnapshot()
})

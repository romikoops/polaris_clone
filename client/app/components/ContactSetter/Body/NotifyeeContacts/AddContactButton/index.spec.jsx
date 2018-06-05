import * as React from 'react'
import { shallow } from 'enzyme'
import { identity } from '../../../../../mocks'

jest.mock('uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
// eslint-disable-next-line
import ContactSetterBodyNotifyeeContactsContactCard from './'

const propsBase = {
  onClick: identity
}

test('shallow render', () => {
  const Component = <ContactSetterBodyNotifyeeContactsContactCard {...propsBase} />

  expect(shallow(Component)).toMatchSnapshot()
})

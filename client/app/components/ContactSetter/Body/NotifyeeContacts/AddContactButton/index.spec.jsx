import * as React from 'react'
import { shallow } from 'enzyme'
import ContactSetterBodyNotifyeeContactsContactCard from '.'

const propsBase = {
  onClick: x => x
}

test('shallow render', () => {
  const Component = <ContactSetterBodyNotifyeeContactsContactCard {...propsBase} />

  expect(shallow(Component)).toMatchSnapshot()
})

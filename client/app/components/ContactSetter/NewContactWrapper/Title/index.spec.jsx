import * as React from 'react'
import { shallow } from 'enzyme'

import ContactSetterNewContactWrapperTitle from '.'

const propsBase = {
  contactType: 'FOO'
}

test('shallow render', () => {
  expect(shallow(<ContactSetterNewContactWrapperTitle {...propsBase} />)).toMatchSnapshot()
})

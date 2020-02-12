import React from 'react'
import { shallow } from 'enzyme'

import FatalError from './FatalError'

it('should shallow render without error', () => {
  expect(shallow(<FatalError error={{}} />)).toMatchSnapshot()
})

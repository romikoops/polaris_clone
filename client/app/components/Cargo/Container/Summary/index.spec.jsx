import * as React from 'react'
import { shallow } from 'enzyme'
import { firstContainer } from '../../../../mocks'

import CargoContainerSummary from '.'

test('shallow render', () => {
  const props = {
    items: [firstContainer]
  }
  expect(shallow(<CargoContainerSummary {...props} />)).toMatchSnapshot()
})
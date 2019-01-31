import * as React from 'react'
import { shallow } from 'enzyme'
import { firstCargoItem, scope } from '../../../../mocks'

import CargoItemSummary from '.'

test('shallow render', () => {
  const props = {
    items: [firstCargoItem],
    scope,
    mot: 'ocean'
  }
  expect(shallow(<CargoItemSummary {...props} />)).toMatchSnapshot()
})

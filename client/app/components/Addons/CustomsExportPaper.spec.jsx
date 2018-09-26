import * as React from 'react'
import { shallow } from 'enzyme'
import { tenant } from '../../mocks'

import CustomsExportPaper from './CustomsExportPaper'

const propsBase = {
  tenant,
  addon: {
    fees: { total: 100 }
  },
  toggleCustomAddon: jest.fn()
}

test('shallow render', () => {
  expect(shallow(<CustomsExportPaper {...propsBase} />)).toMatchSnapshot()
})

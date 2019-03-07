import * as React from 'react'
import { shallow } from 'enzyme'
import { tenant, documents } from '../../mocks/index'

import CustomsExportPaper from './CustomsExportPaper'

const propsBase = {
  addon: {
    fees: { total: 100 }
  },
  deleteDoc: false,
  documents,
  fileFn: false,
  tenant,
  toggleCustomAddon: jest.fn()
}

test('shallow render', () => {
  expect(shallow(<CustomsExportPaper {...propsBase} />)).toMatchSnapshot()
})

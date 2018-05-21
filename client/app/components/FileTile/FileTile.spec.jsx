import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'

jest.mock('isomorphic-fetch', () =>
  () => Promise.resolve({ data: [] }))
jest.mock('react-router', () => ({
  // eslint-disable-next-line react/prop-types
  Link: ({ props }) => <a {...props}>link</a>
}))
jest.mock('react-truncate', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <span>{children}</span>)
jest.mock('../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: ({ props }) => <button {...props}>click</button>
}))
jest.mock('../../helpers', () => ({
  authHeader: x => x
}))
jest.mock('../../constants', () => {
  const format = () => 19
  const add = () => ({ format })

  const moment = () => ({
    format,
    add
  })

  const documentTypes = {
    packing_sheet: 'Packing Sheet',
    commercial_invoice: 'Commercial Invoice',
    customs_declaration: 'Customs Declaration',
    customs_value_declaration: 'Customs Value Declaration',
    eori: 'EORI',
    certificate_of_origin: 'Certificate Of Origin',
    dangerous_goods: 'Dangerous Goods',
    bill_of_lading: 'Bill of Lading',
    invoice: 'Invoice',
    miscellaneous: 'Miscellaneous'
  }
  const BASE_URL = 'BASE_URL'

  return { moment, documentTypes, BASE_URL }
})
// eslint-disable-next-line
import FileTile from './FileTile'

const propsBase = {
  theme,
  type: 'FOO_TYPE',
  isAdmin: false,
  dispatchFn: identity,
  adminDispatch: {
    documentAction: identity
  },
  doc: {
    id: 9,
    approved: 'approved'
  },
  deleteFn: identity
}

test('shallow render', () => {
  expect(shallow(<FileTile {...propsBase} />)).toMatchSnapshot()
})

test('doc.approved === rejected', () => {
  const props = {
    ...propsBase,
    doc: {
      ...propsBase.doc,
      approved: 'rejected'
    }
  }
  expect(shallow(<FileTile {...props} />)).toMatchSnapshot()
})

test('doc.approved === null', () => {
  const props = {
    ...propsBase,
    doc: {
      ...propsBase.doc,
      approved: null
    }
  }
  expect(shallow(<FileTile {...props} />)).toMatchSnapshot()
})

test('isAdmin is true', () => {
  const props = {
    ...propsBase,
    isAdmin: true
  }
  expect(shallow(<FileTile {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<FileTile {...props} />)).toMatchSnapshot()
})

test('state.showDenialDetails is true', () => {
  const wrapper = shallow(<FileTile {...propsBase} />)
  wrapper.setState({ showDenialDetails: true })

  expect(wrapper).toMatchSnapshot()
})

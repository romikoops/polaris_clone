import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'

jest.mock('isomorphic-fetch', () =>
  () => Promise.resolve({ data: [] }))
jest.mock('react-router', () => ({
  // eslint-disable-next-line react/prop-types
  Link: ({ props }) => <a {...props}>link</a>
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
    packing_sheet: 'Packing List',
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
  const getTenantApiUrl = () => 'BASE_URL'

  return { moment, documentTypes, getTenantApiUrl }
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

test('doc.signed_url is truthy', () => {
  const props = {
    ...propsBase,
    doc: {
      ...propsBase.doc,
      signed_url: 'FOO_SIGNED_URL'
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

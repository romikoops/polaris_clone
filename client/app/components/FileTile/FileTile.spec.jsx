import '../../mocks/libraries/moment'
import * as React from 'react'
import { shallow } from 'enzyme'
import {
  turnFalsy, theme, identity, firstDocument
} from '../../mocks'
import FileTile from './FileTile'

const propsBase = {
  theme,
  type: 'TYPE',
  isAdmin: false,
  dispatchFn: identity,
  adminDispatch: {
    documentAction: identity
  },
  doc: firstDocument,
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
  const props = turnFalsy(
    propsBase,
    'doc.approved'
  )
  expect(shallow(<FileTile {...props} />)).toMatchSnapshot()
})

test('doc.signed_url is falsy', () => {
  const props = turnFalsy(
    propsBase,
    'doc.signed_url'
  )
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

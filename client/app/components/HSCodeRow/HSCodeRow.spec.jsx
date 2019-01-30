import * as React from 'react'
import { shallow } from 'enzyme'
import {
  change,
  cargoItems,
  containers,
  identity,
  tenant,
  theme,
  firstContainer,
  user,
  hsCodes
} from '../../mocks'

import HSCodeRow from './HSCodeRow'

const propsBase = {
  tenant,
  theme,
  user,
  hsCodes,
  setCode: identity,
  deleteCode: identity,
  containers,
  cargoItems,
  hsTexts: {},
  handleHsTextChange: identity
}
const dangerousContainer = {
  ...firstContainer,
  dangerousGoods: true
}
const dangerousProps = {
  ...propsBase,
  containers: [dangerousContainer]
}

test('shallow render', () => {
  expect(shallow(<HSCodeRow {...propsBase} />)).toMatchSnapshot()
})

test('textInputBool is false', () => {
  const props = change(
    propsBase,
    'tenant.scope.cargo_info_level',
    'foo'
  )
  expect(shallow(<HSCodeRow {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<HSCodeRow {...props} />)).toMatchSnapshot()
})

test('containers is falsy', () => {
  const props = {
    ...propsBase,
    containers: null
  }
  expect(shallow(<HSCodeRow {...props} />)).toMatchSnapshot()
})

test('cargoItems is falsy', () => {
  const props = {
    ...propsBase,
    cargoItems: null
  }
  expect(shallow(<HSCodeRow {...props} />)).toMatchSnapshot()
})

test('state.showPaste is true', () => {
  const wrapper = shallow(<HSCodeRow {...dangerousProps} />)
  wrapper.setState({ showPaste: true })

  expect(wrapper).toMatchSnapshot()
})

test('dangerousGoods is true', () => {
  expect(shallow(<HSCodeRow {...dangerousProps} />)).toMatchSnapshot()
})

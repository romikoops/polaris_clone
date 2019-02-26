import * as React from 'react'
import { shallow } from 'enzyme'
import RouteSectionForm from '.'

const propsBase = {
  carriage: true,
  childrenProps: {
    childrenPropFoo: 'childrenPropFoo',
    childrenPropBar: 'childrenPropBar'
  }
}

test('with empty props', () => {
  expect(shallow(<RouteSectionForm />)).toMatchSnapshot()
})

test('carriage is true', () => {
  expect(shallow(<RouteSectionForm {...propsBase} />)).toMatchSnapshot()
})

test('carriage is false', () => {
  const props = {
    ...propsBase,
    carriage: false
  }
  expect(shallow(<RouteSectionForm {...props} />)).toMatchSnapshot()
})

import * as React from 'react'
import { createStore } from 'redux'
import { shallow } from 'enzyme'
import ScrollTracking from "./ScrollTracking";

const propsBase = {
  type: 'PROP_TYPE'
}

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

// @ts-ignore
window.IntersectionObserver = () => ({
  observe: () => {}
})

test('shallow render', () => {
  expect(shallow(<ScrollTracking {...propsBase} />)).toMatchSnapshot()
})

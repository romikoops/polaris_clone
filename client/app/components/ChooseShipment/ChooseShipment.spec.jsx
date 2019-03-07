import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks/index'

import ChooseShipment from './ChooseShipment'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

const propsBase = {
  theme,
  messages: ['FOO', 'BAR'],
  selectLoadType: identity,
  scope: {
    modes_of_transport: []
  }
}

test('shallow render', () => {
  expect(shallow(<ChooseShipment {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<ChooseShipment {...props} />)).toMatchSnapshot()
})

test('messages.length === 0', () => {
  const props = {
    ...propsBase,
    messages: []
  }
  expect(shallow(<ChooseShipment {...props} />)).toMatchSnapshot()
})

test('state.showCargoTypes is true', () => {
  const wrapper = shallow(<ChooseShipment {...propsBase} />)
  wrapper.setState({ showCargoTypes: true })
  expect(wrapper).toMatchSnapshot()
})

test('showCargoTypes and direction are truthy', () => {
  const wrapper = shallow(<ChooseShipment {...propsBase} />)
  wrapper.setState({ showCargoTypes: true, direction: 'export' })
  expect(wrapper).toMatchSnapshot()
})

test('state.direction === export', () => {
  const wrapper = shallow(<ChooseShipment {...propsBase} />)
  wrapper.setState({ direction: 'export' })
  expect(wrapper).toMatchSnapshot()
})

test('state.direction && state.loadType', () => {
  const wrapper = shallow(<ChooseShipment {...propsBase} />)
  wrapper.setState({ direction: 'export', loadType: 'FOO_LOAD_TYPE' })

  expect(wrapper).toMatchSnapshot()
})

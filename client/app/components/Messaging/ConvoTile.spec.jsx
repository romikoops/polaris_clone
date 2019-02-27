import * as React from 'react'
import { mount, shallow } from 'enzyme'
import { theme, shipment, identity } from '../../mocks/index'

import ConvoTile from './ConvoTile'

const propsBase = {
  theme,
  viewConvo: identity,
  convoKey: 'CONVO_KEY',
  conversation: {
    messages: ['FOO_MESSAGE', 'BAR_MESSAGE']
  },
  shipment
}

const createWrapper = propsInput => mount(<ConvoTile {...propsInput} />)

test('shallow render', () => {
  expect(shallow(<ConvoTile {...propsBase} />)).toMatchSnapshot()
})

test('shipment.status === requested', () => {
  const props = {
    ...propsBase,
    shipment: {
      ...shipment,
      status: 'requested'
    }
  }
  expect(shallow(<ConvoTile {...props} />)).toMatchSnapshot()
})

test('shipment.status === confirmed', () => {
  const props = {
    ...propsBase,
    shipment: {
      ...shipment,
      status: 'confirmed'
    }
  }
  expect(shallow(<ConvoTile {...props} />)).toMatchSnapshot()
})

test('convoKey is truthy', () => {
  const props = {
    ...propsBase,
    convoKey: 'FOO_CONVO_KEY'
  }
  expect(shallow(<ConvoTile {...props} />)).toMatchSnapshot()
})

test('click calls props.viewConvo', () => {
  const props = {
    ...propsBase,
    viewConvo: jest.fn()
  }
  const wrapper = createWrapper(props)
  const clickableDiv = wrapper.find('.convo_tile_wrapper').first()

  expect(props.viewConvo).not.toHaveBeenCalled()

  clickableDiv.simulate('click')

  expect(props.viewConvo).toHaveBeenCalled()
})

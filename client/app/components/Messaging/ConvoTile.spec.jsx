import * as React from 'react'
import { mount } from 'enzyme'
import { theme, shipment } from '../../mocks'

// eslint-disable-next-line
import { ConvoTile } from './ConvoTile'

const propsBase = {
  theme,
  viewConvo: jest.fn(),
  convoKey: 'FOO_KEY',
  conversation: {
    messages: []
  },
  shipment
}

let wrapper

const createWrapper = propsInput => mount(<ConvoTile {...propsInput} />)

beforeEach(() => {
  wrapper = createWrapper(propsBase)
})

test('click calls props.viewConvo', () => {
  const clickableDiv = wrapper.find('.convo_tile_wrapper').first()

  expect(propsBase.viewConvo).not.toHaveBeenCalled()

  clickableDiv.simulate('click')

  expect(propsBase.viewConvo).toHaveBeenCalled()
})

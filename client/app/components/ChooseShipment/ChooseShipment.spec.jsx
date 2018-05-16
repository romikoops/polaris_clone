import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mocks'

jest.mock('../../helpers', () => ({
  capitalize: x => x,
  gradientTextGenerator: x => x,
  hexToRGB: x => x,
  humanizedMotAndLoadType: x => x
}))
jest.mock('../CardLinkRow/CardLinkRow', () => ({
  // eslint-disable-next-line react/prop-types
  CardLinkRow: ({ children }) => <div>{children}</div>
}))
jest.mock('../RouteResult/RouteResult', () => ({
  // eslint-disable-next-line react/prop-types
  RouteResult: ({ children }) => <div>{children}</div>
}))
jest.mock('../FlashMessages/FlashMessages', () => ({
  // eslint-disable-next-line react/prop-types
  FlashMessages: ({ children }) => <div>{children}</div>
}))
jest.mock('../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: ({ children }) => <div>{children}</div>
}))
jest.mock('../TextHeading/TextHeading', () => ({
  // eslint-disable-next-line react/prop-types
  TextHeading: ({ children }) => <h2>{children}</h2>
}))
// eslint-disable-next-line
import { ChooseShipment } from './ChooseShipment'

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

test('props.theme is falsy', () => {
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

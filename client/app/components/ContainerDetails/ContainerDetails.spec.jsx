import * as React from 'react'
import { mount } from 'enzyme'

jest.mock('../HsCodes/HsCodeViewer', () => {
  // eslint-disable-next-line react/prop-types
  const HsCodeViewer = ({ children }) => <div>{children}</div>

  return { HsCodeViewer }
})

// eslint-disable-next-line
import ContainerDetails from './ContainerDetails'

const propsBase = {
  item: {
    payload_in_kg: 134,
    size_class: 'FOO_SIZE_CLASS',
    quantity: 5
  },
  index: 3,
  hsCodes: [],
  theme: null,
  viewHSCodes: false
}

let wrapper

const createWrapper = propsInput => mount(<ContainerDetails {...propsInput} />)

beforeEach(() => {
  wrapper = createWrapper(propsBase)
})

test('props.index', () => {
  const selector = 'div[className="flex-100 layout-row"]'
  const index = wrapper.find(selector).first().text()

  expect(index.includes(propsBase.index + 1)).toBeTruthy()
})

test('props.item.payload_in_kg', () => {
  const payload = wrapper.find('.layout-align-space-between').at(0).text()

  expect(payload.includes(propsBase.item.payload_in_kg)).toBeTruthy()
})

test('props.item.quantity', () => {
  const quantity = wrapper.find('.layout-align-space-between').at(2).text()

  expect(quantity.includes(propsBase.item.quantity)).toBeTruthy()
})

test('props.viewHSCodes', () => {
  const withCodes = createWrapper({
    ...propsBase,
    viewHSCodes: true
  })

  const selector = 'i.fa-eye'
  const iconDefault = wrapper.find(selector)
  const icon = withCodes.find(selector)

  expect(iconDefault).toHaveLength(0)
  expect(icon).toHaveLength(1)
})

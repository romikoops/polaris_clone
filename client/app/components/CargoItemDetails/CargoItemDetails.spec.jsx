import * as React from 'react'
import { mount } from 'enzyme'
import { CargoItemDetails } from './CargoItemDetails'
import { theme } from '../../mocks'

const propsBase = {
  item: {
    payload_in_kg: 56,
    chargeable_weight: 60,
    dimension_x: 111,
    dimension_y: 37,
    dimension_z: 70,
    hs_codes: []
  },
  index: 1,
  viewHSCodes: false,
  theme,
  hsCodes: []
}

let wrapper

const createWrapper = propsInput => mount(<CargoItemDetails {...propsInput} />)

beforeEach(() => {
  wrapper = createWrapper(propsBase)
})

test('unit element use props.index', () => {
  const unitElement = wrapper.find('.flex-100 h4').first()

  expect(unitElement.text().includes(propsBase.index + 1)).toBeTruthy()
})

test('weight element use props.item', () => {
  const weightElement = wrapper.find('p').at(1)

  expect(weightElement.text().includes(propsBase.item.payload_in_kg)).toBeTruthy()
})

test('dimension elements use props.item', () => {
  const dimensionXElement = wrapper.find('p').at(5)
  const dimensionYElement = wrapper.find('p').at(3)
  const dimensionZElement = wrapper.find('p').at(7)

  expect(dimensionXElement.text().includes(propsBase.item.dimension_x)).toBeTruthy()
  expect(dimensionYElement.text().includes(propsBase.item.dimension_y)).toBeTruthy()
  expect(dimensionZElement.text().includes(propsBase.item.dimension_z)).toBeTruthy()
})

test('volume element use props.item', () => {
  const volumeElement = wrapper.find('p').at(9)

  expect(volumeElement.text().includes(0.15)).toBeTruthy()
})

test('chargable weight element use props.item', () => {
  const chargableWeightElement = wrapper.find('p').at(11)

  expect(chargableWeightElement.text().includes(propsBase.item.chargeable_weight)).toBeTruthy()
})

test('initial state doesn\'t include \'View Hs Codes\'', () => {
  expect(wrapper.text().includes('View Hs Codes')).toBeFalsy()
})

test('\'View Hs Codes\' depends on props.viewHSCodes', () => {
  const props = {
    ...propsBase,
    viewHSCodes: true
  }
  const dom = createWrapper(props)

  expect(dom.text().includes('View Hs Codes')).toBeTruthy()
})

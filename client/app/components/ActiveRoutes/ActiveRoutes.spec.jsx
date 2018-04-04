import * as React from 'react'
import { mount } from 'enzyme'

import { ActiveRoutes } from './ActiveRoutes'

test('has multiple div and h2', () => {
  const props = {
    text: 'foo'
  }
  const wrapper = mount(<ActiveRoutes {...props} />)

  expect(wrapper.find('div').length).toBeGreaterThan(30)
  expect(wrapper.find('h2').length).toBeGreaterThan(10)
})

test('its text content contains specific parts', () => {
  const props = {}
  const wrapper = mount(<ActiveRoutes {...props} />)
  const text = wrapper.text()

  const expectedParts = [
    'Available',
    'Destinations',
    'China'
  ]

  expectedParts.forEach((singlePart) => {
    expect(text.includes(singlePart)).toBeTruthy()
  })
})

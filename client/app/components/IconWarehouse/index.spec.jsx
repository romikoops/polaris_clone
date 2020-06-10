/* eslint-disable max-len */
import React from 'react'
import { mount } from 'enzyme'
import IconWarehouse from './index'

let wrapper

beforeAll(() => {
  wrapper = mount(<IconWarehouse className="nice" />)
})

it('renders without problems', () => {
  expect(wrapper).toMatchSnapshot()
})

it('renders the className', () => {
  expect(wrapper.exists('.nice')).toBeTruthy()
})

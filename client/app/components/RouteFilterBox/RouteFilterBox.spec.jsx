import * as React from 'react'
import { shallow } from 'enzyme'
import { identity, theme } from '../../mocks'

jest.mock('../../helpers', () => ({
  switchIcon: x => x,
  capitalize: x => x.toUpperCase()
}))
jest.mock('../../constants', () => {
  const format = () => 19
  const add = () => ({ format })

  const moment = () => ({
    format,
    add
  })

  return { moment }
})
// eslint-disable-next-line import/first
import RouteFilterBox from './RouteFilterBox'

const propsBase = {
  departureDate: 0,
  theme,
  setDurationFilter: identity,
  setMoT: identity,
  setDepartureDate: identity,
  durationFilter: 1,
  pickup: true,
  shipment: {}
}

let originalDate
const constantDate = new Date('2017-06-13T04:41:20')
beforeEach(() => {
  originalDate = Date
  Date = class extends Date {
    constructor () {
      return constantDate
    }
  }
})

afterEach(() => {
  Date = originalDate
})

test.skip('shallow rendering', () => {
  expect(shallow(<RouteFilterBox {...propsBase} />)).toMatchSnapshot()
})

test.skip('pickup is false', () => {
  const props = {
    ...propsBase,
    pickup: false
  }
  expect(shallow(<RouteFilterBox {...props} />)).toMatchSnapshot()
})

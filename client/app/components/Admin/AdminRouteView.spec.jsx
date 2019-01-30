import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, hub } from '../../mock'

import AdminRouteView from './AdminRouteView'

jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})
jest.mock('../../helpers', () => ({
  gradientTextGenerator: x => x
}))
jest.mock('../../constants', () => {
  const format = () => 19
  const subtract = () => ({ format })
  const add = () => ({ format })

  const moment = () => ({
    format,
    subtract,
    add
  })

  return { moment }
})

const propsBase = {
  theme,
  hubHash: {},
  adminDispatch: {
    getHub: identity,
    getLayovers: identity,
    deleteItineraryNote: identity
  },
  itineraryData: {
    hubs: [hub],
    schedules: {},
    notes: {},
    itinerary: {
      name: 'NAME'
    }
  }
}

test('shallow render', () => {
  expect(shallow(<AdminRouteView {...propsBase} />)).toMatchSnapshot()
})

test('state.editNotes is true', () => {
  const wrapper = shallow(<AdminRouteView {...propsBase} />)
  wrapper.setState({ editNotes: true })
  expect(wrapper).toMatchSnapshot()
})

test('state.confirm is true', () => {
  const wrapper = shallow(<AdminRouteView {...propsBase} />)
  wrapper.setState({ confirm: true })
  expect(wrapper).toMatchSnapshot()
})

test('itineraryData is falsy', () => {
  const props = {
    ...propsBase,
    itineraryData: null
  }
  expect(shallow(<AdminRouteView {...props} />)).toMatchSnapshot()
})

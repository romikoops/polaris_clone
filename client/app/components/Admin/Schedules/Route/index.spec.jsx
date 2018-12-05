import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity, hub } from '../../../../mocks'

import AdminSchedulesRoute from '.'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
jest.mock('../../../../actions', () => ({
  documentActions: x => x
}))
jest.mock('../../../../helpers', () => ({
  gradientCSSGenerator: x => x,
  gradientBorderGenerator: x => x
}))

jest.mock('../../../../constants', () => {
  const format = () => 11
  const add = () => ({ format })

  const moment = () => ({
    format,
    add
  })

  return {
    moment
  }
})

const propsBase = {
  theme,
  hubs: [hub],
  scheduleData: {
    itinerary: {
      id: 1
    },
    routes: [],
    schedules: [],
    detailedItineraries: [],
    itineraryIds: [],
    itineraries: {}
  },
  itineraries: {},
  adminDispatch: identity,
  setCurrentUrl: identity,
  limit: 0,
  document: {
    viewer: {}
  },
  documentDispatch: identity
}

test('shallow render', () => {
  expect(shallow(<AdminSchedulesRoute {...propsBase} />)).toMatchSnapshot()
})

test('scheduleData is falsy', () => {
  const props = {
    ...propsBase,
    scheduleData: null
  }
  expect(shallow(<AdminSchedulesRoute {...props} />)).toMatchSnapshot()
})

test('document.viewer is falsy', () => {
  const props = {
    ...propsBase,
    document: {}
  }
  expect(shallow(<AdminSchedulesRoute {...props} />)).toMatchSnapshot()
})

test('state.showList is false', () => {
  const wrapper = shallow(<AdminSchedulesRoute {...propsBase} />)
  wrapper.setState({ showList: false })

  expect(wrapper).toMatchSnapshot()
})

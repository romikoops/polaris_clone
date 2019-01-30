import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mock'

import AdminPriceCreator from './AdminPriceCreator'

const stepsBase = {
  cargoClass: false,
  route: false,
  hubRoute: false,
  transportCategory: false,
  pricing: false,
  client: false
}

const propsBase = {
  theme,
  closeForm: identity,
  adminDispatch: {},
  itineraries: [],
  transportCategories: [],
  detailedItineraries: [],
  clients: []
}

test('shallow render', () => {
  expect(shallow(<AdminPriceCreator {...propsBase} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminPriceCreator {...propsBase} />)).toMatchSnapshot()
})

test('state.client is true', () => {
  const wrapper = shallow(<AdminPriceCreator {...propsBase} />)
  wrapper.setState({ client: true })

  expect(wrapper).toMatchSnapshot()
})

test('steps.cargoClass is true', () => {
  const wrapper = shallow(<AdminPriceCreator {...propsBase} />)
  wrapper.setState({
    steps: {
      ...stepsBase,
      cargoClass: true
    }
  })

  expect(wrapper).toMatchSnapshot()
})

test('steps.transportCategory is true', () => {
  const wrapper = shallow(<AdminPriceCreator {...propsBase} />)
  wrapper.setState({
    steps: {
      ...stepsBase,
      transportCategory: true
    }
  })

  expect(wrapper).toMatchSnapshot()
})

test('steps.route is true', () => {
  const wrapper = shallow(<AdminPriceCreator {...propsBase} />)
  wrapper.setState({
    steps: {
      ...stepsBase,
      route: true
    }
  })

  expect(wrapper).toMatchSnapshot()
})

test('steps.hubRoute is true', () => {
  const wrapper = shallow(<AdminPriceCreator {...propsBase} />)
  wrapper.setState({
    steps: {
      ...stepsBase,
      hubRoute: true
    }
  })

  expect(wrapper).toMatchSnapshot()
})

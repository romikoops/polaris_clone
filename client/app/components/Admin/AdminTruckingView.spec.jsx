import * as React from 'react'
import { shallow } from 'enzyme'
import { hub, theme, identity } from '../../mocks'

import AdminTruckingView from './AdminTruckingView'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

jest.mock('../../helpers', () => ({
  history: x => x,
  capitalize: x => x,
  nameToDisplay: x => x,
  switchIcon: x => x,
  gradientGenerator: x => x,
  renderHubType: x => x
}))
jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const propsBase = {
  theme,
  adminDispatch: {
    uploadTrucking: identity
  },
  truckingDetail: {
    hub,
    truckingHub: {},
    truckingPricings: [],
    pricing: {}
  },
  document: {},
  documentDispatch: {}
}

test('shallow render', () => {
  expect(shallow(<AdminTruckingView {...propsBase} />)).toMatchSnapshot()
})

test('truckingDetail is falsy', () => {
  const props = {
    ...propsBase,
    truckingDetail: null
  }
  expect(shallow(<AdminTruckingView {...props} />)).toMatchSnapshot()
})

test('document.viewer is true', () => {
  const props = {
    ...propsBase,
    document: {
      viewer: true
    }
  }
  expect(shallow(<AdminTruckingView {...props} />)).toMatchSnapshot()
})

test('idenitfierKey === distance', () => {
  const wrapper = shallow(<AdminTruckingView {...propsBase} />)
  wrapper.setState({
    loadTypeBool: true,
    filteredTruckingPricings: [
      { distance: [], truckingPricing: {} }
    ]
  })
  expect(wrapper).toMatchSnapshot()
})

test('idenitfierKey !== distance', () => {
  const wrapper = shallow(<AdminTruckingView {...propsBase} />)
  wrapper.setState({
    loadTypeBool: true,
    filteredTruckingPricings: [
      { truckingPricing: {} }
    ]
  })
  expect(wrapper).toMatchSnapshot()
})

test('filteredTruckingPricings is truthy while loadTypeBool is false ', () => {
  const wrapper = shallow(<AdminTruckingView {...propsBase} />)
  wrapper.setState({
    loadTypeBool: false,
    filteredTruckingPricings: [
      { truckingPricing: {} }
    ]
  })
  expect(wrapper).toMatchSnapshot()
})

test('state.currentTruckingPricing is true', () => {
  const wrapper = shallow(<AdminTruckingView {...propsBase} />)
  wrapper.setState({ currentTruckingPricing: true })
  expect(wrapper).toMatchSnapshot()
})

test('state.loadTypeBool is false', () => {
  const wrapper = shallow(<AdminTruckingView {...propsBase} />)
  wrapper.setState({ loadTypeBool: false })
  expect(wrapper).toMatchSnapshot()
})

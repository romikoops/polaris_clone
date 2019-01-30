import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mock'
import AdminPricings from './AdminPricings'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))

const propsBase = {
  theme,
  adminDispatch: {
    getPricings: identity
  },
  match: { url: 'URL' },
  setCurrentUrl: identity,
  document: { viewer: {} },
  trucking: { nexuses: {} },
  hubs: [],
  loading: false,
  pricingData: null,
  hubHash: {},
  clients: [],
  itineraries: [],
  tenant: null,
  truckingDetail: null
}

test('shallow render', () => {
  expect(shallow(<AdminPricings {...propsBase} />)).toMatchSnapshot()
})

test('{itineraries || pricingData.itineraries', () => {
  const props = {
    ...propsBase,
    itineraries: null,
    pricingData: { itineraries: [{}] }
  }
  expect(shallow(<AdminPricings {...props} />)).toMatchSnapshot()
})

test('document.viewer is falsy', () => {
  const props = {
    ...propsBase,
    document: {}
  }
  expect(shallow(<AdminPricings {...props} />)).toMatchSnapshot()
})

test('state.selectedPricing is true', () => {
  const wrapper = shallow(<AdminPricings {...propsBase} />)
  wrapper.setState({ selectedPricing: true })

  expect(wrapper).toMatchSnapshot()
})

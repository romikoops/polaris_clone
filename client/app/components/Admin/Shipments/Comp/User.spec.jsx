import * as React from 'react'
import { shallow } from 'enzyme'
import { theme } from '../../../../mock'

import ShipmentsCompUser from './User'

jest.mock('react-redux', () => ({
  connect: (mapStateToProps, mapDispatchToProps) => Component => Component
}))
jest.mock('../../../../helpers', () => ({
  filters: { sortByDate: x => x, sortByAlphabet: x => x },
  capitalize: x => x,
  loadOriginNexus: x => x,
  loadDestinationNexus: x => x,
  loadMot: x => x
}))

const propsBase = {
  theme,
  hubs: [{}],
  shipments: { pages: {}, nexuses: {} },
  clients: [{}],
  user: {},
  userDispatch: {
    getShipments: () => []
  },
  numShipmentsPages: 1
}

test('shallow render', () => {
  expect(shallow(<ShipmentsCompUser {...propsBase} />)).toMatchSnapshot()
})

test('hubs is falsy', () => {
  const props = {
    ...propsBase,
    hubs: null
  }
  expect(shallow(<ShipmentsCompUser {...props} />)).toMatchSnapshot()
})

test('shipments.pages is truthy', () => {
  const props = {
    ...propsBase,
    shipments: {
      quoted: [],
      pages: {
        quoted: 'QUOTED'
      }
    }
  }

  const wrapper = shallow(<ShipmentsCompUser {...props} />)
  expect(wrapper).toMatchSnapshot()
})

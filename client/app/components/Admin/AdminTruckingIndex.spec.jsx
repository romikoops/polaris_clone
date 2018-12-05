import * as React from 'react'
import { shallow } from 'enzyme'
import { hub, identity } from '../../mocks'

import AdminTruckingIndex from './AdminTruckingIndex'

const hubBase = {
  ...hub,
  data: {
    hub_type: 'HUB_TYPE'
  }
}

const propsBase = {
  viewTrucking: identity,
  loading: false,
  hubs: [hubBase],
  adminDispatch: {
    getTrucking: identity
  },
  truckingNexuses: [{
    _id: 7
  }]
}

test('shallow render', () => {
  expect(shallow(<AdminTruckingIndex {...propsBase} />)).toMatchSnapshot()
})

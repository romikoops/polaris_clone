import * as React from 'react'
import { shallow } from 'enzyme'
import { hub, theme, identity } from '../../mock'

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
    hub
  },
  document: {},
  documentDispatch: {}
}

test('shallow render', () => {
  expect(shallow(<AdminTruckingView {...propsBase} />)).toMatchSnapshot()
})


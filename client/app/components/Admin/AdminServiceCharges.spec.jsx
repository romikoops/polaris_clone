import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, identity } from '../../mock'

import AdminServiceCharges from './AdminServiceCharges'

jest.mock('../../components/FileUploader/FileUploader', () => ({
  FileUploader: () => <div />
}))
jest.mock('./AdminChargePanel', () => ({
  AdminChargePanel: () => <div />
}))
jest.mock('./Hubs/AdminHubTile', () => ({
  AdminHubTile: () => <div />
}))
jest.mock('uuid', () => {
  let counter = -1
  const v4 = () => {
    counter += 1

    return `RANDOM_KEY_${counter}`
  }

  return { v4 }
})

const hub = {
  data: {
    name: 'FOO_NAME',
    hub_code: 'FOO_HUB_CODE'
  },
  name: 'FOO_HUB_NAME'
}

const secondHub = {
  data: {
    name: 'BAR_NAME',
    hub_code: 'BAR_HUB_CODE'
  },
  name: 'BAR_HUB_NAME'
}

const propsBase = {
  theme,
  hubs: [hub, secondHub],
  charges: [{}],
  adminTools: {
    updateServiceCharge: identity
  }
}

test('shallow render', () => {
  expect(shallow(<AdminServiceCharges {...propsBase} />)).toMatchSnapshot()
})

test('state.selectedHub is true', () => {
  const wrapper = shallow(<AdminServiceCharges {...propsBase} />)
  wrapper.setState({ selectedHub: true })
  expect(wrapper).toMatchSnapshot()
})

test('hubs is falsy', () => {
  const props = {
    ...propsBase,
    hubs: null
  }
  expect(shallow(<AdminServiceCharges {...props} />)).toMatchSnapshot()
})

test('theme is falsy', () => {
  const props = {
    ...propsBase,
    theme: null
  }
  expect(shallow(<AdminServiceCharges {...props} />)).toMatchSnapshot()
})

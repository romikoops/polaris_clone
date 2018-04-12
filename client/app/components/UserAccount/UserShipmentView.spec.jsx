import * as React from 'react'
import { shallow, mount } from 'enzyme'
import { theme, identity, shipmentData, tenant, user, match } from '../../mocks'

jest.mock('react-select', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <div>{children}</div>)
jest.mock('node-uuid', () => ({
  v4: () => 'RANDOM_KEY'
}))
jest.mock('../../constants', () => {
  const moment = input => ({
    format: () => input,
    diff: () => input
  })
  const documentTypes = x => x

  return { moment, documentTypes }
})
jest.mock('../Cargo/Item/Group', () => ({
  // eslint-disable-next-line react/prop-types
  CargoItemGroup: ({ children }) => <div>{children}</div>
}))
jest.mock('../Cargo/Item/Group/Aggregated', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <div>{children}</div>)
jest.mock('../FileUploader/FileUploader', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <div>{children}</div>)
jest.mock('../FileTile/FileTile', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <div>{children}</div>)
jest.mock('../ShipmentCard/ShipmentCard', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <div>{children}</div>)
jest.mock('../Cargo/Container/Group', () => ({
  // eslint-disable-next-line react/prop-types
  CargoContainerGroup: ({ children }) => <div>{children}</div>
}))
jest.mock('../RouteHubBox/RouteHubBox', () => ({
  // eslint-disable-next-line react/prop-types
  RouteHubBox: ({ children }) => <div>{children}</div>
}))
jest.mock('../TextHeading/TextHeading', () => ({
  // eslint-disable-next-line react/prop-types
  TextHeading: ({ children }) => <div>{children}</div>
}))
jest.mock('../Incoterm/Row', () => ({
  // eslint-disable-next-line react/prop-types
  IncotermRow: ({ children }) => <div>{children}</div>
}))
jest.mock('../RoundButton/RoundButton', () => ({
  // eslint-disable-next-line react/prop-types
  RoundButton: ({ props }) => <button {...props} />
}))
jest.mock('../../helpers', () => ({
  capitalize: x => x,
  gradientTextGenerator: x => x
}))

// eslint-disable-next-line import/first
import { UserShipmentView } from './UserShipmentView'

const createWrapper = propsInput => mount(<UserShipmentView {...propsInput} />)

const propsBase = {
  theme,
  hubs: [],
  loading: false,
  shipmentData,
  user,
  userDispatch: {
    deleteDocument: identity
  },
  match,
  setNav: identity,
  tenant
}

test('shallow render', () => {
  expect(shallow(<UserShipmentView {...propsBase} />)).toMatchSnapshot()
})

test('props.loading is true', () => {
  const props = {
    ...propsBase,
    loading: true
  }
  expect(shallow(<UserShipmentView {...props} />)).toMatchSnapshot()
})

test('props.setNav is called', () => {
  const props = {
    ...propsBase,
    setNav: jest.fn()
  }

  createWrapper(props)
  expect(props.setNav).toHaveBeenCalled()
})

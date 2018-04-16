import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, shipmentData, identity } from '../../mocks'

jest.mock('react-tooltip', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <h2>{children}</h2>)
jest.mock('../FormsyInput/FormsyInput', () =>
  // eslint-disable-next-line react/prop-types
  ({ props }) => <input {...props} />)
jest.mock('../Documents/Form', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <div>{children}</div>)
jest.mock('../Documents/MultiForm', () =>
  // eslint-disable-next-line react/prop-types
  ({ children }) => <div>{children}</div>)
jest.mock('../Checkbox/Checkbox', () => ({
  // eslint-disable-next-line react/prop-types
  Checkbox: ({ children }) => <div>{children}</div>
}))
jest.mock('../TextHeading/TextHeading', () => ({
  // eslint-disable-next-line react/prop-types
  TextHeading: ({ children }) => <h2>{children}</h2>
}))
jest.mock('../NamedSelect/NamedSelect', () => ({
  // eslint-disable-next-line react/prop-types
  NamedSelect: ({ children }) => <div>{children}</div>
}))
jest.mock('../Tooltip/Tooltip', () => ({
  // eslint-disable-next-line react/prop-types
  Tooltip: ({ children }) => <div>{children}</div>
}))
jest.mock('../../helpers', () => ({
  // eslint-disable-next-line react/prop-types
  converter: x => x
}))
// eslint-disable-next-line import/first
import { CargoDetails } from './CargoDetails'

const editedShipmentData = {
  ...shipmentData,
  customs: {
    total: {
      total: {
        currency: 'EUR'
      }
    },
    import: {
      total: {
        currency: 'EUR'
      }
    },
    export: {
      total: {
        currency: 'EUR',
        value: 100
      }
    }
  }
}

const propsBase = {
  theme,
  tenant: {
    data: {
      scope: {}
    }
  },
  shipmentData: editedShipmentData,
  handleChange: identity,
  handleInsurance: identity,
  cargoNotes: 'FOO_CARGO_NOTES',
  totalGoodsValue: 11,
  insurance: {
    val: 'FOO_INSURANCE',
    bool: true
  },
  customsData: {
    val: 'FOO_CUSTOM_DATA',
    import: {
      bool: true,
      total: {
        currency: 'USD'
      }
    },
    export: {
      bool: true
    }
  },
  setCustomsFee: identity,
  shipmentDispatch: {
    deleteDocument: identity,
    uploadDocument: identity
  },
  currencies: [{
    key: 'FOO_CURRENCIES_KEY',
    rate: 6
  }],
  hsCodes: [],
  finishBookingAttempted: false,
  hsTexts: {},
  handleTotalGoodsCurrency: identity,
  eori: 'FOO_EORI',
  notes: 'FOO_NOTEST',
  incoterm: 'FOO_INCOTERM'
}

test('', () => {
  expect(shallow(<CargoDetails {...propsBase} />)).toMatchSnapshot()
})

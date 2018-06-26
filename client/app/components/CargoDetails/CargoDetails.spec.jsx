import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, shipmentData, identity } from '../../mocks'

/**
 * ISSUE
 * `totalGoodsValue: PropTypes.number.isRequired,` is wrong
 */

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
  totalGoodsValue: { value: 11 },
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
  notes: 'FOO_NOTES',
  incoterm: 'FOO_INCOTERM'
}

test('shallow render', () => {
  expect(shallow(<CargoDetails {...propsBase} />)).toMatchSnapshot()
})

test('totalGoodsValue.value > 20000', () => {
  const props = {
    ...propsBase,
    totalGoodsValue: { value: 20001 }
  }

  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

test('shipmentData.dangerousGoods is true', () => {
  const props = {
    ...propsBase,
    shipmentData: {
      ...editedShipmentData,
      dangerousGoods: true
    }
  }
  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

test('tenant.data.scope.has_insurance is true', () => {
  const tenant = {
    data: {
      scope: {
        has_insurance: true
      }
    }
  }
  const props = {
    ...propsBase,
    tenant
  }
  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

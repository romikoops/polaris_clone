import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, shipmentData, identity, change } from '../../mocks'

jest.mock('../../helpers', () => ({
  // eslint-disable-next-line react/prop-types
  converter: x => x
}))
// eslint-disable-next-line
import CargoDetails from './CargoDetails'

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

const customsDataBase = {
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
}

const propsBase = {
  theme,
  tenant: {
    scope: {}
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
  customsData: customsDataBase,
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

test('scope.has_customs || scope.has_insurance', () => {
  const changeData = {
    shipmentData: {
      addons: {
        customs_export_paper: true
      }
    },
    tenant: {
      scope: {
        has_insurance: true,
        has_customs: true,
        customs_export_paper: true
      }
    }
  }
  const props = change(
    {
      ...propsBase,
      insurance: { bool: null }
    },
    '',
    changeData
  )

  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

test('shipment.has_pre_carriage ?', () => {
  const changeData = {
    has_pre_carriage: true,
    has_on_carriage: true
  }
  const props = change(
    propsBase,
    'shipmentData.shipment',
    changeData
  )
  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

test('this.props.insurance.bool ?', () => {
  const props = {
    ...propsBase,
    insurance: {
      bool: false
    }
  }
  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

test('customsData[target].unknown', () => {
  const props = {
    ...propsBase,
    customsData: {
      import: { unknown: true },
      export: {}
    }
  }
  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

test('fee && !fee.unknown && fee.total.value', () => {
  const changeData = {
    import: {
      unknown: false
    },
    export: {
      unknown: false
    }
  }
  const props = change(
    propsBase,
    'shipmentData.customs',
    changeData
  )
  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

test('customs.import.unknown && customs.export.unknown', () => {
  const changeData = {
    import: {
      unknown: true
    },
    export: {
      unknown: true
    }
  }
  const props = change(
    propsBase,
    'shipmentData.customs',
    changeData
  )
  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

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

test('tenant.scope.has_insurance is true', () => {
  const tenant = {
    scope: {
      has_insurance: true
    }
  }
  const props = {
    ...propsBase,
    tenant
  }

  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

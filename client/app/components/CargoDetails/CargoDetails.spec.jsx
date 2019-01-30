import * as React from 'react'
import { shallow } from 'enzyme'
import {
  change,
  currencies,
  identity,
  shipmentData,
  tenant,
  theme,
  turnFalsy
} from '../../mocks'

import CargoDetails from './CargoDetails'

const customsData = {
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
  tenant,
  shipmentData,
  handleChange: identity,
  handleInsurance: identity,
  cargoNotes: 'CARGO_NOTES',
  totalGoodsValue: { value: 11 },
  insurance: {
    val: 'INSURANCE',
    bool: true
  },
  customsData,
  setCustomsFee: identity,
  shipmentDispatch: {
    deleteDocument: identity,
    uploadDocument: identity
  },
  currencies,
  hsCodes: [],
  finishBookingAttempted: false,
  hsTexts: {},
  handleTotalGoodsCurrency: identity,
  eori: 'EORI',
  notes: 'NOTES',
  incoterm: 'INCOTERM'
}

test('shallow render', () => {
  expect(shallow(<CargoDetails {...propsBase} />)).toMatchSnapshot()
})

test('state.customsView is true', () => {
  const wrapper = shallow(<CargoDetails {...propsBase} />)
  wrapper.setState({ customsView: true })
  expect(wrapper).toMatchSnapshot()
})

test('state.showModal is true', () => {
  const wrapper = shallow(<CargoDetails {...propsBase} />)
  wrapper.setState({ showModal: true })
  expect(wrapper).toMatchSnapshot()
})

test('state.insuranceView is false', () => {
  const wrapper = shallow(<CargoDetails {...propsBase} />)
  wrapper.setState({ insuranceView: true })
  expect(wrapper).toMatchSnapshot()
})

test('scope.has_customs || scope.has_insurance', () => {
  const props = {
    ...propsBase,
    insurance: { bool: null }
  }

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

test('totalGoodsValue.value > 20000', () => {
  const props = {
    ...propsBase,
    totalGoodsValue: { value: 20001 }
  }

  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

test('shipmentData.dangerousGoods is true', () => {
  const props = change(
    propsBase,
    'shipmentData.dangerousGoods',
    true
  )
  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

test('tenant.scope.has_insurance is false', () => {
  const props = change(
    propsBase,
    'tenant.scope.has_insurance',
    false
  )

  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

test('tenant.scope.has_customs is false', () => {
  const props = change(
    propsBase,
    'tenant.scope.has_customs',
    false
  )

  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

test('tenant.scope.customs_export_paper is false', () => {
  const props = change(
    propsBase,
    'tenant.scope.customs_export_paper',
    false
  )

  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

test('scope.has_customs || scope.has_insurance || scope.customs_export_paper is false', () => {
  const props = change(
    propsBase,
    'tenant.scope',
    {
      has_customs: false,
      has_insurance: false,
      customs_export_paper: false
    }
  )

  expect(shallow(<CargoDetails {...props} />)).toMatchSnapshot()
})

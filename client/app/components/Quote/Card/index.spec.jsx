import * as React from 'react'
import { shallow } from 'enzyme'
import {
  change,
  firstCargoItem,
  identity,
  tenant,
  shipment,
  selectedOffer,
  theme
} from '../../../mocks/index'

import QuoteCard from './index'

const propsBase = {
  theme,
  tenant,
  identity,
  loggedIn: true,
  truckingTime: 22,
  result: {
    meta: {
      origin_hub: {
        name: 'Gothenburg'
      },
      destination_hub: {
        name: 'Shanghai'
      },
      pricing_range_data: {
        fcl_20: {
          valid_until: '2019-12-31T00:00:00.000Z'
        },
      },
      validUntil: '2019-12-31T00:00:00.000Z'
    },
    quote: selectedOffer,
    schedules: [{ eta: '10-8-2018', closing_date: '10-8-2018', etd: '10-8-2018' }],
    notes: []
  },
  shipment,
  cargo: [],
  pickup: true,
  aggregatedCargo: firstCargoItem,
  onClickAdd: () => {},
  onScheduleRequest: () => {}
}

const newProps = {
  ...propsBase,
  tenant: {
    id: 123,
    scope: {
      detailed_billing: true,
      modes_of_transport: {
        ocean: {
          OCEAN_LOAD_TYPE: true
        },
        air: {},
        truck: {},
        rail: {}
      },
      closed_quotation_tool: true
    },
    theme,
    subdomain: 'foosubdomain'
  }
}

test('shallow rendering', () => {
  expect(shallow(<QuoteCard {...propsBase} />)).toMatchSnapshot()
})

test('single result rendering removes add button', () => {
  const props = {
    ...propsBase,
    onClickAdd: null
  }
  expect(shallow(<QuoteCard {...props} />)).toMatchSnapshot()
})

test('aggregatedCargo is empty object', () => {
  const props = {
    ...propsBase,
    aggregatedCargo: {}
  }
  expect(shallow(<QuoteCard {...props} />)).toMatchSnapshot()
})

test('tenant.scope is empty object', () => {
  const props = change(
    propsBase,
    'tenant.scope',
    {}
  )
  expect(shallow(<QuoteCard {...props} />)).toMatchSnapshot()
})

test.skip('it hides the grand total with multiple currencies', () => {
  const shallowTest = shallow(<QuoteCard {...propsBase} />)
  const instance = shallowTest.instance();
  const shouldShowGrandTotal = instance.shouldHideGrandTotal()
  expect(shouldShowGrandTotal).toBe(false)
})

test.skip('it shows the grand total with one currency', () => {
  const singleCurrencyProps = {
    ...propsBase,
    result: {
      ...propsBase.result,
      quote: {
        ...propsBase.result.quote,
        export: {
          total: { value: 0.11152e3, currency: 'GBP' },
          edited_total: null,
          name: 'Export',
          ams: { value: 0.18e3, currency: 'GBP', name: 'AMS ENS ACI' },
          bkn: { value: 0.19e3, currency: 'GBP', name: 'CFS' },
          doc: { value: 0.35e3, currency: 'GBP', name: 'Documentation' },
          tel: { value: 0.15e3, currency: 'GBP', name: 'TELEX' },
          vgm: { value: 0.105e3, currency: 'GBP', name: 'VGM' }
        }
      }
    }
  }
  const shallowTest = shallow(<QuoteCard {...singleCurrencyProps} />)
  const instance = shallowTest.instance();
  const shouldShowGrandTotal = instance.shouldHideGrandTotal()
  expect(shouldShowGrandTotal).toBe(false)
})

const newShallow = shallow(<QuoteCard {...newProps} />)

test('detailed billing working properly', () => {
  expect(newShallow).toMatchSnapshot()
})


test('show schedule options working', () => {
  newShallow.setState({ showSchedules: true })
  expect(newShallow).toMatchSnapshot()
})

test('validUntil is truthy', () => {
  const wrapper = shallow(<QuoteCard {...propsBase} />)
  
  expect(wrapper).toMatchSnapshot()
})

test('validUntil is falsy', () => {
  const props = change(propsBase, 'results.meta.pricing_rate_data', null)
  
  expect(shallow(<QuoteCard {...props} />)).toMatchSnapshot()
})
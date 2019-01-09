import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, tenant, identity, selectedOffer } from '../../../mocks'

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
      }
    },
    quote: selectedOffer,
    schedules: [{ eta: '10-8-2018', closing_date: '10-8-2018', etd: '10-8-2018' }]
  },
  cargo: [],
  pickup: true,
  aggregatedCargo: {},
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

test('single result rendering removes the "add" button', () => {
  const { onClickAdd, ...otherProps } = propsBase

  expect(shallow(<QuoteCard {...otherProps} />)).toMatchSnapshot()
})

const shallowTest = shallow(<QuoteCard {...propsBase} />)

test('shallow rendering', () => {
  expect(shallowTest).toMatchSnapshot()
})

test('show schedules set to true', () => {
  shallowTest.setState({ showSchedules: true })
  expect(shallowTest).toMatchSnapshot()
})

const newShallow = shallow(<QuoteCard {...newProps} />)

test('detailed billing working properly', () => {
  expect(newShallow).toMatchSnapshot()
})

test('it hides the grand total with multiple currencies', () => {
  const shallowTest = shallow(<QuoteCard {...propsBase} />)
  const instance = shallowTest.instance();
  const shouldShowGrandTotal = instance.shouldHideGrandTotal()
  expect(shouldShowGrandTotal).toBe(false)
})

test('it shows the grand total with one currency', () => {
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

test('show schedule options working', () => {
  newShallow.setState({ showSchedules: true })
  expect(newShallow).toMatchSnapshot()
})


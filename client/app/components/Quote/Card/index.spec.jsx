import * as React from 'react'
import { shallow } from 'enzyme'
import { theme, tenant, identity } from '../../../mocks'

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
    quote: {
      total: {
        value: 100,
        currency: 'EUR'
      }
    },
    schedules: [{ eta: '10-8-2018', closing_date: '10-8-2018', etd: '10-8-2018' }]
  },
  cargo: [],
  pickup: true,
  aggregatedCargo: {}
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

test('show schedule options working', () => {
  newShallow.setState({ showSchedules: true })
  expect(newShallow).toMatchSnapshot()
})

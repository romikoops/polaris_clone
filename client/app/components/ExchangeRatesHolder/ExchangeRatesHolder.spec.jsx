import React from 'react'
import { shallow, mount } from 'enzyme'
import ExchangeRatesHolder from './ExchangeRatesHolder'
import { eurUsdExchangeRate } from '../../mocks/currencies'

const defaultProps = {
  exchangeRates: [eurUsdExchangeRate]
}

describe('ExchangeRatesHolder', () => {
  let wrapper
  describe('Context: shallow rendering', () => {
    beforeEach(() => {
      wrapper = shallow(<ExchangeRatesHolder {...defaultProps} />)
    })

    it('should render without any errors', () => {
      expect(wrapper).toMatchSnapshot()
    })
  })

  describe('Context: deep rendering', () => {
    beforeEach(() => {
      wrapper = mount(<ExchangeRatesHolder {...defaultProps} />)
    })

    it('should render the formatted exchange rates', () => {
      const keys = Object.keys(eurUsdExchangeRate)
      const targetCurrency = keys[keys.length - 1]
      const expectedRate = `1 ${eurUsdExchangeRate.base.toUpperCase()} = ${
        eurUsdExchangeRate[targetCurrency]
      } ${targetCurrency.toUpperCase()}`
      const identifier = `${eurUsdExchangeRate.base.toUpperCase()}-${targetCurrency.toUpperCase()}`
      expect(wrapper.find(`#${identifier}`).text().includes(expectedRate)).toBe(true)
    })
  })
})

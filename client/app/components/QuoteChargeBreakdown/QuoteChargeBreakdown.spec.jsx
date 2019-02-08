
import React from 'react'
import { shallow, configure } from 'enzyme'
import QuoteChargeBreakdown from './QuoteChargeBreakdown'
import { selectedOffer, cargoItems } from '../../mocks'

describe('correctly determines whether to display subtotals based on currencies charged', () => {
  

  it('should render the total', () => {
    const wrapper = shallow(<QuoteChargeBreakdown quote={selectedOffer} scope={{}} cargo={cargoItems}/>);
    const instance = wrapper.instance();
    const key = 'cargo'
    const quote = selectedOffer
    const contentSections = Object.entries(quote[key])
    .map(array => array.filter(value => !instance.unbreakableKeys.includes(value)))
    .filter(value => value.length !== 1)
    const currencySections = {}
    const currencyTotals = {}
    contentSections.forEach((price) => {
      const { currency, value, overridePrice } = instance.dynamicValueExtractor(key, price)
  
      if (value && currency) {
        if (!currencySections[currency]) {
          currencySections[currency] = []
        }
        if (!currencyTotals[currency]) {
          currencyTotals[currency] = 0.0
        }
        currencyTotals[currency] += parseFloat(value)
        currencySections[currency].push(overridePrice)
      }
      const showSubTotal = QuoteChargeBreakdown.shouldShowSubTotal(currencySections)
      expect(showSubTotal).toBe(true)
    })

  })
  it('should not render the total due to scope', () => {
    const wrapper = shallow(<QuoteChargeBreakdown quote={selectedOffer} scope={{hide_sub_totals: true}} cargo={cargoItems}/>);
    const instance = wrapper.instance();
    const key = 'cargo'
    const quote = selectedOffer
    const contentSections = Object.entries(quote[key])
    .map(array => array.filter(value => !instance.unbreakableKeys.includes(value)))
    .filter(value => value.length !== 1)
    const currencySections = {}
    const currencyTotals = {}
    contentSections.forEach((price) => {
      const { currency, value, overridePrice } = instance.dynamicValueExtractor(key, price)
  
      if (value && currency) {
        if (!currencySections[currency]) {
          currencySections[currency] = []
        }
        if (!currencyTotals[currency]) {
          currencyTotals[currency] = 0.0
        }
        currencyTotals[currency] += parseFloat(value)
        currencySections[currency].push(overridePrice)
      }
      const showSubTotal = QuoteChargeBreakdown.shouldShowSubTotal(currencySections)
      expect(showSubTotal).toBe(true)
    })
 
  })
  
  it('should not render the total due to multiple currencies', () => {
    const wrapper = shallow(<QuoteChargeBreakdown quote={selectedOffer} scope={{}} cargo={cargoItems}/>);
    const instance = wrapper.instance();
    const key = 'export'
    const quote = selectedOffer
    quote.export.test = { value: 0.105e3, currency: 'GBP', name: 'VGM' }
    const contentSections = Object.entries(quote[key])
    .map(array => array.filter(value => !instance.unbreakableKeys.includes(value)))
    .filter(value => value.length !== 1)
    const currencySections = {}
    const currencyTotals = {}
    contentSections.forEach((price) => {
      const { currency, value, overridePrice } = instance.dynamicValueExtractor(key, price)
  
      if (value && currency) {
        if (!currencySections[currency]) {
          currencySections[currency] = []
        }
        if (!currencyTotals[currency]) {
          currencyTotals[currency] = 0.0
        }
        currencyTotals[currency] += parseFloat(value)
        currencySections[currency].push(overridePrice)
      }
      const showSubTotal = QuoteChargeBreakdown.shouldShowSubTotal(currencySections)
      expect(showSubTotal).toBe(true)
    })
 
  })


  test('it hides the grand totals', () => {
    const shallowTest = shallow(<QuoteChargeBreakdown quote={selectedOffer} scope={{hide_grand_total: true}} cargo={cargoItems} />)
    expect(shallowTest).toMatchSnapshot()
  })
  

});
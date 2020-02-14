import React from 'react'
import { mount } from 'enzyme'
import QuoteChargeBreakdown from './QuoteChargeBreakdown'
import { selectedOffer, cargoItems, user } from '../../mocks/index'
import { UserContext } from '../../helpers/contexts'

describe('correctly determines whether to display subtotals based on currencies charged', () => {
  it('should render the total', () => {
    const wrapper = mount(
      <UserContext.Provider value={user}>
        <QuoteChargeBreakdown
          quote={selectedOffer}
          scope={{ hide_sub_totals: false }}
          cargo={cargoItems}
        />
      </UserContext.Provider>
    )
    const instance = wrapper.instance()
    const key = 'cargo'
    const quote = selectedOffer
    const contentSections = Object.entries(quote[key])
      .map(array => array.filter(value => !instance.unbreakableKeys.includes(value)))
      .filter(value => value.length !== 1)
    const currencySections = {}
    const scope = { hide_sub_totals: false }
    const currencyTotals = {}
    contentSections.forEach((price) => {
      const { currency, value, overridePrice } = instance.dynamicValueExtractor(
        key,
        price
      )

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
      const showSubTotal = QuoteChargeBreakdown.shouldShowSubTotal(
        currencySections,
        scope
      )
      expect(showSubTotal).toBe(true)
    })
  })

  it('should not render the total due to scope', () => {
    const wrapper = mount(
      <UserContext.Provider value={user}>
        <QuoteChargeBreakdown
          quote={selectedOffer}
          scope={{ hide_sub_totals: true }}
          cargo={cargoItems}
        />
      </UserContext.Provider>
    )
    const instance = wrapper.instance()
    const key = 'cargo'
    const quote = selectedOffer
    const contentSections = Object.entries(quote[key])
      .map(array => array.filter(value => !instance.unbreakableKeys.includes(value)))
      .filter(value => value.length !== 1)
    const currencySections = {}
    const scope = { hide_sub_totals: true }

    const currencyTotals = {}
    contentSections.forEach((price) => {
      const { currency, value, overridePrice } = instance.dynamicValueExtractor(
        key,
        price
      )

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
      const showSubTotal = QuoteChargeBreakdown.shouldShowSubTotal(
        currencySections,
        scope
      )
      expect(showSubTotal).toBe(false)
    })
  })
})

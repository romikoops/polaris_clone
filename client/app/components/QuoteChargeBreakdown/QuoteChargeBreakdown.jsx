import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { get } from 'lodash'
import styles from './QuoteChargeBreakdown.scss'
import CollapsingBar from '../CollapsingBar/CollapsingBar'
import {
  numberSpacing, capitalize, formattedPriceValue, nameToDisplay, humanizeSnakeCaseUp
} from '../../helpers'

class QuoteChargeBreakdown extends Component {
  constructor (props) {
    super(props)
    this.unbreakableKeys = ['total', 'edited_total', 'name']
    this.quoteKeys = this.quoteKeys.bind(this)
    this.state = {
      expander: this.quoteKeys().reduce((acc, k) => ({ ...acc, [k]: props.scope.hide_sub_totals }), {})
    }
  }

  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }

  determineSubKey (charge) {
    const { scope, mot } = this.props

    if (charge[0] === 'unknown') {
      return `${capitalize(mot)} Freight: ${charge[1].name}`
    }

    switch (scope.fee_detail) {
      case 'key':
        return this.displayKeyOnly(charge[0])
      case 'name':
        return charge[1].name
      case 'key_and_name':
        return this.displayKeyAndName(charge)
      default:
        return this.displayKeyOnly(charge[0])
    }
  }

  displayKeyOnly (key) {
    const { t } = this.props

    switch (key) {
      case 'trucking_lcl' || 'trucking_fcl':
        return t('cargo:truckingRate')

      default:
        return humanizeSnakeCaseUp(key)
    }
  }

  displayKeyAndName (fee) {
    const { t } = this.props

    switch (fee[0]) {
      case 'trucking_lcl' || 'trucking_fcl':
        return t('cargo:truckingRate')

      default:
        return `${humanizeSnakeCaseUp(fee[0])} - ${fee[1].name}`
    }
  }

  quoteKeys () {
    const keysInOrder = ['trucking_pre', 'export', 'cargo', 'import', 'trucking_on']
    const availableQuoteKeys = Object.keys(this.props.quote).filter(key => !this.unbreakableKeys.includes(key))

    return keysInOrder.filter(key => availableQuoteKeys.includes(key))
  }

  motName (name) {
    const { mot } = this.props
    if (name === 'Freight') {
      return `${capitalize(mot)} ${name}`
    }

    return name
  }

  dynamicValueExtractor (key, price) {
    const { scope } = this.props
    if (scope.freight_in_original_currency && key === 'cargo') {
      const feeKeys = Object.keys(price[1]).filter(key => !this.unbreakableKeys.includes(key))
      const currency = price[1][feeKeys[0]].currency
      let value = 0.0
      feeKeys.forEach((fKey) => {
        value += parseFloat(price[1][fKey].value)
      })
      const overridePrice = [price[0], {
        ...price[1],
        total: {
          value,
          currency
        }
      }]

      return { currency, value, overridePrice }
    }
    const currency = ['export', 'import'].includes(key) ? get(price, ['1', 'currency'], null) : get(price, ['1', 'total', 'currency'], null)
    const value = ['export', 'import'].includes(key) ? get(price, ['1', 'value'], null) : get(price, ['1', 'total', 'value'], null)

    return { currency, value, overridePrice: price }
  }

  dynamicSectionTotal (key) {
    const { scope, quote } = this.props
    if (scope.freight_in_original_currency && key === 'cargo') {
      const pricesArray = Object.entries(quote[key]).filter(array => !this.unbreakableKeys.includes(array[0]))
      const feeKeys = Object.keys(pricesArray[0][1]).filter(pKey => !this.unbreakableKeys.includes(pKey))
      if (feeKeys.length === 1 && feeKeys[0] === 'unknown') return ''
      const { currency } = pricesArray[0][1][feeKeys[0]]
      let value = 0.0
      pricesArray.forEach((price) => {
        feeKeys.forEach((fKey) => {
          value += parseFloat(price[1][fKey].value)
        })
      })

      return `${formattedPriceValue(value)} ${currency}`
    }
    if (scope.hide_sub_totals) {
      return ''
    }

    return `${formattedPriceValue(quote[key].total.value)} ${quote[key].total.currency}`
  }

  dynamicSubKey (key, price, i) {
    const { t } = this.props

    if (key === 'cargo') {
      return t('cargo:unitFreightRate', { unitNo: i + 1 })
    }

    return this.determineSubKey(price)
  }

  generateContent (key) {
    const { quote, t, scope } = this.props

    const contentSections = Object.entries(quote[`${key}`])
      .map(array => array.filter(value => !this.unbreakableKeys.includes(value)))
      .filter(value => value.length !== 1)
    const currencySections = {}
    const currencyTotals = {}
    contentSections.forEach((price) => {
      const { currency, value, overridePrice } = this.dynamicValueExtractor(key, price)

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
    })

    return Object.entries(currencySections).map(currencyFees => (
      <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">

        {scope.detailed_billing ? currencyFees[1].map((price, i) => {
          const subPrices = (
            <div className={`flex-100 layout-row layout-align-start-center ${styles.sub_price_row}`}>
              <div className="flex-45 layout-row layout-align-start-center">
                <span>
                  {this.dynamicSubKey(key, price, i)}
                </span>
              </div>
              <div className="flex-50 layout-row layout-align-end-center">
                <p>
                  {numberSpacing(price[1].value || price[1].total.value, 2)}
                    &nbsp;
                  {(price[1].currency || price[1].total.currency)}
                </p>
              </div>
            </div>
          )

          return subPrices
        }) : ''}
        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.currency_header}`}>
          <div className="flex-70 layout-row layout-align-start-center">
            <span className="flex-none bold">
              {' '}
              {t('cargo:feesIn', { currency: currencyFees[0] })}
            </span>
          </div>
          <div className="flex-25 layout-row layout-align-end-center">
            <p className="flex-none bold">{`${numberSpacing(currencyTotals[currencyFees[0]] || 0, 2)} ${currencyFees[0]}`}</p>
          </div>
        </div>
      </div>
    ))
  }

  fetchCargoData (id) {
    const { cargo } = this.props
    if (id === 'cargo_item') {
      return cargo[0]
    }

    return cargo.filter(cargo => String(cargo.id) === String(id))[0]
  }

  determineContentToGenerate (key) {
    const { scope } = this.props
    if (key === 'cargo' && scope.fine_fee_detail) return this.generateUnitContent(key)

    return this.generateContent(key)
  }

  shouldShowSubTotal (currencySections) {
    if (Object.keys(currencySections).length > 1) return true

    if (Object.values(currencySections)[0].length > 1) return true

    if (Object.values(currencySections)[0][0][0] === 'unknown') return false

    return true
  }

  generateUnitContent (key) {
    const { quote, t, scope } = this.props

    const unitSections = Object.entries(quote[`${key}`])
      .map(array => array.filter(value => !this.unbreakableKeys.includes(value)))
      .filter(value => value.length !== 1)

    return unitSections.map((unitArray) => {
      const cargo = this.fetchCargoData(unitArray[0])

      const contentSections = Object.entries(unitArray[1])
        .map(array => array.filter(value => !this.unbreakableKeys.includes(value)))
        .filter(value => value.length !== 1)
      const currencySections = {}
      const currencyTotals = {}
      contentSections.forEach((price) => {
        const { currency, value } = price[1]

        if (!currencySections[currency]) {
          currencySections[currency] = []
        }
        if (!currencyTotals[currency]) {
          currencyTotals[currency] = 0.0
        }
        currencyTotals[currency] += parseFloat(value)
        currencySections[currency].push(price)
      })
      const dimensions = cargo.cargo_class === 'lcl'
        ? [
          <p className={`flex-none ${styles.item_dims}`}>{`W: ${cargo.dimension_x}cm L:${cargo.dimension_y}cm H: ${cargo.dimension_z}cm`}</p>,
          <p className={`flex-none ${styles.item_dims}`}>{`${t('cargo:perUnitWeight')} ${cargo.payload_in_kg}kg`}</p>
        ] : [
          <p className={`flex-none ${styles.item_dims}`}>{`${t('cargo:perUnitWeight')} ${cargo.payload_in_kg}kg`}</p>
        ]
      const showSubTotal = this.shouldShowSubTotal(currencySections)
      const sections = Object.entries(currencySections).map(currencyFees => (
        <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">

          {scope.detailed_billing ? currencyFees[1].map((price, i) => {
            const subPrices = (
              <div className={`flex-100 layout-row layout-align-start-center ${styles.sub_price_row}`}>
                <div className="flex-70 layout-row layout-align-start-center">
                  <span>
                    {this.determineSubKey(price)}
                  </span>
                </div>
                <div className="flex-25 layout-row layout-align-end-center">
                  { price[0] === 'unknown' ? '' : (
                    <p>
                      {numberSpacing(price[1].value || price[1].total.value, 2)}
                      &nbsp;
                      {(price[1].currency || price[1].total.currency)}
                    </p>
                  )}
                </div>
              </div>
            )

            return subPrices
          }) : ''}

          { showSubTotal ? (
            <div className={`flex-100 layout-row layout-align-space-between-center ${styles.currency_header}`}>
              <div className="flex-45 layout-row layout-align-start-center">
                <span className="flex-none bold">
                  {' '}
                  {t('cargo:feesIn', { currency: currencyFees[0] })}
                </span>
              </div>
              <div className="flex-45 layout-row layout-align-end-center">
                <p className="flex-none bold">{`${numberSpacing(currencyTotals[currencyFees[0]] || 0, 2)} ${currencyFees[0]}`}</p>
              </div>
            </div>
          ) : '' }

        </div>
      ))

      return (
        <div className="flex-100 layout-row layout-wrap">
          <div className={`flex-100 layout-row layout-align-space-between-center ${styles.cargo_summary}`}>
            <p className={`flex-none ${styles.item_dims}`}>{`${cargo.quantity} x ${nameToDisplay(cargo.cargo_class)}`}</p>
            {dimensions}
          </div>
          {sections}
        </div>
      )
    })
  }

  overrideTranslations (key) {
    const { t, scope } = this.props

    if (scope.translation_overrides && scope.translation_overrides[key]) {
      return capitalize(t(scope.translation_overrides[key]))
    }

    return capitalize(t(key))
  }

  render () {
    const {
      theme,
      quote,
      showBreakdowns,
      scope
    } = this.props
    if (Object.keys(quote).length === 0) return ''

    return this.quoteKeys()
      // .filter(key => ((!scope.cargo_price_notes || (scope.cargo_price_notes && !scope.cargo_price_notes[key]))))
      .map(key => (
        <CollapsingBar
          showArrow
          collapsed={showBreakdowns ? this.state.expander[`${key}`] : !this.state.expander[`${key}`]}
          theme={theme}
          contentStyle={styles.sub_price_row_wrapper}
          headerWrapClasses="flex-100 layout-row layout-wrap layout-align-start-center"
          handleCollapser={() => this.toggleExpander(`${key}`)}
          mainWrapperStyle={{ borderTop: '1px solid #E0E0E0', minHeight: '50px' }}
          contentHeader={(
            <div className={`flex-100 layout-row layout-align-start-center ${styles.price_row}`}>
              <div
                className="flex-none layout-row layout-align-start-center"
              />
              <div className="flex-45 layout-row layout-align-start-center">
                <span>{this.motName(quote[key].name)}</span>
              </div>
              <div className="flex-50 layout-row layout-align-end-center">
                <p>
                  {
                    this.dynamicSectionTotal(key)
                  }
                </p>
              </div>
            </div>
          )}
          content={this.determineContentToGenerate(key)}
        />
      ))
  }
}

export default withNamespaces(['shipment', 'cargo', 'overrides'])(QuoteChargeBreakdown)

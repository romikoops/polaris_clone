import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
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
    const { scope } = this.props

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
    const {mot} = this.props
    if (name === 'Freight') {
      return `${capitalize(mot)} ${name}`
    }
    return name
  }

  generateContent (key) {
    const { quote, t, scope } = this.props

    const contentSections = Object.entries(quote[`${key}`])
      .map(array => array.filter(value => !this.unbreakableKeys.includes(value)))
      .filter(value => value.length !== 1)
    const currencySections = {}
    const currencyTotals = {}
    contentSections.forEach((price) => {
      const currency = ['export', 'import'].includes(key) ? price[1].currency : price[1].total.currency
      const value = ['export', 'import'].includes(key) ? price[1].value : price[1].total.value
      if (!currencySections[currency]) {
        currencySections[currency] = []
      }
      if (!currencyTotals[currency]) {
        currencyTotals[currency] = 0.0
      }
      currencyTotals[currency] += parseFloat(value)
      currencySections[currency].push(price)
    })

    return Object.entries(currencySections).map(currencyFees => (
      <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">

        {scope.detailed_billing ? currencyFees[1].map((price, i) => {
          const subPrices = (
            <div className={`flex-100 layout-row layout-align-start-center ${styles.sub_price_row}`}>
              <div className="flex-45 layout-row layout-align-start-center">
                <span>
                  {key === 'cargo' ? t('cargo:unitFreightRate', { unitNo: i + 1 }) : this.determineSubKey(price)}
                </span>
              </div>
              <div className="flex-50 layout-row layout-align-end-center">
                {scope.cargo_price_notes && scope.cargo_price_notes[key] ? (
                  <p style={{ textAlign: 'right', width: '100%' }}>{scope.cargo_price_notes[key]}</p>
                ) : (
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
        {scope.cargo_price_notes && scope.cargo_price_notes[key] ? ''
          : (
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
          ) }
      </div>
    ))
  }

  fetchCargoData (id) {
    const { cargo } = this.props

    return cargo.filter(cargo => String(cargo.id) === String(id))[0]
  }

  determineContentToGenerate (key) {
    const { scope } = this.props
    if (key === 'cargo' && scope.fine_fee_detail) return this.generateUnitContent(key)

    return this.generateContent(key)
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
          <p className="flex-none">{`W: ${cargo.dimension_x}cm L:${cargo.dimension_y}cm H: ${cargo.dimension_z}cm`}</p>,
          <p className="flex-none">{`${t('cargo:perUnitWeight')} ${cargo.payload_in_kg}kg`}</p>
        ] : [
          <p className="flex-none">{`${t('cargo:perUnitWeight')} ${cargo.payload_in_kg}kg`}</p>
        ]
      const sections = Object.entries(currencySections).map(currencyFees => (
        <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">

          {scope.detailed_billing ? currencyFees[1].map((price, i) => {
            const subPrices = (
              <div className={`flex-100 layout-row layout-align-start-center ${styles.sub_price_row}`}>
                <div className="flex-45 layout-row layout-align-start-center">
                  <span>
                    {this.determineSubKey(price)}
                  </span>
                </div>
                <div className="flex-50 layout-row layout-align-end-center">
                  {scope.cargo_price_notes && scope.cargo_price_notes[key] ? (
                    <p style={{ textAlign: 'right', width: '100%' }}>{scope.cargo_price_notes[key]}</p>
                  ) : (
                    <p>
                      {`${numberSpacing(price[1].value || price[1].total.value, 2)}&nbsp;${(price[1].currency || price[1].total.currency)}`}
                    </p>
                  )}
                </div>
              </div>
            )

            return subPrices
          }) : ''}
          {scope.cargo_price_notes && scope.cargo_price_notes[key] ? ''
            : (
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
            ) }
        </div>
      ))

      return (
        <div className="flex-100 layout-row layout-wrap">
          <div className={`flex-100 layout-row layout-align-space-between-center ${styles.cargo_summary}`}>
            <p className="flex-none">{`${cargo.quantity} x ${nameToDisplay(cargo.cargo_class)}`}</p>
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
      scope
    } = this.props
    if (Object.keys(quote).length === 0) return ''

    return this.quoteKeys()
      .filter(key => ((!scope.cargo_price_notes || (scope.cargo_price_notes && !scope.cargo_price_notes[key]))))
      .map(key => (
        <CollapsingBar
          showArrow
          collapsed={!this.state.expander[`${key}`]}
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
                    scope.hide_sub_totals || (scope.cargo_price_notes && scope.cargo_price_notes[key])
                      ? ''
                      : `${formattedPriceValue(quote[key].total.value)} ${quote[key].total.currency}`
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

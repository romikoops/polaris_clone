import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './QuoteChargeBreakdown.scss'
import CollapsingBar from '../CollapsingBar/CollapsingBar'
import { numberSpacing, capitalize, formattedPriceValue } from '../../helpers'
import PropTypes from '../../prop-types'

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
        return key
    }
  }

  displayKeyAndName (fee) {
    const { t } = this.props
    
    switch (fee[0]) {
      case 'trucking_lcl' || 'trucking_fcl':
        return t('cargo:truckingRate')

      default:
        return `${fee[0]} - ${fee[1].name}`
    }
  }
  quoteKeys () {
    const keysInOrder = ['trucking_pre', 'export', 'cargo', 'import', 'trucking_on']
    const availableQuoteKeys = Object.keys(this.props.quote).filter(key => !this.unbreakableKeys.includes(key))
    return keysInOrder.filter(key => availableQuoteKeys.includes(key))
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
          const subPrices = (<div className={`flex-100 layout-row layout-align-start-center ${styles.sub_price_row}`}>
            <div className="flex-45 layout-row layout-align-start-center">
              <span>
                {key === 'cargo' ? t('cargo:unitFreightRate', { unitNo: i + 1 }) : this.determineSubKey(price)}
              </span>
            </div>
            <div className="flex-50 layout-row layout-align-end-center">
              {scope.cargo_price_notes && scope.cargo_price_notes[key] ? (
                <p style={{ textAlign: 'right', width: '100%' }}>{scope.cargo_price_notes[key]}</p>
              ) : (
                <p>{numberSpacing(price[1].value || price[1].total.value, 2)}&nbsp;{(price[1].currency || price[1].total.currency)}</p>
              )}
            </div>
          </div>)

          return subPrices
        }) : ''}
        {scope.cargo_price_notes && scope.cargo_price_notes[key] ? ''
          : <div className={`flex-100 layout-row layout-align-space-between-center ${styles.currency_header}`}>
            <div className="flex-45 layout-row layout-align-start-center">
              <span className="flex-none"> {t('cargo:feesIn', { currency: currencyFees[0] })}</span>
            </div>
            <div className="flex-45 layout-row layout-align-end-center">
              <p className="flex-none">{`${numberSpacing(currencyTotals[currencyFees[0]] || 0, 2)} ${currencyFees[0]}`}</p>
            </div>
          </div> }
      </div>
    ))
  }

  overrideTranslations (key) {
    const { t, scope } = this.props

    if (scope.translation_overrides && scope.translation_overrides[key]) {
      return capitalize(t(scope.translation_overrides[key]))
    }

    return capitalize(t(key))
  }

  renderSubTitle (key) {
    const { t, mot, scope } = this.props

    if (scope.translation_overrides && scope.translation_overrides[key]) {
      return this.overrideTranslations(`shipment:${key}`)
    }

    switch (key) {
      case 'trucking_pre':
        return t('shipment:pickUp')
      case 'trucking_on':
        return t('shipment:delivery')
      case 'cargo':
        return t('shipment:motCargo', { mot: t(`shipment:${mot}`) })
      default:
        return ''
    }
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
                <span>{this.renderSubTitle(key)}</span>
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
          content={this.generateContent(key)}
        />
      ))
  }
}

QuoteChargeBreakdown.propTypes = {
  theme: PropTypes.theme,
  scope: PropTypes.scope.isRequired,
  t: PropTypes.func.isRequired,
  quote: PropTypes.node.isRequired,
  mot: PropTypes.string.isRequired
}

QuoteChargeBreakdown.defaultProps = {
  theme: null
}
export default withNamespaces(['shipment', 'cargo', 'overrides'])(QuoteChargeBreakdown)

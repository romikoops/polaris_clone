import React, { Component } from 'react'
import { translate } from 'react-i18next'
import styles from './QuoteChargeBreakdown.scss'
import CollapsingBar from '../CollapsingBar/CollapsingBar'
import { numberSpacing, capitalize } from '../../helpers'
import PropTypes from '../../prop-types'

class QuoteChargeBreakdown extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expander: {}
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

  render () {
    const {
      theme,
      t,
      quote
    } = this.props
    if (Object.keys(quote).length === 0) return ''

    const unbreakableKeys = ['total', 'edited_total', 'name']
    const quoteChargeBreakdown = Object.keys(quote)
      .filter(key => !unbreakableKeys.includes(key))
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
              <div className="flex-none layout-row layout-align-start-center" />
              <div className="flex-45 layout-row layout-align-start-center">
                {key === 'trucking_pre' ? (
                  <span>{t('shipment:pickUp')}</span>
                ) : ''}
                {key === 'trucking_on' ? (
                  <span>{t('shipment:delivery')}</span>
                ) : ''}
                <span>{key === 'trucking_pre' || key === 'trucking_on' ? '' : capitalize(key)}</span>
              </div>
              <div className="flex-50 layout-row layout-align-end-center">
                <p>
                  {numberSpacing(quote[`${key}`].total.value, 2)}&nbsp;{quote.total.currency}
                </p>
              </div>
            </div>
          )}
          content={Object.entries(quote[`${key}`])
            .map(array => array.filter(value => !unbreakableKeys.includes(value)))
            .filter(value => value.length !== 1).map((price, i) => {
              const subPrices = (<div className={`flex-100 layout-row layout-align-start-center ${styles.sub_price_row}`}>
                <div className="flex-45 layout-row layout-align-start-center">
                  <span>{key === 'cargo' ? `${t('cargo:unitFreightRate', { unitNo: i + 1 })}` : this.determineSubKey(price)}</span>
                </div>
                <div className="flex-50 layout-row layout-align-end-center">
                  <p>{numberSpacing(price[1].value || price[1].total.value, 2)}&nbsp;{(price[1].currency || price[1].total.currency)}</p>
                </div>
              </div>)

              return subPrices
            })}
        />
      ))

    return quoteChargeBreakdown
  }
}

QuoteChargeBreakdown.propTypes = {
  theme: PropTypes.theme,
  scope: PropTypes.scope,
  t: PropTypes.func.isRequired,
  quote: PropTypes.node.isRequired
}

QuoteChargeBreakdown.defaultProps = {
  theme: null,
  scope: {}
}
export default translate(['shipment', 'cargo'])(QuoteChargeBreakdown)

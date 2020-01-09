import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { uniq, compact } from 'lodash'
import { numberSpacing } from '../../../../helpers'
import CollapsingBar from '../../../CollapsingBar/CollapsingBar'
import styles from '../index.scss'

class RatesOverview extends Component {
  static keyToRender (key) {
    let str = key.toLowerCase()
    if (str.includes('included_')) {
      str = str.replace('included_', '').toUpperCase()
    }
    if (str.includes('unknown_')) {
      str = str.replace('unknown_', '').toUpperCase()
    }

    return str.replace(/_/g, ' ').toUpperCase()
  }

  valueToRender (key, value) {
    const { t } = this.props

    if (key.toLowerCase().includes('included_')) {
      return t('shipment:included')
    }
    if (!value) {
      return '-'
    }

    return numberSpacing(value, 2)
  }

  render () {
    const { theme, ratesObject, t } = this.props
    const valuesByFees = {}
    const currencyByFees = {}
    const cargoClasses = Object.keys(ratesObject).sort()
    cargoClasses.forEach((cargoClass) => {
      Object.keys(ratesObject[cargoClass]).filter(key => !['total', 'valid_until'].includes(key)).forEach((key) => {
        if (!valuesByFees[key]) { valuesByFees[key] = {} }
        valuesByFees[key][cargoClass] = ratesObject[cargoClass][key].rate
        if (!currencyByFees[key]) { currencyByFees[key] = {} }
        currencyByFees[key] = ratesObject[cargoClass][key].currency
      })
    })
    const singleCurrency = uniq(compact(Object.values(currencyByFees))).length === 1
    const currencyToDisplay = singleCurrency ? Object.values(ratesObject)[0].total.currency : null
    const overviewNode = [
      (<div className="flex-20 layout-row layout-wrap layout-align-start-center">
        <p className={`flex-100  ${styles.rates_header}`}>
          {`${t(`common:freightCharges`)}:`}
        </p>
        { singleCurrency ? (<p className={`flex-100  ${styles.rates_value}`}>
          {`${t(`common:perUnitLumpsum`)}:`}
        </p>
        ) : '' }
      </div>),
      (<div className="flex layout-row layout-wrap layout-align-center-center">
        <p className={`flex-100 center ${styles.rates_header}`}>
          {`${t(`common:currency`)}`}
        </p>
        { singleCurrency ? (
          <p className={`flex-100 center ${styles.rates_value}`}>
            {`${currencyToDisplay}`}
          </p>
        ) : '' }
      </div>)
    ]

    cargoClasses.forEach((cargoClass) => {
      overviewNode.push(
        <div className="flex layout-row layout-wrap layout-align-center-center">
          <p className={`flex-100 center ${styles.rates_header}`}>
            {t(`common:${cargoClass}`)}
          </p>
          { singleCurrency ? (
            <p className={`flex-100 center ${styles.rates_value}`}>
              {`${numberSpacing(ratesObject[cargoClass].total.value, 2)}`}
            </p>
          ) : '' }
        </div>
      )
    })

    const content = []
    Object.keys(valuesByFees).forEach((feeKey) => {
      const feeNode = [
        (<div className="flex-20 layout-row layout-wrap layout-align-start-center">
          <p className={`flex-100  ${styles.rates_sub_header}`}>
            {`${RatesOverview.keyToRender(feeKey)}:`}
          </p>
        </div>),
        (<div className="flex layout-row layout-wrap layout-align-center-center">
          <p className={`flex-100 center ${styles.rates_value}`}>
            {currencyByFees[feeKey] || '-' }
          </p>
        </div>)
      ]
      cargoClasses.forEach((cargoClass) => {
        feeNode.push(
          <div className="flex layout-row layout-wrap layout-align-center-center">
            <p className={`flex-100 center ${styles.rates_value}`}>
              {`${this.valueToRender(feeKey, valuesByFees[feeKey][cargoClass])}`}
            </p>
          </div>
        )
      })
      content.push(<div className={`flex-90 layout-row layout-align-space-around-center ${styles.rate_wrapper}`}>
        {feeNode}
      </div>)
    })

    return (
      <div className="layout-row layout-wrap layout-align-start-center flex-100">
        <CollapsingBar
          theme={theme}
          contentHeader={overviewNode}
          showArrow
          startCollapsed
          mainWrapperStyle={{ borderTop: '1px solid #E0E0E0', minHeight: '50px' }}
          headerWrapClasses={`flex layout-row layout-align-space-around-center ${styles.rate_wrapper}`}
          content={content}
        />
      </div>
    )
  }
}

RatesOverview.defaultProps = {
  theme: {},
  ratesObject: {}
}
export default withNamespaces('common')(RatesOverview)

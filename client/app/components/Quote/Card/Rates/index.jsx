import React from 'react'
import { withNamespaces } from 'react-i18next'
import CollapsingBar from '../../../CollapsingBar/CollapsingBar'
import styles from '../index.scss'

function RatesOverview ({
  theme, ratesObject, t
}) {
  const valuesByFees = {}
  const currencyToDisplay = Object.values(ratesObject)[0].total.currency
  const overviewNode = [
    (<div className="flex-20 layout-row layout-wrap layout-align-start-center">
      <p className={`flex-100  ${styles.rates_header}`}>
        {`${t(`common:freightCharges`)}:`}
      </p>
      <p className={`flex-100  ${styles.rates_value}`}>
        {`${t(`common:perUnitLumpsum`)}:`}
      </p>
    </div>),
    (<div className="flex layout-row layout-wrap layout-align-center-center">
      <p className={`flex-100 center ${styles.rates_header}`}>
        {`${t(`common:currency`)}`}
      </p>
      <p className={`flex-100 center ${styles.rates_value}`}>
        {`${currencyToDisplay}`}
      </p>
    </div>)
  ]
  const cargoClasses = Object.keys(ratesObject).sort()
  cargoClasses.forEach((cargoClass) => {
    overviewNode.push(
      <div className="flex layout-row layout-wrap layout-align-center-center">
        <p className={`flex-100 center ${styles.rates_header}`}>
          {t(`common:${cargoClass}`)}
        </p>
        <p className={`flex-100 center ${styles.rates_value}`}>
          {`${ratesObject[cargoClass].total.value}`}
        </p>
      </div>
    )
    Object.keys(ratesObject[cargoClass]).filter(k => k !== 'total').forEach((key) => {
      if (!valuesByFees[key]) { valuesByFees[key] = {} }
      valuesByFees[key][cargoClass] = ratesObject[cargoClass][key].rate
    })
  })
  const content = []
  Object.keys(valuesByFees).forEach((feeKey) => {
    const feeNode = [
      (<div className="flex-20 layout-row layout-wrap layout-align-start-center">
        <p className={`flex-100  ${styles.rates_sub_header}`}>
          {`${feeKey}:`}
        </p>
      </div>),
      (<div className="flex layout-row layout-wrap layout-align-center-center">
        <p className={`flex-100 center ${styles.rates_value}`}>
          {`${currencyToDisplay}`}
        </p>
      </div>)
    ]
    cargoClasses.forEach((cargoClass) => {
      feeNode.push(
        <div className="flex layout-row layout-wrap layout-align-center-center">
          <p className={`flex-100 center ${styles.rates_value}`}>
            {`${valuesByFees[feeKey][cargoClass]}`}
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
        startCollapsed={true}
        mainWrapperStyle={{ borderTop: '1px solid #E0E0E0', minHeight: '50px' }}
        headerWrapClasses={`flex layout-row layout-align-space-around-center ${styles.rate_wrapper}`}
        content={content}
      />
    </div>
  )
}
RatesOverview.defaultProps = {
  theme: {},
  ratesObject: {}
}
export default withNamespaces('common')(RatesOverview)

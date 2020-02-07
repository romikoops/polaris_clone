import React, { useState } from 'react'
import { get } from 'lodash'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'
import { numberSpacing } from '../../../../helpers'

function ResultSection ({
  section, sectionKey, viewRate, t
}) {
  let rows = false

  if (section) {
    const feeKeys = Object.keys(get(section, ['fees']))
    const nonValueKeys = ['name', 'key', 'currency', 'min', 'max', 'rate_basis', 'base', 'hw_threshold', 'hw_rate_basis', 'range']

    rows = feeKeys.flatMap((feeKey) => {
      const finalFee = get(section, ['fees', feeKey, 'final'], {})
      const name = feeKey.includes('trucking')
        ? t('shipment:truckingRate') : get(finalFee, ['key'])
      if (sectionKey.includes('trucking_')) {
        return (
          <tr
            className={`${styles.fee_row} pointy`}
            onClick={() => viewRate(sectionKey, feeKey)}
          >
            <td colSpan="2">{name}</td>
            <td><i className="fa fa-eye" /></td>
          </tr>
        )
      }
      const valueKeys = Object.keys(finalFee).filter(key => !nonValueKeys.includes(key))
      const rateBasis = t(`rates:${get(finalFee, 'rate_basis')}`)

      const valueRows = valueKeys.map((valueKey, i) => {
        const finalValue = `${get(finalFee, 'currency')} ${numberSpacing(get(finalFee, valueKey), 2)}`

        return (
          <tr
            className={`${styles.fee_row} pointy`}
            onClick={() => viewRate(sectionKey, feeKey)}
          >
            <td>{i === 0 ? name : ''}</td>
            <td>{finalValue}</td>
            <td>{rateBasis}</td>
          </tr>
        )
      })
      const additionMarginsValue = get(section, ['fees', feeKey, 'flatMargins'], [])
        .filter(margin => margin.operator === '+')
        .reduce((acc, margin) => acc += Number(margin.margin_value), 0)

      if (additionMarginsValue > 0) {
        valueRows.push(<tr
          className={`${styles.fee_row} pointy`}
          onClick={() => viewRate(sectionKey, feeKey)}
        >
          <td />
          <td>+</td>
          <td>{`${get(finalFee, 'currency')} ${numberSpacing(additionMarginsValue, 2)}`}</td>
        </tr>)
      }

      return valueRows
    })
  }
  const invertClass = sectionKey.includes('trucking_') ? styles.invert_table_section : ''

  return (
    <div className={`flex layout-column layout-align-center-center ${styles.main_table_section} ${invertClass}`}>
      <div className="flex-100 layout-row layout-align-center-center">
        <p className="flex-100">{t(`rates:${sectionKey}`)}</p>
      </div>
      { rows
        ? (
          <table>
            <tbody>
              {rows}
            </tbody>
          </table>
        )
        : (
          <div className={`flex-100 layout-row layout-align-center-center layout-wrap ${styles.no_data}`}>
            <div className="flex-100 layout-row layout-align-center-center">
              <i className="flex-none fa fa-minus-circle" />
            </div>

          </div>
        )
      }

    </div>
  )
}

export default withNamespaces(['rates'])(ResultSection)

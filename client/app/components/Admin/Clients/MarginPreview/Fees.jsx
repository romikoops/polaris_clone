import React from 'react'
import { get, has, find } from 'lodash'
import { withNamespaces } from 'react-i18next'

function Fees ({ data, t }) {
  const valueKeys = ['rate', 'value', 'cbm', 'ton', 'margin_value']
  const isRangeFee = has(data, 'range') && data.range.length > 0
  function generateRows () {
    if (isRangeFee) {
      const valueKey = find(valueKeys, key => !!range.data[key])
      const currency = get(data.range, [0, 'currency'])
      const rangeStart = get(data.range, [0, valueKey])
      const rangeEnd = get(data.range, [data.range.length - 1, valueKey])
      const rangeString = `${rangeStart} ${currency} - ${rangeEnd} ${currency}`

      return (
        <tr>
          <td colSpan="3" className={styles.type_cell}>{data.min_value}</td>
          <td colSpan="3" className={styles.value_cell}>{t('rates:effRange', { min, max, unit })}</td>
          <td colSpan="3" className={styles.range_cell}>{rangeString}</td>
          <td colSpan="3" className={styles.range_cell}>{data.rate_basis}</td>
        </tr>
      )
    }

    const valueKey = find(valueKeys, key => !!data[key])
    const value = get(data, [valueKey])

    return (
      <tr>
        <td colSpan="4">{data.min || 'N/A'}</td>
        <td colSpan="4">{`${value} ${data.currency}`}</td>
        <td colSpan="4">{data.rate_basis}</td>
      </tr>
    )
  }

  const headers = isRangeFee ? (
    <thead>
      <th colSpan="3" className={styles.type_cell}>{t('rates:min')}</th>
      <th colSpan="3" className={styles.value_cell}>{t('rates:range')}</th>
      <th colSpan="3" className={styles.range_cell}>{t('rates:rateRange')}</th>
      <th colSpan="3" className={styles.range_cell}>{t('rates:rateBasis')}</th>
    </thead>
  ) : (
    <thead>
      <th colSpan="4">{t('rates:min')}</th>
      <th colSpan="4">{t('rates:rate')}</th>
      <th colSpan="4">{t('rates:rateBasis')}</th>
    </thead>
  )

  return (
    <table className="flex-100">
      {headers}
      {generateRows()}
    </table>
  )
}

export default withNamespaces(['rates'])(Fees)

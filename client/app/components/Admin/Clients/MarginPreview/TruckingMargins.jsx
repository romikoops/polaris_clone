import React from 'react'
import { get, has, find } from 'lodash'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'

function TruckingMargins ({ margins, t, viewOwner }) {
  const valueKeys = ['rate', 'value', 'cbm', 'ton', 'margin_value']
  const filteredMargins = margins.filter(margin => margin.operator !== '+')

  function row (margin) {
    return Object.keys(margin.data).map((modifierKey) => {
      const targetRates = get(margin, ['data', modifierKey])
      const valueKey = find(valueKeys, key => has(targetRates, [0, 'rate', key]))
      const currency = get(targetRates, [0, 'rate', 'currency'])
      const rangeStart = get(targetRates, [0, 'rate', valueKey])
      const rangeEnd = get(targetRates, [targetRates.length - 1, 'rate', valueKey])
      const ownerString = `${margin.target_type.replace('Tenants::', '')}: ${margin.target_name}`
      const rangeString = `${rangeStart} ${currency} - ${rangeEnd} ${currency}`

      return (
        <tr>
          <td colSpan="3" className={styles.type_cell}>{modifierKey}</td>
          <td colSpan="3" className={styles.value_cell}>{`${parseFloat(margin.margin_value) * 100} ${margin.operator}`}</td>
          <td colSpan="3" className={styles.range_cell}>{rangeString}</td>
          <td
            colSpan="3"
            className={styles.owner_cell}
            onClick={() => viewOwner(margin)}
          >
            {ownerString}
          </td>
        </tr>
      )
    })
  }

  const rows = filteredMargins.flatMap(margin => row(margin))

  return (
    <table className="flex-100">
      <thead>
        <th colSpan="3" className={styles.type_cell}>{t('rates:type')}</th>
        <th colSpan="3" className={styles.value_cell}>{t('rates:value')}</th>
        <th colSpan="3" className={styles.range_cell}>{t('rates:adjustedRate')}</th>
        <th colSpan="3" className={styles.owner_cell}>{t('rates:owner')}</th>
      </thead>
      {rows}
    </table>
  )
}

TruckingMargins.defaultProps = {
  margins: []
}

export default withNamespaces(['rates'])(TruckingMargins)

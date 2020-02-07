import React from 'react'
import { get } from 'lodash'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'

function TruckingFees ({ data, t }) {
  function generateRows () {
    return Object.keys(data).map((key) => {
      const targetRates = data[key]
      if (targetRates.length > 0) {
        const minMaxKeys = Object.keys(targetRates[0]).filter(subKey => subKey !== 'min_value')
        const minKey = minMaxKeys.find(subKey => subKey.includes('min'))
        const maxKey = minMaxKeys.find(subKey => subKey.includes('max'))
        const min = get(targetRates, [0, minKey])
        const max = get(targetRates, [targetRates.length - 1, maxKey])
        const rangeStart = get(targetRates, [0, 'rate', 'value'])
        const rangeEnd = get(targetRates, [targetRates.length - 1, 'rate', 'value'])
        const unit = key.includes('unit') ? 'unit' : key
        const rangeString = `${rangeStart} ${get(targetRates, [0, 'rate', 'currency'])} - ${rangeEnd} ${get(targetRates, [0, 'rate', 'currency'])}`

        return (
          <tr>
            <td colSpan="3" className={styles.type_cell}>{key}</td>
            <td colSpan="3" className={styles.value_cell}>{t('rates:effRange', { min, max, unit })}</td>
            <td colSpan="3" className={styles.range_cell}>{rangeString}</td>
            <td colSpan="3" className={styles.range_cell}>{get(targetRates, [0, 'rate', 'rate_basis'])}</td>
          </tr>
        )
      }
    })
  }

  const rows = generateRows()

  return (
    <table className="flex-100">
      <thead>
        <th colSpan="3" className={styles.type_cell}>{t('rates:type')}</th>
        <th colSpan="3" className={styles.value_cell}>{t('rates:range')}</th>
        <th colSpan="3" className={styles.range_cell}>{t('rates:rateRange')}</th>
        <th colSpan="3" className={styles.range_cell}>{t('rates:rateBasis')}</th>
      </thead>
      {rows}
    </table>
  )
}

export default withNamespaces(['rates'])(TruckingFees)

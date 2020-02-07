import React from 'react'
import { get, find } from 'lodash'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'

function Margins ({ margins, t, viewOwner }) {
  const valueKeys = ['rate', 'value', 'cbm', 'ton', 'margin_value']

  function percentRow (margin) {
    const valueKey = find(valueKeys, key => !!margin.data[key])
    const value = get(margin, ['data', valueKey])
    const currency = get(margin, ['data', 'currency'])
    const ownerString = `${margin.target_type.replace('Tenants::', '')}: ${margin.target_name}`

    return (
      <tr>
        <td colSpan="4" className={styles.value_cell}>{`${parseFloat(margin.margin_value) * 100} ${margin.operator}`}</td>
        <td colSpan="4" className={styles.value_cell}>{`${value} ${currency}`}</td>
        <td
          colSpan="4"
          className={styles.owner_cell}
          onClick={() => viewOwner(margin)}
        >
          {ownerString}
        </td>
      </tr>
    )
  }

  const rows = margins.map(margin => percentRow(margin))

  return (
    <table className="flex-100">
      <thead>
        <th colSpan="4" className={styles.value_cell}>{t('rates:delta')}</th>
        <th colSpan="4" className={styles.value_cell}>{t('rates:adjustedRate')}</th>
        <th colSpan="4" className={styles.owner_cell}>{t('rates:owner')}</th>
      </thead>
      {rows}
    </table>
  )
}

Margins.defaultProps = {
  margins: []
}

export default withNamespaces(['rates'])(Margins)

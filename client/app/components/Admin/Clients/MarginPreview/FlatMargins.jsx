import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'

function FlatMargins ({ margins, currency, t }) {
  const filteredMargins = margins.filter(margin => margin.operator === '+')

  function flatRow (margin) {
    return (
      <tr>
        <td colSpan="4" >{margin.operator}</td>
        <td colSpan="4">{`${margin.margin_value} ${currency}`}</td>
        <td colSpan="4">{margin.target_name}</td>
      </tr>
    )
  }

  const rows = filteredMargins.map(margin => flatRow(margin))

  return (
    <table className={`${styles.flat_table} flex-100`}>
      <thead>
        <th colSpan="4">{t('rates:operator')}</th>
        <th colSpan="4">{t('rates:value')}</th>
        <th colSpan="4">{t('rates:owner')}</th>
      </thead>
      {rows}
    </table>
  )
}

FlatMargins.defaultProps = {
  margins: []
}

export default withNamespaces(['rates'])(FlatMargins)

import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import styles from './index.scss'
import { numberSpacing } from '../../../../helpers'

class AdminMarginPreviewMargins extends Component {
  static renderValue (operator, value) {
    if (operator === '%') return Number(value) * 100

    return numberSpacing(value, 2)
  }

  render () {
    const { t, data } = this.props

    const columns = [
      {
        columns: [
          {
            Header: t('rates:owner'),
            accessor: d => d.target_name,
            id: 'owner'
          },
          {
            Header: t('rates:operator'),
            accessor: d => d.operator,
            id: 'operator'
          },
          {
            Header: t('rates:value'),
            accessor: d => AdminMarginPreviewMargins.renderValue(d.operator, d.margin_value),
            id: 'value'
          },
          {
            Header: t('rates:order'),
            accessor: d => d.order,
            id: 'order'
          }
        ]
      }
    ]
    const dataWithOrder = data.map((row, i) => ({ ...row, order: i + 1 }))

    return (
      <div className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles.rate_wrapper}`}>
        <div className={`flex-100 layout-row layout-aling-start-center ${styles.back_btn_row}`}>
          <div
            className={`flex-none layout-row layout-align-start-center ${styles.back_btn}`}
            onClick={this.props.back}
          >
            <i className="fa fa-chevron-left" />
            <p className="flex-none">{t('common:basicBack')}</p>
          </div>
        </div>
        <ReactTable
          className="flex-100 height_100"
          data={dataWithOrder}
          columns={columns}
          defaultSorted={[
            {
              id: 'order',
              desc: true
            }
          ]}
          defaultPageSize={3}
          showPaginationBottom={false}
        />
      </div>
    )
  }
}

export default withNamespaces(['rates', 'admin', 'shipment'])(AdminMarginPreviewMargins)

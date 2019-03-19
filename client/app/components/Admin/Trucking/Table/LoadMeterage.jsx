import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { get } from 'lodash'
import TruckingTableRates from './Rates'
import styles from './index.scss'

class TruckingTableLoadMeterage extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {}
    this.setTarget = this.setTarget.bind(this)
  }

  setTarget (row) {
    this.setState({ targetKey: get(row, ['original', 'key'], false) })
  }

  render () {
    const { t, truckingPricing, pricingName } = this.props
    if (!truckingPricing) { return '' }

    const { targetKey } = this.state
    const data = Object.keys(truckingPricing.load_meterage).map(key => (
      { label: t(`trucking:${key}`), value: truckingPricing.load_meterage[key] }
    ))
    const columns = [
      {
        Header: t('trucking:loadMeterageDetails'),
        columns: [
          {
            accessor: d => d.label,
            id: 'label',
            Cell: row => (
              <div
                className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}
              >
                <p className="flex-none">
                  {row.row.label}
                  {' '}
                </p>
              </div>
            )
          },
          {
            accessor: d => d.value,
            id: 'value',
            Cell: row => (
              <div
                className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}
              >
                <p className="flex-none">
                  {row.row.value || 'N/A'}
                  {' '}
                </p>
              </div>
            )
          }
        ]
      }
    ]
    const headers = (
      <ReactTable
        className="flex-100 height_100"
        data={data}
        columns={columns}
        defaultSorted={[
          {
            id: 'label',
            desc: true
          }
        ]}
        defaultPageSize={data.length}
        showPaginationBottom={false}
      />
    )
    const rates = (
      <TruckingTableRates
        truckingPricing={truckingPricing}
        target={targetKey}
        back={() => this.setTarget(false)}
      />
    )

    return (
      <div className="flex-100 layout-row layout-align-start-start layout-wrap">
        <div className="flex-100 layout-row layout-align-start-center">
          <div
            className={`flex-none layout-row layout-align-start-center ${styles.back_btn}`}
            onClick={this.props.back}
          >
            <i className="fa fa-chevron-left" />
            <p className="flex-none">{t('common:basicBack')}</p>
          </div>
          <div className={`flex-none layout-row layout-align-center-center ${styles.breadcrumb}`}>
            <p className="flex-none">{pricingName}</p>
            <i className="fa fa-angle-double-right" />
          </div>
          <div className={`flex-none layout-row layout-align-center-center ${styles.breadcrumb}`}>
            <p className="flex-none">{t('trucking:loadMeterage')}</p>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-start-start">
          { targetKey ? rates : headers}
        </div>

      </div>
    )
  }
}

export default withNamespaces(['common', 'shipment', 'trucking'])(TruckingTableLoadMeterage)

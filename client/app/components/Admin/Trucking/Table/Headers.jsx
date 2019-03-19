import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { get } from 'lodash'
import TruckingTableFees from './Fees'
import TruckingTableRateHeaders from './RateHeaders'
import TruckingTableLoadMeterage from './LoadMeterage'
import styles from './index.scss'
import { determineDestinationAccessor } from '../../../../helpers'

class TruckingTableHeaders extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      data: [
        { label: 'Load Meterage', key: 'load_meterage' },
        { label: 'Fees', key: 'fees' },
        { label: 'Rates', key: 'rates' }
      ]
    }
    this.determineDataComponent = this.determineDataComponent.bind(this)
  }

  setHeader (row) {
    this.setState({ targetKey: get(row, ['original', 'key'], false) })
  }

  determineDataComponent () {
    const { rowData } = this.props
    const { targetKey } = this.state
    if (!targetKey) { return '' }
    const { truckingPricing } = rowData
    const pricingName = determineDestinationAccessor(rowData)

    switch (targetKey) {
      case 'load_meterage':
        return (
          <TruckingTableLoadMeterage
            truckingPricing={truckingPricing}
            pricingName={pricingName}
            back={() => this.setHeader(false)}
          />
        )
      case 'fees':
        return (
          <TruckingTableFees
            pricingName={pricingName}
            truckingPricing={truckingPricing}
            back={() => this.setHeader(false)}
          />
        )
      case 'rates':
        return (
          <TruckingTableRateHeaders
            pricingName={pricingName}
            truckingPricing={truckingPricing}
            back={() => this.setHeader(false)}
          />
        )

      default:
        return ''
    }
  }

  render () {
    const { t, rowData } = this.props

    const {
      data, targetKey
    } = this.state
    const columns = [
      {
        columns: [
          {

            accessor: d => d.label,
            id: 'label',
            Cell: row => (
              <div
                className={`flex layout-row layout-align-start-center ${styles.pricing_cell}`}
                onClick={() => this.setHeader(row)}
              >
                <p className="flex-none">
                  {row.row.label}
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
        defaultPageSize={3}
        showPaginationBottom={false}
      />
    )
    const backBtn = targetKey ? '' : (
      <div className="flex-100 layout-row layout-align-start-center">
        <div
          className={`flex-none layout-row layout-align-start-center ${styles.back_btn}`}
          onClick={this.props.back}
        >
          <i className="fa fa-chevron-left" />
          <p className="flex-none">{t('common:basicBack')}</p>
        </div>
        <div className={`flex-none layout-row layout-align-center-center ${styles.breadcrumb}`}>
          <p className="flex-none">{determineDestinationAccessor(rowData)}</p>
        </div>
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-align-start-start layout-wrap">
        {backBtn}
        <div className="flex-100 layout-row layout-align-start-start">
          { targetKey ? this.determineDataComponent() : headers}
        </div>

      </div>
    )
  }
}

export default withNamespaces(['common', 'shipment', 'account'])(TruckingTableHeaders)

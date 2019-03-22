import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { get } from 'lodash'
import TruckingTableRates from './Rates'
import styles from './index.scss'

class TruckingTableRateHeaders extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      expanded: {},
      sorted: []
    }
    this.setTarget = this.setTarget.bind(this)
  }

  setTarget (row) {
    this.setState({ targetKey: get(row, ['original', 'key'], false) })
  }

  render () {
    const { t, truckingPricing, pricingName } = this.props
    if (!truckingPricing) { return '' }

    const { targetKey } = this.state

    const data = Object.keys(truckingPricing.rates).map(key => ({ label: t(`trucking:${key}Ranges`), key }))
    const columns = [
      {
        Header: t('trucking:pricingDetails'),
        columns: [
          {

            accessor: d => d.label,
            id: 'label',
            Cell: row => (
              <div
                className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}
                onClick={() => this.setTarget(row)}
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
        expanded={this.state.expanded}
        onExpandedChange={newExpanded => this.setState({ expanded: newExpanded })}
        sorted={this.state.sorted}
        onSortedChange={newSorted => this.setState({ sorted: newSorted })}
        defaultPageSize={data.length}
        showPaginationBottom={false}
      />
    )
    const rates = (
      <TruckingTableRates
        truckingPricing={truckingPricing}
        target={targetKey}
        pricingName={pricingName}
        back={() => this.setTarget(false)}
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
          <p className="flex-none">{pricingName}</p>
          <i className="fa fa-angle-double-right" />
        </div>
        <div className={`flex-none layout-row layout-align-center-center ${styles.breadcrumb}`}>
          <p className="flex-none">{t('trucking:rates')}</p>
        </div>
      </div>
    )


    return (
      <div className="flex-100 layout-row layout-align-start-start layout-wrap">
        {backBtn}
        <div className="flex-100 layout-row layout-align-start-start">
          { targetKey ? rates : headers}
        </div>
      </div>
    )
  }
}

export default withNamespaces(['common', 'shipment', 'trucking'])(TruckingTableRateHeaders)

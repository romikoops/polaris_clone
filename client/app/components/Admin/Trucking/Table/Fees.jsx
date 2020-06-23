import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import styles from './index.scss'
import { determineSortingCaret } from '../../../../helpers/sortingCaret'

class TruckingTableFees extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      expanded: {},
      sorted: []
    }
  }

  render () {
    const { t, truckingPricing, pricingName } = this.props
    const { sorted } = this.state

    const data = Object.values(truckingPricing.fees)

    const columns = [
      {
        columns: [
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('key', sorted)}
              <p className="flex-none">{t('trucking:feeCode')}</p>
            </div>),
            accessor: d => d.key,
            id: 'key',
            minWidth: 50,
            Cell: row => (
              <div className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}>
                <p className="flex-none">
                  {`${row.row.key}`}
                  {' '}
                </p>
              </div>
            )
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('name', sorted)}
              <p className="flex-none">{t('trucking:feeName')}</p>
            </div>),
            accessor: d => d.name,
            id: 'name',
            minWidth: 50,
            Cell: row => (
              <div className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}>
                <p className="flex-none">
                  {`${row.row.name}`}
                  {' '}
                </p>
              </div>
            )
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret(`currency`, sorted)}
              <p className="flex-none">{t('trucking:currency')}</p>
            </div>),
            accessor: d => d.currency,
            id: `currency`,
            maxWidth: 75,
            Cell: row => (
              <div className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}>
                <p className="flex-none">
                  {row.row.currency}
                  {' '}
                </p>
              </div>
            )
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret(`value`, sorted)}
              <p className="flex-none">{t('trucking:value')}</p>
            </div>),
            accessor: d => d.value,
            id: `value`,
            maxWidth: 75,
            Cell: row => (
              <div className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}>
                <p className="flex-none">
                  {row.row.value}
                  {' '}
                </p>
              </div>
            )
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret(`rate_basis`, sorted)}
              <p className="flex-none">{t('trucking:rateBasis')}</p>
            </div>),
            accessor: d => d.rate_basis,
            id: `rate_basis`,
            minWidth: 50,
            Cell: row => (
              <div className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}>
                <p className="flex-none">
                  {row.row.rate_basis}
                  {' '}
                </p>
              </div>
            )
          }
        ]
      }
    ]

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
            <p className="flex-none">{t('trucking:fees')}</p>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-start-start">
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
            defaultPageSize={10}
            showPaginationBottom={false}
          />
        </div>

      </div>
    )
  }
}

export default withNamespaces(['common', 'shipment', 'account'])(TruckingTableFees)

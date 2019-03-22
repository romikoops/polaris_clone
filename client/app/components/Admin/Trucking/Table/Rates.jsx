import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import styles from './index.scss'
import { determineSortingCaret } from '../../../../helpers/sortingCaret'

class TruckingTableRates extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      expanded: {},
      sorted: []
    }
    this.prepData = this.prepData.bind(this)
  }

  prepData () {
    const { truckingPricing, target } = this.props
    const data = truckingPricing.rates[target]
    if (!data) { return [] }

    return data.map((row) => {
      const newRow = { ...row, ...row.rate }
      delete newRow.rate

      return newRow
    })
  }

  render () {
    const { t, target, pricingName } = this.props
    const { sorted } = this.state
    const data = this.prepData()
    const columns = [
      {
        columns: [
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret(`min_${target}`, sorted)}
              <p className="flex-none">{t('trucking:rangeMin')}</p>
            </div>),
            accessor: d => d[`min_${target}`],
            id: `min_${target}`,
            minWidth: 50,
            Cell: row => (
              <div className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}>
                <p className="flex-none">
                  {`${row.row[`min_${target}`]} ${target}`}
                  {' '}
                </p>
              </div>
            )
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret(`max_${target}`, sorted)}
              <p className="flex-none">{t('trucking:rangeMax')}</p>
            </div>),
            accessor: d => d[`max_${target}`],
            id: `max_${target}`,
            minWidth: 50,
            Cell: row => (
              <div className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}>
                <p className="flex-none">
                  {`${row.row[`max_${target}`]} ${target}`}
                  {' '}
                </p>
              </div>
            )
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret(`base`, sorted)}
              <p className="flex-none">{t('trucking:base')}</p>
            </div>),
            accessor: d => d.base,
            id: `base`,
            maxWidth: 50,
            Cell: row => (
              <div className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}>
                <p className="flex-none">
                  {row.row.base}
                  {' '}
                </p>
              </div>
            )
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret(`min`, sorted)}
              <p className="flex-none">{t('trucking:min')}</p>
            </div>),
            accessor: d => d.min_value,
            id: `min`,
            maxWidth: 75,
            Cell: row => (
              <div className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}>
                <p className="flex-none">
                  {row.row.min}
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
            <p className="flex-none">{t('trucking:rates')}</p>
            <i className="fa fa-angle-double-right" />
          </div>
          <div className={`flex-none layout-row layout-align-center-center ${styles.breadcrumb}`}>
            <p className="flex-none">{t(`trucking:${target}Ranges`)}</p>
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

export default withNamespaces(['common', 'shipment', 'account'])(TruckingTableRates)

import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { adminActions, appActions } from '../../../../actions'
import styles from './index.scss'
import { determineSortingCaret } from '../../../../helpers/sortingCaret'
import { capitalize } from '../../../../helpers'

class TruckingRateTable extends PureComponent {
  static determineDestinationAccessor (d) {
    if (d.city) {
      return d.city
    } if (d.zipcode) {
      return d.zipcode
    }
  }

  constructor (props) {
    super(props)
    this.state = {
      expanded: {},
      sorted: []
    }
    this.fetchData = this.fetchData.bind(this)
  }

  fetchData (tableState) {
    const { adminDispatch, hub } = this.props
    debugger
    adminDispatch.viewTrucking({ 
      hubId: hub.id,
      page: tableState.page + 1,
      filters: tableState.filtered,
      pageSize: tableState.pageSize
    })
  }

  

  render () {
    const { t, truckingPricings, pages } = this.props
    if (!truckingPricings) return ''
    const { expanded, sorted } = this.state
    const expandedIndexes = Object.keys(expanded).filter(ex => !!expanded[ex])
    const columns = [
      {
        Header: (<div className="flex layout-row layout-align-space-around-center">
          <p className="flex-none">{t('common:routing')}</p>
        </div>),
        columns: [
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('destination', sorted)}
              <p className="flex-none">{t('shipment:destination')}</p>
            </div>),
            id: 'destination',
            accessor: d => TruckingRateTable.determineDestinationAccessor(d),
            Cell: row => (
              <div className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}>
                <p className="flex-none">
                  {' '}
                  {row.row.destination}
                </p>
              </div>
            )
          }
        ]
      },
      {
        Header: t('account:pricing'),
        columns: [
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('cargo_class', sorted)}
              <p className="flex-none">{t('common:cargoClass')}</p>
            </div>),
            accessor: d => d.truckingPricing.cargo_class,
            id: 'cargo_class',
            Cell: row => (
              <div className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}>
                <p className="flex-none">
                  {row.row.cargo_class}
                  {' '}
                </p>
              </div>
            ),
            Filter: ({ filter, onChange }) =>
              <select
                onChange={event => onChange(event.target.value)}
                style={{ width: "100%" }}
                value={filter ? filter.value : "all"}
              >
                <option value="all">All</option>
                <option value="fcl_20">FTL 20'</option>
                <option value="fcl_40">FTL 40'</option>
                <option value="fcl_40_hq">FTL 40' HQ</option>
                <option value="lcl">Cargo Item</option>
              </select>
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('truck_type', sorted)}
              <p className="flex-none">{t('common:truckType')}</p>
            </div>),
            id: 'truck_type',
            accessor: d => d.truckingPricing.truck_type,
            Cell: row => (
              <div className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}>
                <p className="flex-none">
                  {' '}
                  {row.row.truck_type}
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
          <ReactTable
            className="flex-100 height_100"
            data={truckingPricings}
            columns={columns}
            defaultSorted={[
              {
                id: 'origin_name',
                desc: true
              }
            ]}
            expanded={this.state.expanded}
            onExpandedChange={newExpanded => this.setState({ expanded: newExpanded })}
            sorted={this.state.sorted}
            onSortedChange={newSorted => this.setState({ sorted: newSorted })}
            defaultPageSize={10}
            filterable
            pages={pages}
            manual
            onFetchData={this.fetchData}
            SubComponent={d => (
              <div className={styles.nested_table} />)}
          />
        </div>

      </div>
    )
  }
}

function mapStateToProps (state) {
  const {
    authentication, app, admin
  } = state
  const { tenant } = app
  const { theme } = tenant
  const { user, loggedIn } = authentication
  const { truckingDetail } = admin
  const { truckingPricings, hub, page, pages } = truckingDetail

  return {
    user,
    tenant,
    loggedIn,
    theme,
    truckingPricings,
    hub,
    page,
    pages
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default withNamespaces(['common', 'shipment', 'account'])(connect(mapStateToProps, mapDispatchToProps)(TruckingRateTable))

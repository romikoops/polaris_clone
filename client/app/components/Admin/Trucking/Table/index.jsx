import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { get } from 'lodash'
import TruckingTableHeaders from './Headers'
import { adminActions, appActions, clientsActions } from '../../../../actions'
import { cargoClassOptions } from '../../../../constants'
import TruckingCoverageEditor from '../CoverageEditor'
import styles from './index.scss'
import { determineSortingCaret } from '../../../../helpers/sortingCaret'
import { determineDestinationAccessor } from '../../../../helpers'

class TruckingTable extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expanded: {},
      sorted: [],
      filters: [],
      selectedTruckingPricing: false
    }
    this.fetchData = this.fetchData.bind(this)
    this.viewPricing = this.viewPricing.bind(this)
  }

  componentDidMount () {
    const { clientsDispatch } = this.props
    clientsDispatch.getGroupsForList({
      page: 1, pageSize: 30, targetId: null, targetType: null
    })
  }

  fetchData (tableState) {
    const { adminDispatch, hub, groupId } = this.props
    adminDispatch.viewTrucking({
      hubId: hub.id,
      page: tableState.page + 1,
      filters: tableState.filtered,
      pageSize: tableState.pageSize,
      groupId
    })

    this.setState({ filters: tableState.filtered })
  }

  viewPricing (row) {
    this.setState({ selectedTruckingPricing: row.original }, () => {
      this.props.setTargetTruckingId(get(row, ['original', 'truckingPricing', 'id'], false))
    })
  }


  render () {
    const {
      t, truckingPricings, pages, groups, scope, groupId, toggleEditor
    } = this.props
    if (!truckingPricings) return ''
    const {
      sorted, selectedTruckingPricing, filters
    } = this.state

    const cargoClassFilter = filters.filter(x => x.id === 'cargo_class')[0]
    const groupOptions = [
      <option value="all">All</option>
    ]

    groups.forEach((g) => {
      groupOptions.push(<option value={g.id}>{g.name}</option>)
    })
    let truckOptions
    if (cargoClassFilter && cargoClassFilter.value === 'lcl') {
      truckOptions = [
        <option value="all">All</option>,
        <option value="default">{t('trucking:default')}</option>
      ]
    } else if (!cargoClassFilter) {
      truckOptions = [
        <option value="all">All</option>,
        <option value="default">{t('trucking:default')}</option>,
        <option value="chassis">{t('trucking:chassis')}</option>,
        <option value="side_lifter">{t('trucking:sideLifter')}</option>
      ]
    } else {
      truckOptions = [
        <option value="all">All</option>,
        <option value="chassis">{t('trucking:chassis')}</option>,
        <option value="side_lifter">{t('trucking:sideLifter')}</option>
      ]
    }
    const columns = [
      {

        columns: [
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('destination', sorted)}
              <p className="flex-none">{t('shipment:destination')}</p>
            </div>),
            id: 'destination',
            accessor: d => determineDestinationAccessor(d),
            Cell: row => (
              <div
                className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}
                onClick={() => this.viewPricing(row)}
              >
                <p className="flex-none">
                  {' '}
                  {row.row.destination}
                </p>
              </div>
            )
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('cargo_class', sorted)}
              <p className="flex-none">{t('trucking:cargoClass')}</p>
            </div>),
            accessor: d => d.truckingPricing.cargo_class,
            id: 'cargo_class',
            maxWidth: 120,
            Cell: row => (
              <div
                className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}
                onClick={() => this.viewPricing(row)}
              >
                <p className="flex-none">
                  {row.row.cargo_class}
                  {' '}
                </p>
              </div>
            ),
            Filter: ({ filter, onChange }) => (
              <select
                onChange={event => onChange(event.target.value)}
                style={{ width: '100%' }}
                value={filter ? filter.value : 'all'}
              >
                <option value="all">All</option>
                {cargoClassOptions.map(cc => <option value={cc.value}>{cc.label}</option>)}

              </select>
            )
          },
          scope.base_pricing && !groupId ? {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('group', sorted)}
              <p className="flex-none">{t('common:group')}</p>
            </div>),
            id: 'group',
            maxWidth: 120,
            accessor: d => d.truckingPricing.group_id,
            Cell: row => (
              <div
                className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}
                onClick={() => this.viewPricing(row)}
              >
                <p className="flex-none">
                  {' '}
                  {get(groups.filter(g => g.id === row.row.group)[0], ['name'], '')}
                </p>
              </div>
            ),
            Filter: ({ filter, onChange }) => (
              <select
                onChange={event => onChange(event.target.value)}
                style={{ width: '100%' }}
                value={filter ? filter.value : 'all'}
              >
                {groupOptions}
              </select>
            )
          } : false,
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('truck_type', sorted)}
              <p className="flex-none">{t('common:truckType')}</p>
            </div>),
            id: 'truck_type',
            maxWidth: 120,
            accessor: d => d.truckingPricing.truck_type,
            Cell: row => (
              <div
                className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}
                onClick={() => this.viewPricing(row)}
              >
                <p className="flex-none">
                  {' '}
                  {row.row.truck_type}
                </p>
              </div>
            ),
            Filter: ({ filter, onChange }) => (
              <select
                onChange={event => onChange(event.target.value)}
                style={{ width: '100%' }}
                value={filter ? filter.value : 'all'}
              >
                {truckOptions}
              </select>
            )
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('direction', sorted)}
              <p className="flex-none">{t('trucking:direction')}</p>
            </div>),
            id: 'direction',
            maxWidth: 120,
            accessor: d => d.truckingPricing.carriage,
            Cell: row => (
              <div
                className={`flex layout-row layout-align-start-center ${styles.pricing_cell} `}
                onClick={() => this.viewPricing(row)}
              >
                <p className="flex-none">
                  {' '}
                  {row.row.direction === 'pre' ? 'export' : 'import'}
                </p>
              </div>
            ),
            Filter: ({ filter, onChange }) => (
              <select
                onChange={event => onChange(event.target.value)}
                style={{ width: '100%' }}
                value={filter ? filter.value : 'all'}
              >
                <option value="all">All</option>
                <option value="on">{t('common:import')}</option>
                <option value="pre">{t('common:export')}</option>
              </select>
            )
          }
        ].filter(x => x)
      }
    ]
    const pricingsTable = (
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
        sorted={sorted}
        onSortedChange={newSorted => this.setState({ sorted: newSorted })}
        defaultPageSize={10}
        filterable
        pages={pages}
        manual
        onFetchData={this.fetchData}
      />
    )
    const pricingView = (
      <TruckingTableHeaders
        rowData={selectedTruckingPricing}
        back={() => this.viewPricing(false)}
        toggleEditor={() => toggleEditor()}
      />
    )
   

    const truckingView = selectedTruckingPricing
      ? pricingView
      : pricingsTable

    return (
      <div className={`flex-100 layout-row layout-align-start-start layout-wrap ${styles.wrapper}`}>
        <div className="flex-100 layout-row layout-align-start-start">
          {truckingView}
        </div>

      </div>
    )
  }
}

function mapStateToProps (state) {
  const {
    authentication, app, admin, clients
  } = state
  const { tenant } = app
  const { theme, scope } = tenant
  const { user, loggedIn } = authentication
  const { truckingDetail } = admin
  const {
    truckingPricings, hub, page, pages
  } = truckingDetail
  const { groups } = clients
  const { groupData } = groups || {}

  return {
    user,
    tenant,
    scope,
    loggedIn,
    theme,
    truckingPricings,
    hub,
    page,
    pages,
    groups: groupData
  }
}

TruckingTable.defaultProps = {
  groups: []
}

function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch),
    adminDispatch: bindActionCreators(adminActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default withNamespaces(['common', 'shipment', 'trucking'])(connect(mapStateToProps, mapDispatchToProps)(TruckingTable))

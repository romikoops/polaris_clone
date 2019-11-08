import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { get } from 'lodash'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import styles from '../Admin.scss'
import { adminClicked as clickTip, moment } from '../../../constants'
import { capitalize } from '../../../helpers'
import { adminActions, appActions } from '../../../actions'

export class AdminHubsComp extends Component {
  constructor (props) {
    super(props)
    this.state = {
      page: 1,
      filters: {}
    }

    this.fetchData = this.fetchData.bind(this)
  }


  fetchData (tableState) {
    const { adminDispatch } = this.props
    adminDispatch.getHubs(
      tableState.page + 1,
      tableState.filtered,
      tableState.sorted,
      tableState.pageSize
    )

    this.setState({ filters: tableState.filtered })
  }

  render () {
    const {
      t,
      actionNodes,
      hubs,
      numPages,
      handleClick,
      showLocalExpiry,
      perPage
    } = this.props

    const motOptions = ['air', 'ocean', 'rail', 'truck'].map(mot => ({ label: capitalize(t(`common:${mot}`)), value: mot }))
    const columns = [
      {
        id: 'name',
        Header: t('admin:name'),
        accessor: d => get(d, ['name']),
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => handleClick(rowData.original)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.name}
            </p>
          </div>
        )
      },
      {
        id: 'locode',
        Header: t('admin:locode'),
        accessor: d => get(d, ['hub_code']),
        maxWidth: 100,
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => handleClick(rowData.original)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.locode}
            </p>
          </div>
        )
      },
      {
        id: 'type',
        Header: t('admin:mot'),
        accessor: d => get(d, ['hub_type']),
        maxWidth: 100,
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => handleClick(rowData.original)}
          >
            <p className="flex-none">
              {' '}
              {capitalize(rowData.row.type)}
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
            {motOptions.map(cc => <option value={cc.value}>{cc.label}</option>)}

          </select>
        )
      },
      {
        Header: t('admin:country'),
        id: 'country',
        accessor: d => get(d, ['address', 'country', 'name']),
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => handleClick(rowData.original)}
          >
            <p className="flex-none">
              {' '}
              {capitalize(rowData.row.country)}
            </p>
          </div>
        )
      }
    ]
    if (showLocalExpiry) {
      columns.push({
        Header: t('admin:localChargesExpiring'),
        id: 'earliest_expiration',
        accessor: d => get(d, ['earliest_expiration']),
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => handleClick(rowData.original)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.earliest_expiration ? moment(rowData.row.earliest_expiration).format('ll') : t('admin:noLocalCharges') }
            </p>
          </div>
        ),
        Filter: () => (
          <div />
        )
      })
    }

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-align-space-between-start">
          <div className="layout-row flex flex-sm-100">
            <div className="layout-row flex-100 layout-align-start-center layout-wrap">
              <ReactTable
                className="flex-95 height_100"
                data={hubs}
                columns={columns}
                defaultSorted={[
                  {
                    id: 'name',
                    desc: false
                  }
                ]}
                defaultPageSize={perPage}
                pageSize={perPage}
                filterable
                sortable
                pages={numPages}
                manual
                onFetchData={this.fetchData}
              />

            </div>
          </div>
          {
            actionNodes.length > 0 &&
            (
              <div className="flex-20 hide-sm hide-xs layout-row layout-wrap layout-align-end-end">
                <div className={`${styles.position_fixed_right} flex`}>
                  <div className="flex layout-row margin_bottom">
                    {actionNodes}
                  </div>
                </div>
              </div>
            )
          }
        </div>
      </div>

    )
  }
}

AdminHubsComp.defaultProps = {
  theme: null,
  hubs: [],
  countries: [],
  actionNodes: [],
  handleClick: null,
  tenant: {},
  loading: false,
  showLocalExpiry: true,
  perPage: 15
}

function mapStateToProps (state) {
  const {
    authentication, admin, document, app
  } = state
  const { tenant } = app
  const { theme } = tenant
  const { user, loggedIn } = authentication
  const {
    hubs, hub // eslint-disable-line
  } = admin
  const { hubsData, numPages } = hubs || {}

  return {
    user,
    tenant,
    loggedIn,
    hubs: hubsData,
    theme,
    hub,
    numPages,
    document
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default withNamespaces('admin')(connect(mapStateToProps, mapDispatchToProps)(AdminHubsComp))

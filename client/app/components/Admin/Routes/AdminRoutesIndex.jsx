import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { adminActions, appActions } from '../../../actions'
import styles from '../Admin.scss'
import { capitalize } from '../../../helpers'
import { defaultTablePageSizes, defaultTablePageSize } from '../../../constants'

class AdminRoutesIndex extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {}
    this.fetchData = this.fetchData.bind(this)
    this.viewRoute = this.viewRoute.bind(this)
  }

  fetchData (tableState) {
    const { adminDispatch } = this.props

    adminDispatch.getItineraries(
      tableState.page + 1,
      tableState.filtered,
      tableState.sorted,
      tableState.pageSize
    )

    this.setState({ filters: tableState.filtered })
  }

  viewRoute (id) {
    const { adminDispatch } = this.props
    adminDispatch.goTo(`/admin/routes/${id}`)
  }

  render () {
    const {
      t, itineraries, numPages
    } = this.props
    const motOptions = ['air', 'ocean', 'rail', 'truck'].map(mot => ({ label: capitalize(t(`common:${mot}`)), value: mot }))
    const columns = [
      {
        columns: [
          {
            Header: (<div className="flex layout-row layout-center-center">
              <p className="flex-none">{t('admin:itinerary')}</p>
            </div>),
            id: 'name',
            accessor: d => d.name,
            Cell: rowData => (
              <div 
                className={`pointy flex layout-row layout-align-start-center ${styles.pricing_cell}`}
                onClick={() => this.viewRoute(rowData.original.id)}
              >
                <p className="flex-none">
                  {' '}
                  {rowData.row.name}
                </p>
              </div>
            )
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              <p className="flex-none">{t('admin:transshipmentVia')}</p>
            </div>),
            id: 'transshipment',
            accessor: (d) => d.transshipment,
            Cell: (rowData) => (
              <div
                className={`pointy flex layout-row layout-align-start-center ${styles.pricing_cell}`}
                onClick={() => this.viewRoute(rowData.original.id)}
              >
                <p className="flex-none">
                  {' '}
                  {rowData.row.transshipment}
                </p>
              </div>
            )
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              <p className="flex-none">{t('common:modeOfTransport')}</p>
            </div>),
            id: 'mot',
            accessor: d => d.mode_of_transport,
            Cell: rowData => (
              <div 
                className={`pointy flex layout-row layout-align-start-center ${styles.pricing_cell}`}
                onClick={() => this.viewRoute(rowData.original.id)}
              >
                <p className="flex-none">
                  {capitalize(rowData.row.mot)}
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
                {motOptions.map(cc => <option value={cc.value}>{cc.label}</option>)}

              </select>
            )
          }
        ]
      }
    ]

    return (
      <div className="flex-100 layout-row layout-align-center-start layout-wrap">
        <div className="flex-90 layout-row layout-align-center-center">
          <ReactTable
            className="flex-100 height_100"
            data={itineraries}
            columns={columns}
            defaultSorted={[
              {
                id: 'name',
                desc: true
              }
            ]}
            defaultPageSize={defaultTablePageSize}
            filterable
            sortable={false}
            pageSizeOptions={defaultTablePageSizes}
            pages={numPages}
            manual
            onFetchData={this.fetchData}

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
  const {
    itineraries
  } = admin
  const { itinerariesData, numPages, page } = itineraries || {}

  return {
    user,
    tenant,
    loggedIn,
    theme,
    itineraries: itinerariesData,
    numPages,
    page
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default withNamespaces(['common', 'shipment', 'admin'])(connect(mapStateToProps, mapDispatchToProps)(AdminRoutesIndex))

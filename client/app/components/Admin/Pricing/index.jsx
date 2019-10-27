import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { get } from 'lodash'
import { adminActions, appActions } from '../../../actions'
import styles from './index.scss'
import { capitalize } from '../../../helpers'
import { moment } from '../../../constants'

class AdminPricingList extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {}
    this.fetchData = this.fetchData.bind(this)
  }

  fetchData (tableState) {
    const { adminDispatch } = this.props

    adminDispatch.getPricings({
      page: tableState.page + 1,
      filters: tableState.filtered,
      sorted: tableState.sorted,
      pageSize: tableState.pageSize
    })

    this.setState({ filters: tableState.filtered })
  }

  render () {
    const {
      t, itineraries, numPages, viewPricings
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
                onClick={() => viewPricings(rowData.original)}
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
              <p className="flex-none">{t('common:modeOfTransport')}</p>
            </div>),
            id: 'mot',
            accessor: d => d.modeOfTransport,
            Cell: rowData => (
              <div 
                className={`pointy flex layout-row layout-align-start-center ${styles.pricing_cell}`}
                onClick={() => viewPricings(rowData.original)}
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
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              <p className="flex-none">{t('admin:pricingsSC')}</p>
            </div>),
            maxWidth: 150,
            accessor: 'pricingCount',
            Cell: rowData => (
              <div 
                className={`pointy flex layout-row layout-align-start-center ${styles.pricing_cell}`}
                onClick={() => viewPricings(rowData.original)}
              >
                <p className="flex-none">
                  {rowData.row.pricingCount}
                  {' '}
                </p>
              </div>
            ),
            Filter: () => false
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              <p className="flex-none">{t('admin:nextExpiry')}</p>
            </div>),
            id: 'lastExpiry',
            accessor: d => d.lastExpiry,
            Cell: rowData => (
              <div 
                className={`pointy flex layout-row layout-align-start-center ${styles.pricing_cell}`}
                onClick={() => viewPricings(rowData.original)}
              >
                <p className="flex-none">
                  {' '}
                  {moment(rowData.row.lastExpiry).utc().format('DD/MM/YYYY')}
                </p>
              </div>
            ),
            Filter: () => false
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
                id: 'origin_name',
                desc: true
              }
            ]}
            defaultPageSize={15}
            filterable
            sortable={false}
            pageSizeOptions={[5,10,15,20,25,50]}
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
    pricings
  } = admin
  const { pricingData, numPages, page } = get(pricings, ['index'], {})

  return {
    user,
    tenant,
    loggedIn,
    theme,
    itineraries: pricingData,
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

export default withNamespaces(['common', 'shipment', 'admin'])(connect(mapStateToProps, mapDispatchToProps)(AdminPricingList))

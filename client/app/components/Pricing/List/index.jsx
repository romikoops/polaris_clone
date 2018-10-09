import React, { PureComponent } from 'react'
import { translate } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import PropTypes from '../../../prop-types'
import { userActions, appActions } from '../../../actions'
import PricesTable from './PricesTable'
import shouldBlur from './pricing_helpers'
import styles from './index.scss'
import { determineSortingCaret } from '../../../helpers/sortingCaret'

class PricingList extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      expanded: {},
      sorted: []
    }
  }

  componentDidMount () {
    const { pricings, userDispatch } = this.props
    if (!pricings || (pricings && pricings.index && pricings.index.itineraries.length === 0)) {
      userDispatch.getPricings(false)
    }
  }

  render () {
    const { t, pricings } = this.props
    if (!pricings) return ''
    const { index } = pricings
    const { itineraries } = index
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
              {determineSortingCaret('origin_name', sorted)}
              <p className="flex-none">{t('shipment:origin')}</p>
            </div>),
            id: 'origin_name',
            accessor: d => d.stops[0].hub.nexus.name,
            Cell: row => (<div className={`flex layout-row layout-align-start-center ${shouldBlur(row, expandedIndexes)}`}>
              <p className="flex-none"> {row.row.origin_name}</p>
            </div>)
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('destination_name', sorted)}
              <p className="flex-none">{t('shipment:destination')}</p>
            </div>),
            id: 'destination_name',
            accessor: d => d.stops[1].hub.nexus.name,
            Cell: row => (<div className={`flex layout-row layout-align-start-center ${shouldBlur(row, expandedIndexes)}`}>
              <p className="flex-none"> {row.row.destination_name}</p>
            </div>)
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('mode_of_transport', sorted)}
              <p className="flex-none">{t('common:modeOfTransport')}</p>
            </div>),
            id: 'mode_of_transport',
            accessor: d => d.mode_of_transport,
            Cell: row => (<div className={`flex layout-row layout-align-start-center ${shouldBlur(row, expandedIndexes)}`}>
              <p className="flex-none">{row.row.mode_of_transport} </p>
            </div>)
          }
        ]
      },
      {
        Header: t('account:pricing'),
        columns: [
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('pricing_count', sorted)}
              <p className="flex-none">{t('account:numPricings')}</p>
            </div>),
            accessor: 'pricing_count',
            Cell: row => (<div className={`flex layout-row layout-align-start-center ${shouldBlur(row, expandedIndexes)}`}>
              <p className="flex-none">{row.row.pricing_count} </p>
            </div>)
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('has_user_pricing', sorted)}
              <p className="flex-none">{t('account:dedicated')}</p>
            </div>),
            id: 'has_user_pricing',
            accessor: d => d.has_user_pricing,
            Cell: row => (<div className={`flex layout-row layout-align-start-center ${shouldBlur(row, expandedIndexes)}`}>
              <p className="flex-none"> {row.row.has_user_pricing ? t('common: true') : t('common:false')}</p>
            </div>)
          }
        ]
      }
    ]

    return (
      <div className="flex-100 layout-row layout-align-start-start layout-wrap">
        <div className="flex-100 layout-row layout-align-start-center greyBg">
          <span><b>{t('common:pricings')}</b></span>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">
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
            expanded={this.state.expanded}
            onExpandedChange={newExpanded => this.setState({ expanded: newExpanded })}
            sorted={this.state.sorted}
            onSortedChange={newSorted => this.setState({ sorted: newSorted })}
            defaultPageSize={10}
            SubComponent={d => (
              <div className={styles.nested_table}>
                <PricesTable row={d} />
              </div>)}
          />
        </div>

      </div>
    )
  }
}

PricingList.propTypes = {
  t: PropTypes.func.isRequired,
  pricings: PropTypes.objectOf(PropTypes.any).isRequired,
  userDispatch: PropTypes.objectOf(PropTypes.func).isRequired
}

function mapStateToProps (state) {
  const {
    authentication, tenant, users
  } = state
  const { theme } = tenant.data
  const { user, loggedIn } = authentication
  const {
    pricings
  } = users

  return {
    user,
    tenant,
    loggedIn,
    theme,
    pricings
  }
}
function mapDispatchToProps (dispatch) {
  return {
    userDispatch: bindActionCreators(userActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default translate(['common', 'shipment', 'account'])(connect(mapStateToProps, mapDispatchToProps)(PricingList))

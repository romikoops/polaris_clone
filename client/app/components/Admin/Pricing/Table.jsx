import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import { has } from 'lodash'
import 'react-table/react-table.css'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import PropTypes from '../../../prop-types'
import styles from './index.scss'
import { adminActions, appActions } from '../../../actions'
import AdminFeeTable from './FeeTable'
import AdminRangeFeeTable from './RangeTable'
import { moment } from '../../../constants'
import { determineSortingCaret } from '../../../helpers/sortingCaret'
import { RoundButton } from '../../RoundButton/RoundButton'

class AdminPricesTable extends PureComponent {
  static determineFeeTable (row) {

    if (
      Object.values(row.original.data)
        .filter(val => val.range && val.range.length > 0)
        .length > 0
    ) {
      return (<div className={styles.nested_table}>
        <AdminRangeFeeTable row={row} className={styles.nested_table} />
      </div>)
    }

    return (<div className={styles.nested_table}>
      <AdminFeeTable row={row} className={styles.nested_table} />
    </div>)
  }

  constructor (props) {
    super(props)
    this.state = {
      expanded: {},
      sorted: []
    }
  }

  componentDidMount () {
    const { pricings, adminDispatch, itineraryId } = this.props
    if (!has(pricings, `show.${itineraryId}`)) {
      adminDispatch.getItineraryPricings(itineraryId)
    }
  }

  requestPricing (data) {
    const { adminDispatch, user } = this.props
    const req = {
      pricing_id: data.id,
      tenant_id: data.tenant_id,
      user_id: user.id
    }
    adminDispatch.requestPricing(req)
  }

  render () {
    const {
      t, pricings, theme, itineraryId, cssClasses
    } = this.props
    const { sorted } = this.state

    if (!pricings) return ''
    const { show } = pricings
    if (!show) return ''
    const data = show[itineraryId]
    if (!data) return ''
    const columns = [
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('effectiveDate', sorted)}
          <p className="flex-none">{t('account:effectiveDate')}</p>
        </div>),
        id: 'effectiveDate',
        accessor: d => moment(d.effective_date).format('ll'),
        Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
          <p className="flex-none"> {rowData.row.effectiveDate}</p>
        </div>)
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('expirationDate', sorted)}
          <p className="flex-none">{t('account:expirationDate')}</p>
        </div>),
        id: 'expirationDate',
        accessor: d => moment(d.expiration_date).format('ll'),
        Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
          <p className="flex-none"> {rowData.row.expirationDate}</p>
        </div>)
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('carrier', sorted)}
          <p className="flex-none">{t('account:carrier')}</p>
        </div>),
        id: 'carrier',
        accessor: d => d.carrier,
        Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
          <p className="flex-none"> {rowData.row.carrier}</p>
        </div>)
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('service_level', sorted)}
          <p className="flex-none">{t('shipment:serviceLevel')}</p>
        </div>),
        id: 'service_level',
        accessor: d => d.service_level,
        Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
          <p className="flex-none"> {rowData.row.service_level}</p>
        </div>)
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('cargo_class', sorted)}
          <p className="flex-none">{t('account:loadType')}</p>
        </div>),
        accessor: 'cargo_class',
        Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
          <p className="flex-none"> {t(`common:${rowData.row.cargo_class}`)}</p>
        </div>)
      }
    ]

    return (
      <ReactTable
        className={`${styles.no_footer} ${cssClasses}`}
        data={data.pricings}
        columns={columns}
        defaultSorted={[
          {
            id: 'carrier',
            desc: true
          }
        ]}
        defaultPageSize={data.pricings.length}
        showPaginationBottom={false}
        expanded={this.state.expanded}
        sorted={this.state.sorted}
        onSortedChange={newSorted => this.setState({ sorted: newSorted })}
        onExpandedChange={newExpanded => this.setState({ expanded: newExpanded })}
        SubComponent={subRow => AdminPricesTable.determineFeeTable(subRow)}
      />
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
    adminDispatch: bindActionCreators(adminActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default withNamespaces(['common', 'shipment', 'account'])(connect(mapStateToProps, mapDispatchToProps)(AdminPricesTable))

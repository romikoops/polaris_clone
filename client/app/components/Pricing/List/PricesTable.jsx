import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import { has } from 'lodash'
import 'react-table/react-table.css'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import PropTypes from '../../../prop-types'
import styles from './index.scss'
import { userActions, appActions } from '../../../actions'
import FeeTable from './FeeTable'
import RangeFeeTable from './RangeFeeTable'
import { moment } from '../../../constants'
import { determineSortingCaret } from '../../../helpers/sortingCaret'
import { RoundButton } from '../../RoundButton/RoundButton'

class PricesTable extends PureComponent {
  static determineFeeTable (row) {
    if (
      Object.values(row.original.data)
        .filter(val => val.range && val.range.length > 0)
        .length > 0
    ) {
      return (<div className={styles.nested_table}>
        <RangeFeeTable row={row} className={styles.nested_table} />
      </div>)
    }

    return (<div className={styles.nested_table}>
      <FeeTable row={row} className={styles.nested_table} />
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
    const { pricings, userDispatch, row } = this.props
    if (!has(pricings, `show.${row.original.id}`)) {
      userDispatch.getPricingsForItinerary(row.original.id)
    }
  }

  requestPricing (data) {
    const { userDispatch, user } = this.props
    const req = {
      pricing_id: data.id,
      tenant_id: data.tenant_id,
      user_id: user.id
    }
    userDispatch.requestPricing(req)
  }

  render () {
    const {
      t, pricings, row, theme
    } = this.props
    const { sorted } = this.state

    if (!pricings) return ''
    const { show } = pricings
    if (!show) return ''
    const data = show[row.original.id]
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
          {determineSortingCaret('load_type', sorted)}
          <p className="flex-none">{t('account:loadType')}</p>
        </div>),
        accessor: 'load_type',
        Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
          <p className="flex-none"> {t(`common:${rowData.row.load_type}`)}</p>
        </div>)
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('dedicated', sorted)}
          <p className="flex-none">{t('account:dedicated')}</p>
        </div>),
        id: 'dedicated',
        accessor: d => d.user_id,
        Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-center-center`}>
          {!rowData.original.user_id && !rowData.original.requested
            ? <RoundButton
              theme={theme}
              size="full"
              active
              handleNext={() => this.requestPricing(rowData.original)}
              text={t('account:request')}
            /> : ''}
          {!rowData.original.user_id && rowData.original.requested ? t('common:requested') : ''}
          {rowData.original.user_id ? t('common:yes') : '' }
        </div>)
      }
    ]

    return (
      <ReactTable
        className={styles.no_footer}
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
        SubComponent={subRow => PricesTable.determineFeeTable(subRow)}
      />
    )
  }
}

PricesTable.propTypes = {
  t: PropTypes.func.isRequired,
  pricings: PropTypes.objectOf(PropTypes.any).isRequired,
  row: PropTypes.objectOf(PropTypes.any).isRequired,
  userDispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  user: PropTypes.objectOf(PropTypes.user).isRequired,
  theme: PropTypes.objectOf(PropTypes.theme).isRequired
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

export default withNamespaces(['common', 'shipment', 'account'])(connect(mapStateToProps, mapDispatchToProps)(PricesTable))

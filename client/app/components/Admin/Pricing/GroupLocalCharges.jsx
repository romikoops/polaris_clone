import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import matchSorter from 'match-sorter'
import { has, get } from 'lodash'
import 'react-table/react-table.css'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import styles from './index.scss'
import { adminActions, appActions, clientsActions } from '../../../actions'
import AdminFeeTable from './FeeTable'
import AdminRangeFeeTable from './RangeTable'
import { moment } from '../../../constants'
import { determineSortingCaret } from '../../../helpers/sortingCaret'
import AdminPromptConfirm from '../Prompt/Confirm'

class AdminPricesGroupLocalCharges extends PureComponent {
  static determineFeeTable (row) {
    if (
      Object.values(row.original.fees)
        .some(val => val.range && val.range.length > 0)
    ) {
      return (
        <div className={styles.nested_table}>
          <AdminRangeFeeTable row={row.original.fees} className={styles.nested_table} isLocalCharge />
        </div>
      )
    }

    return (
      <div className={styles.nested_table}>
        <AdminFeeTable row={row.original.fees} className={styles.nested_table} isLocalCharge />
      </div>
    )
  }

  constructor (props) {
    super(props)
    this.state = {
      expanded: {},
      sorted: [],
      confirm: false,
      confirmAction: false
    }
    this.fetchData = this.fetchData.bind(this)
  }

  componentDidMount () {
    const { clientsDispatch, groupId } = this.props
    clientsDispatch.getLocalChargesForList({ groupId })
  }

  deleteLocalCharge () {
    const { adminDispatch } = this.props
    const { pricingToDelete } = this.state
    adminDispatch.deleteLocalCharge(pricingToDelete)
    this.closeConfirm()
  }

  onConfirm () {
    const { confirmAction } = this.state
    switch (confirmAction) {
      case 'delete':
        return this.deleteLocalCharge()
      default:
        break
    }
  }

  fetchData (tableState) {
    const { clientsDispatch, groupId } = this.props

    clientsDispatch.getLocalChargesForList({
      page: tableState.page + 1,
      filters: tableState.filtered,
      sorted: tableState.sorted,
      pageSize: tableState.pageSize,
      groupId
    })

    this.setState({ filters: tableState.filtered })
  }

  confirmDialog (action, pricing) {
    this.setState({
      confirm: true,
      confirmAction: action,
      pricingToDelete: pricing
    })
  }

  closeConfirm () {
    this.setState({ confirm: false, pricingToDelete: false, confirmAction: false })
  }


  render () {
    const {
      t, localCharges, theme, groupId, classNames, scope
    } = this.props
    const { sorted, confirm, confirmAction } = this.state

    const { localChargeData, numPages, page, per_page } = localCharges
    if (!localChargeData) return ''
    const columns = [
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('effectiveDate', sorted)}
          <p className="flex-none">{t('account:effectiveDate')}</p>
        </div>),
        id: 'effectiveDate',
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ['effectiveDate'] }),
        filterAll: true,
        accessor: d => moment(d.effective_date).utc().format('ll'),
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {rowData.row.effectiveDate}
            </p>
          </div>
        )
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('expirationDate', sorted)}
          <p className="flex-none">{t('account:expirationDate')}</p>
        </div>),
        id: 'expirationDate',
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ['expirationDate'] }),
        filterAll: true,
        accessor: d => moment(d.expiration_date).utc().format('ll'),
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {rowData.row.expirationDate}
            </p>
          </div>
        )
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('hub_name', sorted)}
          <p className="flex-none">{t('admin:hub')}</p>
        </div>),
        id: 'hub_name',
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ['hub_name'] }),
        filterAll: true,
        accessor: d => d.hub_name,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {rowData.row.hub_name || '-'}
            </p>
          </div>
        )
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('counterpart_hub_name', sorted)}
          <p className="flex-none">{t('admin:destination')}</p>
        </div>),
        id: 'counterpart_hub_name',
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ['counterpart_hub_name'] }),
        filterAll: true,
        accessor: d => d.counterpart_hub_name,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {rowData.row.counterpart_hub_name || '-'}
            </p>
          </div>
        )
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('mode_of_transport', sorted)}
          <p className="flex-none">{t('admin:modeOfTransport')}</p>
        </div>),
        id: 'mode_of_transport',
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ['mode_of_transport'] }),
        filterAll: true,
        accessor: d => d.mode_of_transport,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {rowData.row.mode_of_transport || '-'}
            </p>
          </div>
        )
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('carrier_name', sorted)}
          <p className="flex-none">{t('admin:carrier')}</p>
        </div>),
        id: 'carrier_name',
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ['carrier_name'] }),
        filterAll: true,
        accessor: d => d.carrier_name,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {rowData.row.carrier_name || '-'}
            </p>
          </div>
        )
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('service_level', sorted)}
          <p className="flex-none">{t('shipment:serviceLevel')}</p>
        </div>),
        id: 'service_level',
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ['service_level'] }),
        filterAll: true,
        accessor: d => d.service_level,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {rowData.row.service_level}
            </p>
          </div>
        )
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('load_type', sorted)}
          <p className="flex-none">{t('admin:loadType')}</p>
        </div>),
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ['load_type'] }),
        filterAll: true,
        accessor: 'load_type',
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {t(`common:${rowData.row.load_type}`)}
            </p>
          </div>
        )
      },
      {
        maxWidth: 75,
        Header: (<div className="flex layout-row layout-center-center">
          <p className="flex-none">{t('common:delete')}</p>
        </div>),
        Cell: rowData => (
          <div
            onClick={() => this.confirmDialog('delete', rowData.original.id)}
            className={`${styles.delete_cell} flex layout-row layout-align-center-center pointy`}
          >
            <i className="flex-none fa fa-trash" />
          </div>
        )
      }
    ].filter(x => !!x)

    const confirmDeletePrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading={t('common:areYouSure')}
        text={t('admin:confirmDeleteLocalChargeImmediately')}
        confirm={() => this.onConfirm()}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )

    return (
      <div className="flex-100 layout-row layout-align-center-start">
        {confirmDeletePrompt}
        <ReactTable
          className={`${styles.no_footer} ${classNames}`}
          data={localChargeData}
          defaultFilterMethod={(filter, row) => String(row[filter.id]) === filter.value}
          columns={columns}
          defaultSorted={[
            {
              id: 'carrier',
              desc: true
            }
          ]}
          defaultPageSize={per_page}
          showPaginationBottom={false}
          expanded={this.state.expanded}
          defaultPageSize={10}
          filterable
          pages={numPages}
          manual
          onFetchData={this.fetchData}
          onExpandedChange={newExpanded => this.setState({ expanded: newExpanded })}
          SubComponent={subRow => AdminPricesGroupLocalCharges.determineFeeTable(subRow)}
        />
      </div>
    )
  }
}

AdminPricesGroupLocalCharges.defaultProps = {
  classNames: 'flex-100',
  localCharges: {}
}

function mapStateToProps (state) {
  const {
    authentication, app, clients
  } = state
  const { tenant } = app
  const { theme, scope } = tenant
  const { user, loggedIn } = authentication
  const {
    localCharges
  } = clients

  return {
    user,
    tenant,
    loggedIn,
    theme,
    scope,
    localCharges
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    clientsDispatch: bindActionCreators(clientsActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default withNamespaces(['common', 'shipment', 'account'])(connect(mapStateToProps, mapDispatchToProps)(AdminPricesGroupLocalCharges))

import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import matchSorter from 'match-sorter'
import { has, get } from 'lodash'
import 'react-table/react-table.css'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import styles from './index.scss'
import { adminActions, appActions } from '../../../actions'
import AdminFeeTable from './FeeTable'
import AdminRangeFeeTable from './RangeTable'
import { moment } from '../../../constants'
import { determineSortingCaret } from '../../../helpers/sortingCaret'
import AdminPromptConfirm from '../Prompt/Confirm'
import Checkbox from '../../Checkbox/Checkbox'

class AdminPricesGroupTable extends PureComponent {
  static determineFeeTable (row) {
    if (
      Object.values(row.original.data)
        .some(val => val.range && val.range.length > 0)
    ) {
      return (
        <div className={styles.nested_table}>
          <AdminRangeFeeTable row={row} className={styles.nested_table} />
        </div>
      )
    }

    return (
      <div className={styles.nested_table}>
        <AdminFeeTable row={row} className={styles.nested_table} />
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
  }

  componentDidMount () {
    const { pricings, adminDispatch, groupId } = this.props
    // if (!has(pricings, `groups.${groupId}`)) {
    adminDispatch.getGroupPricings(groupId)
    // }
  }

  deletePricing () {
    const { adminDispatch } = this.props
    const { pricingToDelete } = this.state
    adminDispatch.deletePricing(pricingToDelete)
    this.closeConfirm()
  }

  onConfirm () {
    const { confirmAction } = this.state
    switch (confirmAction) {
      case 'delete':
        return this.deletePricing()
      case 'disable':
        return this.toggleDisabled(confirmAction)
      case 'enable':
        return this.toggleDisabled(confirmAction)

      default:
        break
    }
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

  requestPricing (data) {
    const { adminDispatch, user } = this.props
    const req = {
      pricing_id: data.id,
      tenant_id: data.tenant_id,
      user_id: user.id
    }
    adminDispatch.requestPricing(req)
  }

  toggleDisabled (action) {
    const { adminDispatch } = this.props
    const { pricingToDelete } = this.state
    const req = {
      pricing_id: pricingToDelete.id,
      tenant_id: pricingToDelete.tenant_id,
      action
    }
    adminDispatch.disablePricing(req)
    this.closeConfirm()
  }

  render () {
    const {
      t, pricings, theme, groupId, classNames, scope
    } = this.props
    const { sorted, confirm, confirmAction } = this.state

    const data = get(pricings, ['groups', groupId], false)
    if (!data) return ''
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
          {determineSortingCaret('itinerary_name', sorted)}
          <p className="flex-none">{t('admin:itinerary')}</p>
        </div>),
        id: 'itinerary_name',
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ['itinerary_name'] }),
        filterAll: true,
        accessor: d => d.itinerary_name,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {rowData.row.itinerary_name || '-'}
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
          {determineSortingCaret('carrier', sorted)}
          <p className="flex-none">{t('admin:carrier')}</p>
        </div>),
        id: 'carrier',
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ['carrier'] }),
        filterAll: true,
        accessor: d => d.carrier,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {rowData.row.carrier || '-'}
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
          {determineSortingCaret('cargo_class', sorted)}
          <p className="flex-none">{t('account:loadType')}</p>
        </div>),
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ['cargo_class'] }),
        filterAll: true,
        accessor: 'cargo_class',
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {t(`common:${rowData.row.cargo_class}`)}
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
            onClick={() => this.confirmDialog('delete', rowData.original)}
            className={`${styles.delete_cell} flex layout-row layout-align-center-center pointy`}
          >
            <i className="flex-none fa fa-trash" />
          </div>
        )
      }
    ].filter(x => !!x)
    let confirmText
    switch (confirmAction) {
      case 'delete':
        confirmText = t('admin:confirmDeletePricingImmediately')
        break
      case 'disable':
        confirmText = t('admin:confirmDisablePricingImmediately')
        break
      case 'enable':
        confirmText = t('admin:confirmEnablePricingImmediately')
        break

      default:
        break
    }
    const confirmDeletePrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading={t('common:areYouSure')}
        text={confirmText}
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
          data={data.pricings}
          filterable
          defaultFilterMethod={(filter, row) => String(row[filter.id]) === filter.value}
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
          SubComponent={subRow => AdminPricesGroupTable.determineFeeTable(subRow)}
        />
      </div>
    )
  }
}

AdminPricesGroupTable.defaultProps = {
  classNames: 'flex-100'
}

function mapStateToProps (state) {
  const {
    authentication, app, admin
  } = state
  const { tenant } = app
  const { theme, scope } = tenant
  const { user, loggedIn } = authentication
  const {
    pricings
  } = admin

  return {
    user,
    tenant,
    loggedIn,
    theme,
    scope,
    pricings
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default withNamespaces(['common', 'shipment', 'account'])(connect(mapStateToProps, mapDispatchToProps)(AdminPricesGroupTable))

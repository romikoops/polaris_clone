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

class AdminPricesTable extends PureComponent {
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
      confirm: false
    }
  }

  componentDidMount () {
    const { pricings, adminDispatch, itineraryId } = this.props
    if (!has(pricings, `show.${itineraryId}`)) {
      adminDispatch.getItineraryPricings(itineraryId)
    }
  }
  
  deletePricing () {
    const { adminDispatch } = this.props
    const { pricingToDelete } = this.state
    adminDispatch.deletePricing(pricingToDelete)
    this.closeConfirm()
  }

  confirmDelete (pricing) {
    this.setState({
      confirm: true,
      pricingToDelete: pricing
    })
  }

  closeConfirm () {
    this.setState({ confirm: false, pricingToDelete: false })
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
      t, pricings, theme, itineraryId, classNames
    } = this.props
    const { sorted, confirm } = this.state

    const data = get(pricings, ['show', itineraryId], false)
    if (!data) return ''
    const columns = [
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('userEmail', sorted)}
          <p className="flex-none">{t('account:userEmail')}</p>
        </div>),
        id: 'userEmail',
        accessor: d => d.user_email,
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ["userEmail"] }),
        filterAll: true,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex-100 layout-row layout-align-start-center`}>
            <p className="flex-100">
              {rowData.row.userEmail || '-'}
            </p>
          </div>
        )
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('effectiveDate', sorted)}
          <p className="flex-none">{t('account:effectiveDate')}</p>
        </div>),
        id: 'effectiveDate',
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ["effectiveDate"] }),
        filterAll: true,
        accessor: d => moment(d.effective_date).format('ll'),
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
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ["expirationDate"] }),
        filterAll: true,
        accessor: d => moment(d.expiration_date).format('ll'),
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
          {determineSortingCaret('carrier', sorted)}
          <p className="flex-none">{t('account:carrier')}</p>
        </div>),
        id: 'carrier',
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ["carrier"] }),
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
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ["service_level"] }),
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
        filterMethod: (filter, rows) => matchSorter(rows, filter.value, { keys: ["cargo_class"] }),
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
        maxWidth: 50,
        Cell: rowData => (
          <div
            onClick={() => this.confirmDelete(rowData.original)}
            className={`${styles.delete_cell} flex layout-row layout-align-center-center pointy`}
          >
            <i className="flex-none fa fa-trash"></i>
          </div>
        )
      }
    ]
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading={t('common:areYouSure')}
        text={t('admin:confirmDeletePricingImmediately')}
        confirm={() => this.deletePricing()}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )

    return (
      <div className="flex-100 layout-row layout-align-center-start">
        {confimPrompt}
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
          SubComponent={subRow => AdminPricesTable.determineFeeTable(subRow)}
        />
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

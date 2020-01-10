import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import PropTypes from '../../../prop-types'
import styles from './index.scss'
import { adminActions, appActions } from '../../../actions'
import { determineSortingCaret } from '../../../helpers/sortingCaret'

class AdminFeeTable extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      sorted: []
    }
  }

  determineStringToRender (value, target) {
    const { scope } = this.props.tenant
    if (!scope) return value
    if (scope.cargo_price_notes && scope.cargo_price_notes.cargo && target === 'rate') {
      return scope.cargo_price_notes.cargo
    } if (scope.cargo_price_notes && scope.cargo_price_notes.cargo && target === 'min') {
      return ''
    }

    return value
  }

  render () {
    const {
      t, row, tenant, isLocalCharge, classes
    } = this.props

    if (!row) return ''
    const { scope } = tenant
    const { sorted } = this.state
    const localChargeKeys = []
    const data = Object.keys(row).map((k) => {
      const tempFee = row[k]
      tempFee.feeCode = k
      if (isLocalCharge) {
        Object.keys(tempFee)
          .filter(key => !['currency', 'feeCode', 'name', 'key', 'rate_basis'].includes(key))
          .forEach((key) => {
            if (!localChargeKeys.includes(key)) {
              localChargeKeys.push(key)
            }
          })
      }

      return tempFee
    })

    const columns = [
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('fee_code', sorted)}
          <p className="flex-none">{t('common:feeCode')}</p>
        </div>),
        id: 'fee_code',
        accessor: d => d.feeCode,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {rowData.row.fee_code}
            </p>
          </div>
        )
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('rate_basis', sorted)}
          <p className="flex-none">{t('common:rateBasis')}</p>
        </div>),
        id: 'rate_basis',
        accessor: d => d.rate_basis,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {rowData.row.rate_basis}
            </p>
          </div>
        )
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('currency', sorted)}
          <p className="flex-none">{t('common:currency')}</p>
        </div>),
        id: 'currency',
        accessor: d => d.currency,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {rowData.row.currency}
            </p>
          </div>
        )
      }
    ]

    const feeColumns = [
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('rate', sorted)}
          <p className="flex-none">{t('common:rate')}</p>
        </div>),
        id: 'rate',
        style: { 'white-space': 'unset' },
        accessor: d => d.rate,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex-100 layout-row layout-align-start-center`}>
            <p className="flex-100">
              {this.determineStringToRender(rowData.row.rate, 'rate')}
            </p>
          </div>
        )
      }
    ]
    const localChargeColumns = localChargeKeys.map(k => (
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret(k, sorted)}
          <p className="flex-none">{t(`common:${k}`)}</p>
        </div>),
        id: k,
        style: { 'white-space': 'unset' },
        accessor: d => d[k],
        maxWidth: 75,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex-100 layout-row layout-align-start-center`}>
            <p className="flex-100">
              {this.determineStringToRender(rowData.row[k], k)}
            </p>
          </div>
        )
      }
    ))
    const feeRenderColumns = isLocalCharge ? localChargeColumns : feeColumns
    feeRenderColumns.forEach(col => columns.push(col))

    if ((scope && !scope.cargo_price_notes) || (scope && scope.cargo_price_notes && !scope.cargo_price_notes.cargo)) {
      columns.push({
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('min', sorted)}
          <p className="flex-none">{t('common:minimum')}</p>
        </div>),
        id: 'min',
        accessor: d => d.min,
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
            <p className="flex-none">
              {' '}
              {this.determineStringToRender(rowData.row.min, 'min')}
            </p>
          </div>
        )
      })
    }

    return (
      <ReactTable
        className={`${styles.no_footer} ${classes}`}
        data={data}
        columns={columns}
        defaultSorted={[
          {
            id: 'feeCode',
            desc: true
          }
        ]}
        showPaginationBottom={false}
        sorted={this.state.sorted}
        onSortedChange={newSorted => this.setState({ sorted: newSorted })}
        defaultPageSize={data.length}
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

AdminFeeTable.defaultProps = {
  classes: ''
}

export default withNamespaces(['common'])(connect(mapStateToProps, mapDispatchToProps)(AdminFeeTable))

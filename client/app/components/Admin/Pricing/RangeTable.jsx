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

class AdminRangeFeeTable extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      sorted: [],
      innerSorted: []
    }
  }

  determineStringToRender (value, target) {
    const { scope } = this.props.tenant
    if (!scope) return value
    if (scope.cargo_price_notes && scope.cargo_price_notes.cargo && target === 'rate') {
      return scope.cargo_price_notes.cargo
    } 
    if (scope.cargo_price_notes && scope.cargo_price_notes.cargo && target === 'min') {
      return ''
    }

    return value
  }

  render () {
    const { t, row, isLocalCharge } = this.props
    if (!row || (row && !row.original)) return ''
    const { sorted, innerSorted } = this.state
    const fees = row.original.data
    if (!fees) return ''
    
    const localChargeKeys = []
    const data = Object.keys(fees).map((k) => {
      const tempFee = fees[k]
      tempFee.feeCode = k
      if (isLocalCharge) {
        Object.keys(tempFee)
          .filter(k => !['currency', 'feeCode', 'name', 'key', 'rate_basis'].includes(k))
          .forEach((k) => {
            if (!localChargeKeys.includes(k)) {
              localChargeKeys.push(k)
            }
          })
      }

      return tempFee
    })
    const cellClass = styles.pricing_cell
    const columns = [
      {
        expander: true,
        Header: () => <strong>More</strong>,
        width: 65,
        Expander: ({ isExpanded, ...rest }) => {
          if (rest.original.range) {
            return (
              <div>
                {isExpanded
                  ? <div><i className="fa fa-caret-up" /></div>
                  : <div><i className="fa fa-caret-right" /></div>
                }
              </div>
            )
          }

          return null
        }
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('fee_code', sorted)}
          <p className="flex-none">{t('common:feeCode')}</p>
        </div>),
        id: 'fee_code',
        className: cellClass,
        accessor: d => d.feeCode,
        Cell: rowData => (
          <div className=" flex layout-row layout-align-start-center">
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
        className: cellClass,
        id: 'rate_basis',
        accessor: d => d.rate_basis,
        Cell: rowData => (
          <div className=" flex layout-row layout-align-start-center">
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
        className: cellClass,
        id: 'currency',
        accessor: d => d.currency,
        Cell: rowData => (
          <div className=" flex layout-row layout-align-start-center">
            <p className="flex-none">
                        {' '}
              {rowData.row.currency}
            </p>
          </div>
        )
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('min', sorted)}
          <p className="flex-none">{t('common:minimum')}</p>
        </div>),
        id: 'min',
        className: cellClass,
        accessor: d => d.min,
        Cell: rowData => (
          <div className=" flex layout-row layout-align-start-center">
            <p className="flex-none">
              {' '}
              {rowData.row.min}
                      </p>
          </div>
        )
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('rate', sorted)}
          <p className="flex-none">{t('common:rate')}</p>
        </div>),
        id: 'rate',
        className: cellClass,
        style: { 'white-space': 'unset' },
        accessor: d => d.rate,
        Cell: rowData => (
          <div className=" flex-100 layout-row layout-align-start-center">
            <p className="flex-100">
                        {this.determineStringToRender(rowData.row.rate, 'rate')}
                      </p>
          </div>
        )
      }
    ]
    const rangeColumns = [
      {
        columns: [
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('min', innerSorted)}
              <p className="flex-none">{t('common:minimum')}</p>
            </div>),
            id: 'min',
            className: cellClass,
            accessor: d => d.min,
            Cell: rowData => (
              <div className=" flex layout-row layout-align-start-center">
                <p className="flex-none">
                  {' '}
                  {rowData.row.min}
                </p>
              </div>
            )
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('max', innerSorted)}
              <p className="flex-none">{t('common:max')}</p>
            </div>),
            id: 'max',
            className: cellClass,
            accessor: d => d.max,
            Cell: rowData => (
              <div className=" flex layout-row layout-align-start-center">
                <p className="flex-none">
                  {' '}
                  {rowData.row.max}
                </p>
              </div>
            )
          }
        ]
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
    const localChargeColumns = localChargeKeys ? localChargeKeys.map(k => (
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret(k, sorted)}
          <p className="flex-none">{t('common:rate')}</p>
        </div>),
        id: k,
        style: { 'white-space': 'unset' },
        accessor: d => d[k],
        Cell: rowData => (
          <div className={`${styles.pricing_cell} flex-100 layout-row layout-align-start-center`}>
            <p className="flex-100">
              {this.determineStringToRender(rowData.row[k], k)}
            </p>
          </div>
        )
      }
    )) : []
    const feeRenderColumns = isLocalCharge ? localChargeColumns : feeColumns
    feeRenderColumns.forEach(col => rangeColumns.push(col))

    return (
      <ReactTable
        data={data}
        columns={columns}
        expanded={this.state.expanded}
        sorted={this.state.sorted}
        onSortedChange={newSorted => this.setState({ sorted: newSorted })}
        showPaginationBottom={false}
        onExpandedChange={newExpanded => this.setState({ expanded: newExpanded })}
        defaultSorted={[
          {
            id: 'feeCode',
            desc: true
          }
        ]}
        getTdProps={(state, rowInfo, column, instance) => ({
          onClick: (e, handleOriginal) => {
            if (handleOriginal && !rowInfo.original.range && column.expander) {
              null
            } else {
              handleOriginal()
            }
          }
        })}
        defaultPageSize={data.length}
        SubComponent={d => (d.original.range ? (
          <div className={styles.nested_table}>
            <ReactTable
              data={d.original.range}
              columns={rangeColumns}
              sorted={this.state.innerSorted}
              onSortedChange={newSorted => this.setState({ innerSorted: newSorted })}
              showPaginationBottom={false}
              defaultSorted={[
                {
                  id: 'min',
                  asc: true
                }
              ]}
              defaultPageSize={d.original.range.length}
            />
          </div>
        ) : '')}
      />
    )
  }
}

AdminRangeFeeTable.propTypes = {
  t: PropTypes.func.isRequired,
  row: PropTypes.objectOf(PropTypes.any).isRequired
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

export default withNamespaces(['common'])(connect(mapStateToProps, mapDispatchToProps)(AdminRangeFeeTable))

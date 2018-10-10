import React, { PureComponent } from 'react'
import { translate } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import PropTypes from '../../../prop-types'
import styles from './index.scss'
import { userActions, appActions } from '../../../actions'
import { determineSortingCaret } from '../../../helpers/sortingCaret'

class RangeFeeTable extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      sorted: [],
      innerSorted: []
    }
  }

  render () {
    const { t, row } = this.props
    if (!row || (row && !row.original)) return ''
    const { sorted, innerSorted } = this.state
    const fees = row.original.data
    if (!fees) return ''

    const data = Object.keys(fees).map((k) => {
      const tempFee = fees[k]
      tempFee.feeCode = k

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
        Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
          <p className="flex-none"> {rowData.row.fee_code}</p>
        </div>)
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('rate_basis', sorted)}
          <p className="flex-none">{t('common:rateBasis')}</p>
        </div>),
        id: 'rate_basis',
        accessor: d => d.rate_basis,
        Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
          <p className="flex-none"> {rowData.row.rate_basis}</p>
        </div>)
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('currency', sorted)}
          <p className="flex-none">{t('common:currency')}</p>
        </div>),
        id: 'currency',
        accessor: d => d.currency,
        Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
          <p className="flex-none"> {rowData.row.currency}</p>
        </div>)
      },
      {
        Header: (<div className="flex layout-row layout-center-center">
          {determineSortingCaret('min', sorted)}
          <p className="flex-none">{t('common:minimum')}</p>
        </div>),
        id: 'min',
        accessor: d => d.min,
        Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
          <p className="flex-none"> {rowData.row.min}</p>
        </div>)
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
            accessor: d => d.min,
            Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
              <p className="flex-none"> {rowData.row.min}</p>
            </div>)
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('max', innerSorted)}
              <p className="flex-none">{t('common:max')}</p>
            </div>),
            id: 'max',
            accessor: d => d.max,
            Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
              <p className="flex-none"> {rowData.row.max}</p>
            </div>)
          },
          {
            Header: (<div className="flex layout-row layout-center-center">
              {determineSortingCaret('rate', innerSorted)}
              <p className="flex-none">{t('common:rate')}</p>
            </div>),
            id: 'rate',
            accessor: d => d.rate,
            Cell: rowData => (<div className={`${styles.pricing_cell} flex layout-row layout-align-start-center`}>
              <p className="flex-none"> {rowData.row.rate}</p>
            </div>)
          }
        ]
      }
    ]

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
        defaultPageSize={data.length}
        SubComponent={d => (
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
        )}
      />
    )
  }
}

RangeFeeTable.propTypes = {
  t: PropTypes.func.isRequired,
  row: PropTypes.objectOf(PropTypes.any).isRequired
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

export default translate(['common'])(connect(mapStateToProps, mapDispatchToProps)(RangeFeeTable))

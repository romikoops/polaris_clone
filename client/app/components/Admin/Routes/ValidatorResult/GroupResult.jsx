import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import styles from './index.scss'
import ValidatorResult from './Result'
import CollapsingBar from '../../../CollapsingBar/CollapsingBar'

export class ValidatorGroupResult extends Component {
  static rowStatus (rowData) {
    const resultBool = ValidatorGroupResult.rowChecker(rowData)

    return resultBool ? (<i className={`flex-none fa fa-check-circle-o ${styles.icon_ok}`} />) : (<i className={`flex-none fa fa-exclamation-triangle ${styles.icon_warning}`} />)
  }

  static rowChecker (rowData) {
    const nonResultKeys = ['cargo_class', 'service_level', 'carrier']

    return Object.keys(rowData)
      .filter(k => !nonResultKeys.includes(k))
      .filter(k => !['good', 'info'].includes(rowData[k].status)).length === 0
  }

  groupStatus () {
    const { data } = this.props
    const resultValues = data.results.filter(result => ValidatorGroupResult.rowChecker(result))

    if (resultValues.length !== data.results.length || data.results.length === 0) {
      return (<i className={`flex-none fa fa-exclamation-triangle ${styles.icon_warning}`} />)
    }

    return (<i className={`flex-none fa fa-check-circle-o ${styles.icon_ok}`} />)
  }

  render () {
    const {
      data, t
    } = this.props

    const columns = [
      {
        Header: t('admin:cargoClass'),
        accessor: 'cargo_class',
        Cell: rowData => t(`common:${rowData.row.cargo_class}`)
      },
      {
        Header: t('admin:serviceLevel'),
        accessor: 'service_level'
      },
      {
        Header: t('admin:carrier'),
        accessor: 'carrier'
      },
      {
        Header: t('admin:status'),
        id: 'status',
        maxWidth: 75,
        accessor: rowData => ValidatorGroupResult.rowStatus(rowData)
      }
    ]
    const table = (
      <ReactTable
        className="flex-100 height_100"
        data={data.results}
        columns={columns}
        defaultSorted={[
          {
            id: 'cargo_class',
            desc: true
          }
        ]}
        defaultPageSize={data.results.length}
        SubComponent={row => <ValidatorResult data={row.original} />}
        showPaginationBottom={false}
      />
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start" style={{ padding: '5px' }}>
        <CollapsingBar
          parentClass={styles.shipment_card_border}
          startCollapsed
          showArrow
          minHeight="150px"
          mainWrapperStyle={{ background: '#E0E0E0', color: '#4F4F4F' }}
          contentHeader={(
            <div className={`flex layout-row layout-align-start-center ${styles.group_header}`}>
              {this.groupStatus()}
              <p className="flex">{t('admin:groupNameVar', { groupName: data.group.name })}</p>
            </div>
          )}
          content={(
            <div className="flex-100 layout-row layout-wrap">
              { data.results.length === 0 ? (<h3 className="flex center">{t('admin:no_data')}</h3>) : table }
            </div>

          )}
        />

      </div>
    )
  }
}

ValidatorGroupResult.defaultProps = {
  theme: null,
  hubHash: {}
}

export default withNamespaces(['common', 'admin'])(ValidatorGroupResult)

import React, { PureComponent } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { clientsActions } from '../../../../actions'
import styles from '../index.scss'
import Checkbox from '../../../Checkbox/Checkbox';

class AdminClientCompanies extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      groupId: null,
      filters: {}
    }
    this.fetchData = this.fetchData.bind(this)
  }

  componentDidMount () {
    const { clientsDispatch } = this.props
    clientsDispatch.getCompaniesForList({ page: 1, pageSize: 10 })
  }

  handleClick (id) {
    const { clientsDispatch, handleClick } = this.props

    if (handleClick) {
      return handleClick(id)
    }

    return clientsDispatch.goTo(`/admin/clients/companies/${id}`)
  }

  fetchData (tableState) {
    const { clientsDispatch } = this.props

    clientsDispatch.getCompaniesForList({
      page: tableState.page + 1,
      filters: tableState.filtered,
      pageSize: tableState.pageSize
    })

    this.setState({ filters: tableState.filtered })
  }

  render () {
    const {
      companiesData, t, numPages, isPage, addedMembers, theme
    } = this.props
    const columns = [
      {
        Header: t('admin:name'),
        accessor: 'name',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleClick(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.name}
            </p>
          </div>
        )
      },
      {
        id: 'vatNumber',
        Header: t('admin:vatNumber'),
        accessor: 'vatNumber',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleClick(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.lastName}
            </p>
          </div>
        )
      },
      {
        id: 'address',
        Header: t('admin:address'),
        accessor: 'address',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleClick(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.address}
            </p>
          </div>
        )
      },
      {
        id: 'country',
        Header: t('admin:country'),
        accessor: 'country',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleClick(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.country}
            </p>
          </div>
        )
      },
      {
        id: 'employeeCount',
        Header: t('admin:employeeCount'),
        accessor: 'employeeCount',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleClick(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.employeeCount}
            </p>
          </div>
        )
      }
    ]
    if (addedMembers) {
      columns.push({
        id: 'added',
        Header: t('admin:added'),
        accessor: d => addedMembers.map(a => a.id).includes(d.id),
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
          >
            <Checkbox
              checked={rowData.row.added}  
              theme={theme}
              onChange={() => this.handleClick(rowData.original.id)}
            />
          </div>
        ),
        maxWidth: 75
      })
    }
    const table = (
      <ReactTable
        className="flex-100 height_100"
        data={companiesData}
        columns={columns}
        defaultSorted={[
          {
            id: 'name',
            desc: true
          }
        ]}
        defaultPageSize={10}
        filterable
        pages={numPages}
        manual
        onFetchData={this.fetchData}
      />
    )
    const wrapperClasses = isPage ? 'flex-100 layout-row layout-align-center-center header_buffer extra_padding'
      : 'flex-100 layout-row layout-align-center-center'

    return (
      <div className={wrapperClasses}>
        { table }
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { clients, app } = state
  const  { theme } = app.tenant
  const { groups, margins, companies } = clients
  const { companiesData, numPages, page } = companies || {}

  return {
    groups,
    margins,
    companiesData,
    numPages,
    page,
    theme
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminClientCompanies))

import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { clientsActions } from '../../../../actions'
import styles from '../index.scss'
import Checkbox from '../../../Checkbox/Checkbox';

class AdminClientList extends Component {
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
    clientsDispatch.getClientsForList({ page: 1, pageSize: 10 })
  }

  handleClick (id) {
    const { clientsDispatch, handleClick } = this.props

    if (handleClick) {
      return handleClick(id)
    }
    clientsDispatch.goTo(`/admin/clients/client/${id}`)
  }

  fetchData (tableState) {
    const { clientsDispatch } = this.props

    clientsDispatch.getClientsForList({
      page: tableState.page + 1,
      filters: tableState.filtered,
      pageSize: tableState.pageSize
    })

    this.setState({ filters: tableState.filtered })
  }

  render () {
    const {
      clientData, t, numPages, addedMembers, theme
    } = this.props
    const columns = [
      {
        Header: t('user:firstName'),
        accessor: 'firstName',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleClick(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.firstName}
            </p>
          </div>
        )
      },
      {
        id: 'lastName',
        Header: t('user:lastName'),
        accessor: 'lastName',
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
        id: 'companyName',
        Header: t('user:companyName'),
        accessor: 'companyTitle',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleClick(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.companyName}
            </p>
          </div>
        )
      },
      {
        id: 'email',
        Header: t('user:email'),
        accessor: 'email',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleClick(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.email}
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
        data={clientData}
        columns={columns}
        defaultSorted={[
          {
            id: 'firstName',
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

    return (
      <div className="flex-100 layout-row layout-align-center-center">
        { table }
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { clients, app } = state
  const { groups, margins, users } = clients
  const { clientData, numPages, page } = users || {}
  const { theme } = app.tenant

  return {
    groups,
    margins,
    clientData,
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

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin', 'user'])(AdminClientList))

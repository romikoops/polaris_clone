import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import ReactTable from 'react-table'
import { bindActionCreators } from 'redux'
import { clientsActions } from '../../../../actions'
import styles from '../index.scss'
import 'react-table/react-table.css'
import Checkbox from '../../../Checkbox/Checkbox'
import RoundButton from '../../../RoundButton/RoundButton'

class AdminClientEmployeeManager extends Component {
  constructor (props) {
    super(props)
    this.state = {
      addedMembers: props.employees || [],
      filters: {},
      currentView: 'clients'
    }
    this.saveChanges = this.saveChanges.bind(this)
    this.fetchData = this.fetchData.bind(this)
  }

  getClientFromId (id) {
    const { clientData } = this.props

    return clientData.filter(c => c.id === id)[0]
  }

  addMember (id) {
    this.setState((prevState) => {
      const { addedMembers } = prevState
      const target = this.getClientFromId(id)
      if (!target) { return }
      if (!addedMembers.includes(target)) {
        addedMembers.push(target)
      }

      return { addedMembers }
    })
  }

  removeMember (id) {
    this.setState((prevState) => {
      const { addedMembers } = prevState
      const updatedMembers = addedMembers.filter(c => c.id !== id)

      return { addedMembers: updatedMembers }
    })
  }

  handleMemberChange (id) {
    const { addedMembers } = this.state
    if (addedMembers.map(a => a.id).includes(id)) {
      this.removeMember(id)
    } else {
      this.addMember(id)
    }
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

  saveChanges () {
    const { addedMembers } = this.state
    const { clientsDispatch, company, close } = this.props
    clientsDispatch.editCompanyEmployees({ addedMembers, id: company.id })
    close()
  }

  render () {
    const { t, theme, employees, numPages, clientData } = this.props
    const { addedMembers } = this.state
    const isButtonActive = (employees.map(e => e.id) !== addedMembers.map(m => m.id))
    const usersToRender = [...employees, ...clientData.filter(c => employees.filter(e => e.id === c.id).length === 0)]
    const columns = [
      {
        id: 'firstName',
        Header: t('admin:firstName'),
        accessor: 'firstName',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleMemberChange(rowData.original.id)}
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
        Header: t('admin:lastName'),
        accessor: 'lastName',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleMemberChange(rowData.original.id)}
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
        Header: t('admin:companyName'),
        accessor: 'companyTitle',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleMemberChange(rowData.original.id)}
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
        Header: t('admin:email'),
        accessor: 'email',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.handleMemberChange(rowData.original.id)}
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
              onChange={() => this.handleMemberChange(rowData.original.id)}
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
      <div className="flex-100 layout-row layout-align-center-start layout-wrap padding_top">
        <div className="flex-100 layout-wrap layout-align-center-start">
          <div className="flex-100 layout-align-center-start layout-row layout-wrap">
            <div className="flex-100 layout-row">
              <p className="flex">
                {t('admin:manageEmployees')}
              </p>
            </div>
            <div className="flex-100 layout-row layout-align-center-start">
              {table}
            </div>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <RoundButton
            handleNext={this.saveChanges}
            text={t('admin:saveChanges')}
            theme={theme}
            size="full"
            active={isButtonActive}
            disabled={!isButtonActive}
          />
        </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { clients, app } = state
  const {
    users, company
  } = clients
  const { tenant } = app
  const { clientData, numPages, page } = users || {}
  const { theme } = tenant
  const { employees, data } = company || {}

  return {
    employees,
    users,
    theme,
    clientData,
    numPages,
    page,
    company: data
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminClientEmployeeManager))

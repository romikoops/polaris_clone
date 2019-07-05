import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { get } from 'lodash'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import { clientsActions } from '../../../../actions'
import styles from '../index.scss'
import AdminClientEmployeeManager from '../EmployeeManager'
import { AdminClientGroups, AdminClientMembershipManager, AdminClientMarginPreview } from '..'
import GreyBox from '../../../GreyBox/GreyBox'
import SquareButton from '../../../SquareButton';
import TextHeading from '../../../TextHeading/TextHeading';

class AdminClientCompany extends Component {
  constructor (props) {
    super(props)
    this.state = {
      editUsers: false,
      currentView: 'members',
      editGroups: false
    }
    this.getItineraryNameFromMargin = this.getItineraryNameFromMargin.bind(this)
    this.toggleGroupEdit = this.toggleGroupEdit.bind(this)
  }

  componentDidMount () {
    const { clientsDispatch } = this.props
    const id = get(this.props, ['match', 'params', 'id'], '')
    clientsDispatch.viewCompany(id)
  }

  getItineraryNameFromMargin (margin) {
    const { pricings, itineraries } = this.props
    const pricing = pricings.filter(p => p.id === margin.pricing_id)[0]
    const itinerary = itineraries.filter(it => it.id === pricing.itinerary_id)[0]

    return get(itinerary, ['name'], '')
  }

  setView (view) {
    this.setState({ currentView: view })
  }

  newGroup () {
    const { clientsDispatch } = this.props
    clientsDispatch.goTo('/admin/clients/groupcreator')
  }

  viewEmployee (id) {
    const { clientsDispatch } = this.props
    clientsDispatch.goTo(`/admin/clients/client/${id}`)
  }

  toggleUserEdit () {
    const { clientsDispatch, id } = this.props
    this.setState((prevState) => {
      if (prevState.editUsers) {
        clientsDispatch.viewGroup(id)
      }

      return { editUsers: !prevState.editUsers }
    })
  }

  toggleGroupEdit () {
    const { clientsDispatch, company } = this.props
    this.setState((prevState) => {
      if (prevState.editGroups) {
        clientsDispatch.viewCompany(company.id)
      }

      return { editGroups: !prevState.editGroups }
    })
  }

  render () {
    const {
      employees, t, company, id, groups, theme
    } = this.props
    if (!company) { return '' }

    const groupIds = groups.map(g => g.id)
    const { editUsers, currentView, editGroups } = this.state
    const userColumns = [
      {
        id: 'fullName',
        Header: t('admin:name'),
        accessor: d => `${d.first_name} ${d.last_name}`,
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.viewEmployee(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.fullName}
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
            onClick={() => this.viewEmployee(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.email || '-'}
            </p>
          </div>
        )
      },
      {
        id: 'phone',
        Header: t('admin:phone'),
        accessor: 'phone',
        Cell: rowData => (
          <div
            className={`${styles.table_cell} flex layout-row layout-align-start-center pointy`}
            onClick={() => this.viewEmployee(rowData.original.id)}
          >
            <p className="flex-none">
              {' '}
              {rowData.row.phone || '-'}
            </p>
          </div>
        )
      }
    ]

    const userTable = editUsers ? <AdminClientEmployeeManager close={() => this.toggleUserEdit()} groupId={id} /> : (
      <div className="flex-100 layout-row layout-align-center-center layout-wrap">
        <ReactTable
          className="flex height_100"
          data={employees}
          columns={userColumns}
          defaultSorted={[
            {
              id: 'fullName',
              desc: true
            }
          ]}
          defaultPageSize={10}
        />
      </div>
    )

    const groupTable = editGroups
      ? <AdminClientMembershipManager
          addedGroups={groupIds}
          targetId={company.id}
          targetType="company"
          toggleEdit={this.toggleGroupEdit}
        />
      : (
        <AdminClientGroups
          editable={editGroups}
          targetId={company.id}
          targetType="company"
          withMargins
          toggleEdit={this.toggleGroupEdit}
        />
      )
    const view = currentView === 'groups' ? groupTable : userTable
    const rightButtons = currentView === 'groups' ? [
      (<div className="flex-100 layout-row layout-align-center-center margin_5">
        <SquareButton
          text={t('admin:editGroups')}
          theme={theme}
          handleNext={() => this.toggleGroupEdit()}
          size="small"
          border
          active
        />
      </div>)
      ,
      (<div className="flex-100 layout-row layout-align-center-center margin_5">
        <SquareButton
          text={t('admin:newGroup')}
          theme={theme}
          handleNext={() => this.newGroup()}
          size="small"
          border
          active
        />
      </div>
      )
    ] : [
      (<div className="flex-100 layout-row layout-align-center-center margin_5">
        <SquareButton
          text={t('admin:editEmployees')}
          theme={theme}
          handleNext={() => this.toggleUserEdit()}
          size="small"
          border
          active
        />
      </div>
      )
    ]

    return (
      <div className="flex-100 layout-row layout-align-center-start layout-wrap margin_top">
        <div className="flex layout-row layout-wrap padd_20">
          <div className={`flex-100 layout-row ${styles.group_header}`}>
            <h2 className="flex-none">
              {`${t('user:companyName')}: `}
            </h2>
            <h1 className="flex-none">
              {' '}
              {company.name}
              {' '}
            </h1>
          </div>
          <div className="flex-100 layout-row layout-align-space-between-center">
            <div className="flex-45 layout-row layout-align-center-center">
              <GreyBox
                wrapperClassName="flex tile_padding pointy"
                contentClassName="flex layout-row layout-align-center-center"
                onClick={() => this.setView('members')}
              >
                <i className="flex-none fa fa-users" />
                <p
                  className="flex center"
                 
                >
                  {t('admin:members')}
                </p>
              </GreyBox>
            </div>
            <div className="flex-45 layout-row layout-align-center-center">
              <GreyBox
                wrapperClassName="flex tile_padding pointy"
                contentClassName="flex layout-row layout-align-center-center"
                onClick={() => this.setView('groups')}
              >
                <i className="flex-none fa fa-percent" />
                <p
                  className="flex center"
                  
                >
                  {t('admin:groups')}
                </p>
              </GreyBox>
            </div>
          </div>
          <div className="flex-100 layout-row layout-aling-center-start layout-wrap margin_top">
            {view}
          </div>
        </div>
        <div className="flex-20 layout-row layout-wrap padd_20 layout-align-center-start">
          <div className={`flex-100 layout-row ${styles.group_header}`}>
            <h2 className="flex-none">
              {`${t('admin:companyDetails')}: `}
            </h2>
          </div>
          <div className="flex-100 layout-row layout-align-center-start layout-wrap">
            <div
              className={`flex-100 five_m layout-row layout-align-center-center ${styles.stat_box}`}
            >
              <h4
                className="flex"
              >
                {`${t(`admin:groupCount`)}: ${groups.length}`}
              </h4>
            </div>
            <div
              className={`flex-100 five_m layout-row layout-align-center-center ${styles.stat_box}`}
            >
              <h4
                className="flex"
              >
                {`${t(`admin:employeeCount`)}: ${employees.length}`}
              </h4>
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-center-start layout-wrap tile_padding">
            <div className={`flex-100 layout-align layout-row ${styles.group_header}`}>
              <h2 className="flex-none">
                {`${t('admin:companyActions')}: `}
              </h2>
            </div>
            {rightButtons}
          </div>

        </div>
        <div className="layout-row flex-100 layout-wrap layout-align-start-center padd_20">
          <AdminClientMarginPreview
            targetId={company.id}
            targetType="company"
          />
        </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { clients, app } = state
  const { company } = clients
  const { theme } = app.tenant
  const {
    data,
    employees,
    groups
  } = company || {}

  return {
    company: data,
    employees,
    groups,
    theme
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin', 'user'])(AdminClientCompany))

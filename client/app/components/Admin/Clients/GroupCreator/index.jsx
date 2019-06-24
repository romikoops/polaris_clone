import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { clientsActions } from '../../../../actions'
import styles from '../index.scss'
import AdminClientGroups from '../Groups'
import AdminClientList from '../List'
import AdminClientCompanies from '../Companies'
import GreyBox from '../../../GreyBox/GreyBox'
import RoundButton from '../../../RoundButton/RoundButton'

class AdminClientGroupCreator extends Component {
  constructor (props) {
    super(props)
    this.state = {
      addedMembers: {
        clients: [],
        groups: [],
        companies: []
      },
      filters: {},
      currentView: 'clients'
    }
    this.handleNameChange = this.handleNameChange.bind(this)
    this.saveGroup = this.saveGroup.bind(this)
  }

  componentDidMount () {
    const { clientsDispatch } = this.props
    clientsDispatch.getClientsForList({ page: 1, pageSize: 10 })
  }

  setView (view) {
    this.setState({ currentView: view })
  }

  getClientFromId (id) {
    const { clientData } = this.props

    return clientData.filter(c => c.id === id)[0]
  }

  getCompanyFromId (id) {
    const { companiesData } = this.props

    return companiesData.filter(c => c.id === id)[0]
  }

  getGroupFromId (id) {
    const { groupData } = this.props

    return groupData.filter(c => c.id === id)[0]
  }

  handleNameChange (e) {
    const { value } = e.target
    this.setState({ name: value })
  }

  addMember (type, id) {
    this.setState((prevState) => {
      const { addedMembers } = prevState
      let target
      switch (type) {
        case 'companies':
          target = this.getCompanyFromId(id)
          break
        case 'clients':
          target = this.getClientFromId(id)
          break
        case 'groups':
          target = this.getGroupFromId(id)
          break

        default:
          break
      }
      if (!addedMembers[type].includes(target)) {
        addedMembers[type].push(target)
      }

      return { addedMembers }
    })
  }

  removeMember (type, id) {
    this.setState((prevState) => {
      const { addedMembers } = prevState
      const updatedMembers = addedMembers[type].filter(c => c.id !== id)
      addedMembers[type] = updatedMembers

      return { addedMembers }
    })
  }

  saveGroup () {
    const { addedMembers, name } = this.state
    const { clientsDispatch } = this.props
    clientsDispatch.createGroup({addedMembers, name})
  }

  render () {
    const { t, theme } = this.props
    const { addedMembers, currentView, name } = this.state
    const isButtonActive = name && Object.values(addedMembers).some(arr => arr.length > 0)
    let view
    switch (currentView) {
      case 'clients':
        view = <AdminClientList handleClick={id => this.addMember('clients', id)} />
        break
      case 'companies':
        view = <AdminClientCompanies handleClick={id => this.addMember('companies', id)} />
        break
      case 'groups':
        view = <AdminClientGroups handleClick={id => this.addMember('groups', id)} />
        break

      default:
        break
    }

    return (
      <div className="flex-100 layout-row layout-align-center-start layout-wrap padding_top extra_padding">
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          <div className="flex-75 layout-row layout-align-start-center layout-wrap">
            <div className="flex-100 layout-row five_m" >
              <p className="flex">
                {t('admin:enterGroupName')}
              </p>
            </div>
            <div className="flex-100 layout-row five_m">
              <div className="flex-100 flex-gt-sm-33 layout-row input_box_full">
                <input
                  type="text"
                  onChange={this.handleNameChange}
                  value={name}
                  placeholder={t('admin:groupName')}
                />
              </div>
             
            </div>
          </div>
          <div className="flex-25 layout-row layout-align-start-center layout-wrap">
            <RoundButton
              handleNext={this.saveGroup}
              text={t('admin:saveGroup')}
              theme={theme}
              size="full"
              active={isButtonActive}
              disabled={!isButtonActive}
            />
          </div>
        </div>
        <div className="flex-100 flex-gt-sm-75 layout-wrap layout-align-center-start">
          <div className="flex-95 layout-align-center-start layout-row layout-wrap">
            <div className="flex-100 layout-row five_m">
              <p className="flex">
                {t('admin:addGroupMembers')}
              </p>
            </div>
            <div className="flex-100 layout-align-center-start layout-row">
              <GreyBox
                wrapperClassName="flex-33 pointy"
                contentClassName="flex layout-row layout-align-center-center"
              >
                <p className="flex center" onClick={() => this.setView('clients')}>{t('admin:clients')}</p>
              </GreyBox>
              <GreyBox
                wrapperClassName="flex-33 pointy"
                contentClassName="flex layout-row layout-align-center-center"
              >
                <p className="flex center" onClick={() => this.setView('companies')}>{t('admin:companies')}</p>
              </GreyBox>
              <GreyBox
                wrapperClassName="flex-33 pointy"
                contentClassName="flex layout-row layout-align-center-center"
              >
                <p className="flex center" onClick={() => this.setView('groups')}>{t('admin:groups')}</p>
              </GreyBox>
            </div>
            <div className="flex-100 layout-row layout-align-center-start">
              {view}
            </div>
          </div>
        </div>
        <div className="flex-100 flex-gt-sm-25 layout-row layout-wrap layout-align-center-start padd_sm_top">
          <GreyBox
            wrapperClassName="flex-100"
            contentClassName="flex-100 layout-row layout-wrap layout-align-center-start"
          >
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <p className="flex-100 center">{t('admin:clients')}</p>
              {
                addedMembers.clients.map(c => (
                  <div key={c.id} className="flex-100 layout-row layout-align-start-center">
                    <p className="flex-85 center">{ c.email }</p>
                    <div
                      className="flex layout-row layout-align-center-center"
                      onClick={() => this.removeMember('clients', c.id)}
                    >
                      <i className="fa fa-trash" />
                    </div>
                  </div>
                ))
              }
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <p className="flex-100 center">{t('admin:companies')}</p>
              {
                addedMembers.companies.map(c => (
                  <div key={c.id} className="flex-100 layout-row layout-align-start-center">
                    <p className="flex-85 center">{ c.name }</p>
                    <div
                      className="flex layout-row layout-align-center-center"
                      onClick={() => this.removeMember('companies', c.id)}
                    >
                      <i className="fa fa-trash" />
                    </div>
                  </div>
                ))
              }
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
              <p className="flex-100 center">{t('admin:groups')}</p>
              {
                addedMembers.groups.map(c => (
                  <div key={c.id} className="flex-100 layout-row layout-align-start-center">
                    <p className="flex-85 center">{ c.name }</p>
                    <div
                      className="flex layout-row layout-align-center-center"
                      onClick={() => this.removeMember('groups', c.id)}
                    >
                      <i className="fa fa-trash" />
                    </div>
                  </div>
                ))
              }
            </div>
          </GreyBox>
        </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { clients, app } = state
  const {
    groups, margins, users, companies
  } = clients
  const { tenant } = app
  const { theme } = tenant
  const { clientData } = users || {}
  const { companiesData } = companies || {}
  const { groupData } = groups || {}

  return {
    groups,
    margins,
    users,
    theme,
    clientData,
    companiesData,
    groupData
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminClientGroupCreator))

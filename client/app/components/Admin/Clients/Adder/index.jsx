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

class AdminClientAdder extends Component {
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
    const { group } = this.props
    group.member_list.forEach((m) => {
      let type
      switch (m.human_type) {
        case 'client':
          type = 'clients'
          break
        case 'company':
          type = 'companies'
          break
        case 'group':
          type = 'groups'
          break
        default:
          break
      }
      this.handleMemberChange(type, m.original_member_id)
    })
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
      const obj = target || { id }

      if (!addedMembers[type].some(x => x.id === obj.id)) {
        addedMembers[type].push(obj)
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

  handleMemberChange (type, id) {
    const { addedMembers } = this.state
    if (addedMembers[type].map(a => a.id).includes(id)) {
      this.removeMember(type, id)
    } else {
      this.addMember(type, id)
    }
  }

  saveGroup () {
    const { addedMembers } = this.state
    const { clientsDispatch, group, close } = this.props
    clientsDispatch.editGroupMembers({ addedMembers, id: group.id })
    close()
  }

  render () {
    const { t, theme, group } = this.props
    const { addedMembers, currentView } = this.state
    const isButtonActive = Object.values(addedMembers).some(arr => arr.length > 0)
    let view

    switch (currentView) {
      case 'clients':
        view = (
          <AdminClientList
            handleClick={id => this.handleMemberChange('clients', id)}
            addedMembers={addedMembers.clients}
          />
        )
        break
      case 'companies':
        view = (
          <AdminClientCompanies
            handleClick={id => this.handleMemberChange('companies', id)}
            addedMembers={addedMembers.companies}
          />
        )
        break
      case 'groups':
        view = (
          <AdminClientGroups
            handleClick={id => this.handleMemberChange('groups', id)}
            addedMembers={addedMembers.groups}
            targetId={group.id}
          />
        )
        break

      default:
        break
    }

    return (
      <div className="flex-100 layout-row layout-align-center-start layout-wrap padding_top">
        <div className="flex-100 layout-wrap layout-align-center-start">
          <div className="flex-100 layout-align-center-start layout-row layout-wrap">
            <div className="flex-100 layout-row">
              <p className="flex">
                {t('admin:addMembers')}
              </p>
            </div>
            <div className="flex-100 layout-align-center-start layout-row padd_20">
              <GreyBox
                wrapperClassName="flex pointy five_m"
                contentClassName="flex layout-row layout-align-center-center"
              >
                <p className="flex center" onClick={() => this.setView('clients')}>{t('admin:clients')}</p>
              </GreyBox>
              <GreyBox
                wrapperClassName="flex pointy five_m"
                contentClassName="flex layout-row layout-align-center-center"
              >
                <p className="flex center" onClick={() => this.setView('companies')}>{t('admin:companies')}</p>
              </GreyBox>
              <GreyBox
                wrapperClassName="flex pointy five_m"
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
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
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
    )
  }
}

function mapStateToProps (state) {
  const { clients, app } = state
  const {
    groups, margins, users, companies, group
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
    groupData,
    group
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin'])(AdminClientAdder))

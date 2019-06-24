import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { clientsActions } from '../../../../actions'
import styles from '../index.scss'
import AdminClientList from '../List'
import RoundButton from '../../../RoundButton/RoundButton'

class AdminClientCompanyCreator extends Component {
  constructor (props) {
    super(props)
    this.state = {
      addedMembers: [],
      address: {}
    }
    this.handleChange = this.handleChange.bind(this)
    this.handleAddressChange = this.handleAddressChange.bind(this)
    this.saveCompany = this.saveCompany.bind(this)
  }

  componentDidMount () {
    const { clientsDispatch } = this.props
    clientsDispatch.getClientsForList({ page: 1, pageSize: 10 })
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

  handleChange (target, e) {
    const { value } = e.target
    this.setState({ [target]: value })
  }

  handleAddressChange (target, e) {
    const { value } = e.target
    this.setState(prevState => ({
      address: {
        ...prevState.address,
        [target]: value
      }
    }))
  }

  toggleMember (id) {
    this.setState((prevState) => {
      const { addedMembers } = prevState
      let updatedMembers
      if (!addedMembers.includes(id)) {
        updatedMembers = addedMembers
        updatedMembers.push(id)
      } else {
        updatedMembers = addedMembers.filter(c => c !== id)
      }

      return { addedMembers: updatedMembers }
    })
  }

  saveCompany () {
    const {
      addedMembers, name, email, vatNumber, address
    } = this.state
    const { clientsDispatch } = this.props
    clientsDispatch.createCompany({
      addedMembers, name, email, vatNumber, address
    })
  }

  render () {
    const { t, theme } = this.props
    const {
      addedMembers, name, email, vatNumber, address
    } = this.state
    const isButtonActive = [name, email, vatNumber].every(x => !!x) &&
      Object.values(address).every(x => !!x)
    const addedMembersForList = addedMembers.map(id => ({ id }))

    return (
      <div className="flex-100 layout-row layout-align-center-start layout-wrap padding_top extra_padding">
        <div className="flex-100 layout-row layout-align-start-start layout-wrap">
          <div className="flex-75 layout-row layout-align-start-center layout-wrap">
            <div className="flex-50 layout-row layout-wrap">
              <div className="flex-100 layout-row five_m">
                <p className="flex">
                  {t('admin:enterCompanyName')}
                </p>
              </div>
              <div className="flex-100 layout-row five_m">
                <div className="flex-90 layout-row input_box_full">
                  <input
                    type="text"
                    onChange={e => this.handleChange('name', e)}
                    value={name}
                    placeholder={t('admin:companyName')}
                  />
                </div>
              </div>
              <div className="flex-100 layout-row five_m">
                <p className="flex">
                  {t('admin:enterCompanyEmail')}
                </p>
              </div>
              <div className="flex-100 layout-row five_m">
                <div className="flex-90 layout-row input_box_full">
                  <input
                    type="email"
                    onChange={e => this.handleChange('email', e)}
                    value={email}
                    placeholder={t('admin:companyEmail')}
                  />
                </div>
              </div>
              <div className="flex-100 layout-row five_m">
                <p className="flex">
                  {t('admin:enterCompanyVatNumber')}
                </p>
              </div>
              <div className="flex-100 layout-row five_m">
                <div className="flex-90 layout-row input_box_full">
                  <input
                    type="text"
                    onChange={e => this.handleChange('vatNumber', e)}
                    value={vatNumber}
                    placeholder={t('admin:companyVatNumber')}
                  />
                </div>

              </div>
            </div>
            <div className="flex-50 layout-row layout-wrap">
              <div className="flex-100 layout-row five_m">
                <p className="flex">
                  {t('admin:enterCompanyAddress')}
                </p>
              </div>
              <div className="flex-100 layout-row five_m layout-wrap">
                <div className="flex-90 layout-row input_box_full">
                  <input
                    type="text"
                    onChange={e => this.handleAddressChange('streetNumber', e)}
                    value={address.streetNumber}
                    placeholder={t('user:streetNumber')}
                  />
                </div>
                <div className="flex-90 layout-row input_box_full">
                  <input
                    type="text"
                    onChange={e => this.handleAddressChange('street', e)}
                    value={address.street}
                    placeholder={t('user:street')}
                  />
                </div>
                <div className="flex-90 layout-row input_box_full">
                  <input
                    type="text"
                    onChange={e => this.handleAddressChange('city', e)}
                    value={address.city}
                    placeholder={t('user:city')}
                  />
                </div>
                <div className="flex-90 layout-row input_box_full">
                  <input
                    type="text"
                    onChange={e => this.handleAddressChange('zipCode', e)}
                    value={address.zipCode}
                    placeholder={t('user:zipCode')}
                  />
                </div>
                <div className="flex-90 layout-row input_box_full">
                  <input
                    type="text"
                    onChange={e => this.handleAddressChange('country', e)}
                    value={address.country}
                    placeholder={t('user:country')}
                  />
                </div>
              </div>
            </div>
            <div className="flex-100 layout-row layout-aling-start-start layout-wrap margin_md_top">
              <div className="flex-100 layout-row five_m">
                <p className="flex">
                  {t('admin:addEmployees')}
                </p>
              </div>
              <AdminClientList handleClick={id => this.toggleMember(id)} addedMembers={addedMembersForList} />
            </div>
          </div>
          <div className="flex-25 layout-row layout-align-start-start layout-wrap">
            <RoundButton
              handleNext={this.saveCompany}
              text={t('admin:saveCompany')}
              theme={theme}
              size="full"
              active={isButtonActive}
              disabled={!isButtonActive}
            />
          </div>
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

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['common', 'admin', 'user'])(AdminClientCompanyCreator))

import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import { connect } from 'react-redux'
import { get } from 'lodash'
import { bindActionCreators } from 'redux'
import { clientsActions } from '../../../../actions'
import AdminAddressTile from '../../AdminAddressTile'
import styles from '../../Admin.scss'
import GreyBox from '../../../GreyBox/GreyBox'
import TextHeading from '../../../TextHeading/TextHeading'
import { gradientTextGenerator, capitalizeCities } from '../../../../helpers'
import { NamedSelect } from '../../../NamedSelect/NamedSelect'
import { managerRoles, adminClientsTooltips as clientTip } from '../../../../constants'
import { RoundButton } from '../../../RoundButton/RoundButton'
import AdminPromptConfirm from '../../Prompt/Confirm'
import AdminShipmentsComp from '../../Shipments/Comp'
import { AdminClientMembershipManager, AdminClientGroups, AdminClientMarginPreview } from '..'

export class AdminClientView extends Component {
  static prepShipment (baseShipment, client) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = client
      ? `${client.first_name} ${client.last_name}`
      : ''
    shipment.companyName = client
      ? `${client.company_name}`
      : ''

    return shipment
  }

  constructor (props) {
    super(props)
    this.state = {
      selectedManager: {},
      selectedRole: {},
      showAddManager: false,
      editGroups: false
    }
    this.handleClick = this.handleClick.bind(this)
    this.toggleGroupEdit = this.toggleGroupEdit.bind(this)
    this.handleShipmentAction = this.handleShipmentAction.bind(this)
    this.handleManagerAssigment = this.handleManagerAssigment.bind(this)
    this.handleRoleAssigment = this.handleRoleAssigment.bind(this)
    this.toggleNewManager = this.toggleNewManager.bind(this)
    this.assignNewManager = this.assignNewManager.bind(this)
  }

  componentDidMount () {
    window.scrollTo(0, 0)
    const { clientsDispatch, match } = this.props
    clientsDispatch.viewClient(get(match, ['params', 'id'], 0))
  }

  handleManagerAssigment (event) {
    this.setState({ selectedManager: event })
  }

  handleRoleAssigment (event) {
    this.setState({ selectedRole: event })
  }

  toggleNewManager () {
    this.setState({ showAddManager: !this.state.showAddManager })
  }

  editScope () {
    const { adminDispatch, client } = this.props
    adminDispatch.goTo(`/admin/clients/scopeeditor/user/${client.id}`)
  }

  toggleGroupEdit () {
    const { clientsDispatch, client } = this.props
    this.setState((prevState) => {
      if (prevState.editGroups) {
        clientsDispatch.viewClient(client.id)
      }

      return { editGroups: !prevState.editGroups }
    })
  }

  assignNewManager () {
    const { adminDispatch, client } = this.props
    const { selectedRole, selectedManager } = this.state
    adminDispatch.assignManager({
      manager_id: selectedManager.value,
      role: selectedRole.value,
      client_id: client.id
    })
    this.toggleNewManager()
  }

  deleteClient (id) {
    const { adminDispatch, client } = this.props
    adminDispatch.deleteClient(client.id, true)
    this.closeConfirm()
    adminDispatch.getClients(true)
  }

  confirmDelete () {
    this.setState({
      confirm: true
    })
  }

  closeConfirm () {
    this.setState({ confirm: false })
  }

  handleShipmentAction (id, action) {
    const { adminDispatch } = this.props
    adminDispatch.confirmShipment(id, action)
  }

  handleClick (shipment) {
    const { handleClick, adminDispatch } = this.props
    if (handleClick) {
      handleClick(shipment)
    } else {
      adminDispatch.getShipment(shipment.id, true)
    }
  }

  render () {
    const {
      t, theme, managers, addresses, managerAssignments, client, groups, user, scope
    } = this.props
    if (!client) {
      return ''
    }
    const groupIds = groups.map(g => g.id)
    const {
      selectedManager, selectedRole, showAddManager, confirm, editGroups
    } = this.state
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const managerOpts = managers
      ? managers.map(m => ({
        label: `${m.first_name} ${m.last_name}`,
        value: m.id
      }))
      : []
    const relManagers = managerAssignments
      ? managerAssignments.map((ma) => {
        const man = managers.filter(m => m.id === ma.manager_id)[0]
        man.section = ma.section

        return man
      })
      : []
    const manArray = relManagers
      ? relManagers.map(ma => (
        <div className="flex-100 layout-row layout-align-start-center">
          <div className="flex-50 layout-row layout-align-start-center">
            <i className="fa fa-user flex-none clip" style={textStyle} />
            <p className="flex-none">{`${ma.first_name} ${ma.last_name}`}</p>
          </div>
          <div className="flex-50 layout-row layout-align-start-center">
            <i className="fa fa-book flex-none clip" style={textStyle} />
            <p className="flex-none">{`Section: ${ma.section}`}</p>
          </div>
        </div>
      ))
      : []
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading={t('common:areYouSure')}
        text={t('admin:deleteAllData', { firstName: client.first_name, lastName: client.last_name })}
        confirm={() => this.deleteClient(client.id)}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const addressArr = addresses.map(loc => (
      <AdminAddressTile
        key={v4()}
        address={loc}
        theme={theme}
        client={client}
        tooltip={clientTip.edit_location}
        showTooltip
      />
    ))

    const groupTable = editGroups
      ? (
        <AdminClientMembershipManager
          addedGroups={groupIds}
          targetId={client.id}
          targetType="user"
          toggleEdit={this.toggleGroupEdit}
        />
      )
      : (
        <AdminClientGroups
          editable={editGroups}
          targetId={client.id}
          targetType="user"
          withMargins
          toggleEdit={this.toggleGroupEdit}
        />
      )
    const assignManagerBox = (
      <div className="flex-100 layout-row layout-wrap">
        <div className="flex-100 layout-row layout-wrap layout-align-center-center padd_20">
          <NamedSelect
            name="manager"
            placeholder={t('admin:chooseManager')}
            classes={`${styles.select}`}
            value={selectedManager}
            options={managerOpts}
            className="flex-100"
            onChange={this.handleManagerAssigment}
          />
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-center-center padd_20">
          <NamedSelect
            name="manager"
            placeholder={t('admin:chooseArea')}
            classes={`${styles.select}`}
            value={selectedRole}
            options={managerRoles}
            className="flex-100"
            onChange={this.handleRoleAssigment}
          />
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-center-center padd_20">
          <div className="flex-none layout-row">
            <RoundButton
              theme={theme}
              size="small"
              text={t('admin:save')}
              handleNext={this.assignNewManager}
              iconClass="fa-floppy-o"
            />
          </div>
        </div>
      </div>
    )
    const ProfileBox = ({ user, style, edit }) => (
      <div className={`flex-100 layout-row layout-align-start-start layout-wrap section_padding ${styles.content_details}`}>
        <div className="flex-100 layout-row layout-align-start-start layout-wrap">
          <div className="flex-100 layout-row layout-align-start-start ">
            <sup style={style} className="clip flex-none">
              {t('user:company')}
            </sup>
          </div>
          <div className="flex-100 layout-row layout-align-start-center ">
            <p className="flex-none">
              {' '}
              {user.company_name}
            </p>
          </div>
        </div>
        <div className="flex-50 layout-row layout-align-start-start layout-wrap">
          <div className="flex-100 layout-row layout-align-start-start ">
            <sup style={style} className="clip flex-none">
              {t('user:email')}
            </sup>
          </div>
          <div className="flex-100 layout-row layout-align-start-center ">
            <p className="flex-none">
              {' '}
              {user.email}
            </p>
          </div>
        </div>
        <div className="flex-50 layout-row layout-align-start-start layout-wrap">
          <div className="flex-100 layout-row layout-align-start-start ">
            <sup style={style} className="clip flex-none">
              {t('user:phone')}
            </sup>
          </div>
          <div className="flex-100 layout-row layout-align-start-center ">
            <p className="flex-none">
              {' '}
              {user.phone}
            </p>
          </div>
        </div>
      </div>
    )

    ProfileBox.defaultProps = {
      style: {}
    }
    const managerBox = (
      <div className="flex-100 layout-row layout-wrap">
        <div className="flex-100 layout-row layout-wrap layout-align-center-center">
          <div className="flex-60 layout-row" style={{ marginBottom: '10px' }}>
            <RoundButton
              theme={theme}
              size="full"
              text={t('admin:assignManager')}
              handleNext={this.toggleNewManager}
              iconClass="fa-plus"
            />
          </div>
          <div className="flex-60 layout-row" style={{ marginTop: '10px' }}>
            <RoundButton
              theme={theme}
              size="full"
              text={t('common:delete')}
              handleNext={() => this.confirmDelete()}
              iconClass="fa-trash"
            />
          </div>
        </div>
        <div className="flex-100 layout-row layout-wrap">
          <div className="flex-100 layout-row layout-align-start-center">
            <p className="flex-none">{t('admin:accountManagers')}</p>
          </div>
          {manArray}
        </div>
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start extra_padding">
        <div className="flex-100 layout-row layout-wrap layout-align-start-center padding_top margin_bottom">
          <div className={`flex-100 layout-row layout-align-start-stretch ${styles.username_title}`}>
            <span className="layout-row flex-none layout-align-center-center">
              <i className={`fa fa-user clip ${styles.bigProfile}`} style={textStyle} />
            </span>
            <div className="layout-align-start-center layout-row flex padding_left">
              <h1 className="flex-none layout-row cli">
                {capitalizeCities(client.first_name)}
                {' '}
                {capitalizeCities(client.last_name)}
              </h1>
            </div>
          </div>
        </div>
        <div
          className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.section} `}
        >
          <div className="flex-100 layout-row layout-align-space-between-stretch">
            <GreyBox
              wrapperClassName="flex-70 layout-row layout-align-start-center card_margin_right"
              contentClassName="layout-row flex"
              content={(
                <div className="layout-row flex-100">
                  <ProfileBox user={client} style={textStyle} theme={theme} />
                </div>
              )}
            />
            {relManagers.length !== 0 ? (
              <GreyBox
                title={t('admin:accountManagers')}
                wrapperClassName="flex-30 layout-row layout-align-start-start"
                contentClassName="layout-column flex"
                content={(
                  <div className={styles.conditions_box}>
                    {showAddManager ? assignManagerBox : managerBox}
                  </div>
                )}
              />
            ) : (
              ''
            )}
            <GreyBox
              wrapperClassName="flex-25 layout-row layout-align-center-center card_margin_right"
              contentClassName="layout-row flex-75 layout-align-center-space-around layout-wrap"
            >
              <RoundButton
                theme={theme}
                size="full"
                text={t('common:delete')}
                handleNext={() => this.confirmDelete()}
                iconClass="fa-trash"
                classNames="five_m"
              />
              { user.internal ? (
                <RoundButton
                  theme={theme}
                  size="full"
                  text={t('common:editScope')}
                  handleNext={() => this.editScope()}
                  iconClass="fa-trash"
                  classNames="five_m"
                />
              ) : '' }
            </GreyBox>
          </div>
        </div>

        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center greyBg ${styles.grey_section_head}`}
          >
            <TextHeading theme={theme} size={3} text={t('admin:shipments')} />
          </div>
          <AdminShipmentsComp targetUserId={client.id} />
        </div>
        { scope.base_pricing
          ? [
            (<div className="layout-row flex-100 layout-wrap layout-align-start-center">
              <div
                className={`flex-100 layout-row layout-align-space-between-center greyBg ${styles.grey_section_head}`}
              >
                <TextHeading theme={theme} size={3} text={t('admin:groups')} />
                <div
                  className="flex-none layout-row layotu-align-center-center pointy"
                  onClick={this.toggleGroupEdit}
                >
                  <i className="fa fa-pencil" />
                  <p className="flex">{t('admin:edit')}</p>
                </div>
              </div>
              {groupTable}
            </div>),
            (<div className="layout-row flex-100 layout-wrap layout-align-start-center buffer_10">
              <AdminClientMarginPreview
                targetId={client.id}
                targetType="user"
              />
            </div>)
          ] : '' }
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center greyBg ${styles.grey_section_head}`}
          >
            <TextHeading theme={theme} size={3} text={t('shipment:locations')} />
          </div>
          <div className="layout-row flex-100 layout-wrap layout-align-space-between-stretch margin_bottom">
            {addressArr}
          </div>
        </div>
        {confimPrompt}
      </div>
    )
  }
}

AdminClientView.defaultProps = {
  theme: null,
  hubs: [],
  handleClick: null,
  clientData: null,
  groups: []
}

function mapStateToProps (state) {
  const { clients, app, authentication } = state
  const { client } = clients
  const { user } = authentication
  const {
    clientData, addresses, managerAssignments, groups
  } = client || {}
  const { theme, scope } = app.tenant

  return {
    groups,
    client: clientData,
    addresses,
    managerAssignments,
    theme,
    scope,
    user
  }
}
function mapDispatchToProps (dispatch) {
  return {
    clientsDispatch: bindActionCreators(clientsActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['admin', 'common', 'user', 'shipment'])(AdminClientView))

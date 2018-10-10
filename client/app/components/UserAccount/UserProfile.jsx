import React, { Component } from 'react'
import { translate } from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './UserAccount.scss'
import UserLocations from './UserLocations'
import ProfileBox from './ProfileBox'
import EditProfileBox from './EditProfileBox'
import { AdminClientTile } from '../Admin'
import { RoundButton } from '../RoundButton/RoundButton'
import '../../styles/select-css-custom.css'
import {
  gradientTextGenerator,
  authHeader
} from '../../helpers'
import getApiHost from '../../constants/api.constants'
import { currencyOptions } from '../../constants'
import DocumentsDownloader from '../Documents/Downloader'
import { Modal } from '../Modal/Modal'
import GreyBox from '../GreyBox/GreyBox'
import OptOutCookies from '../OptOut/Cookies'
import OptOutTenant from '../OptOut/Tenant'
import OptOutItsMyCargo from '../OptOut/ItsMyCargo'
import { NamedSelect } from '../NamedSelect/NamedSelect'

const { fetch } = window

const EditNameBox = () => (
  <div className={`${styles.set_size} layout-row flex-100`} />
)

class UserProfile extends Component {
  constructor (props) {
    super(props)
    this.state = {
      editBool: false,
      editObj: {},
      newAlias: {},
      newAliasBool: false,
      passwordResetSent: false,
      passwordResetRequested: false,
      currentCurrency: {}
    }
    this.makePrimary = this.makePrimary.bind(this)
    this.editProfile = this.editProfile.bind(this)
    this.closeEdit = this.closeEdit.bind(this)
    this.saveEdit = this.saveEdit.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.toggleNewAlias = this.toggleNewAlias.bind(this)
    this.handleFormChange = this.handleFormChange.bind(this)
    this.saveNewAlias = this.saveNewAlias.bind(this)
    this.deleteAlias = this.deleteAlias.bind(this)
    this.setCurrency = this.setCurrency.bind(this)
    this.saveCurrency = this.saveCurrency.bind(this)
    this.handlePasswordChange = this.handlePasswordChange.bind(this)
  }
  componentDidMount () {
    this.props.setNav('profile')
    window.scrollTo(0, 0)
  }

  setCurrency (event) {
    this.setState({ currencySelect: event })
  }
  saveCurrency () {
    const { appDispatch } = this.props
    appDispatch.setCurrency(this.state.currencySelect.value)
  }

  handleCurrencyUpdate (e) {
    const { value } = e
    const { appDispatch } = this.props
    this.setState({ currentCurrency: e })
    appDispatch.setCurrency(value)
  }

  makePrimary (locationId) {
    const { userDispatch, user } = this.props
    userDispatch.makePrimary(user.id, locationId)
  }
  editProfile () {
    const { user } = this.props
    this.setState({
      editBool: true,
      editObj: user
    })
  }
  closeEdit () {
    this.setState({
      editBool: false
    })
  }
  handleChange (ev) {
    const { name, value } = ev.target
    this.setState({
      editObj: {
        ...this.state.editObj,
        [name]: value
      }
    })
  }
  optOut (target) {
    this.setState({
      optOut: target
    })
  }
  closeOptOutModal () {
    this.setState({ optOut: false })
  }
  handlePasswordChange () {
    const payload = {
      email: this.props.user.email,
      redirect_url: ''
    }
    fetch(`${getApiHost()}/auth/password`, {
      method: 'POST',
      headers: { ...authHeader(), 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    }).then((promise) => {
      promise.json().then((
        this.setState({
          passwordResetSent: true,
          passwordResetRequested: false
        })))
    })
    this.setState({ passwordResetRequested: true })
  }
  generateModal (target) {
    const {
      user, theme, userDispatch, tenant
    } = this.props
    switch (target) {
      case 'cookies': {
        const comp = (<OptOutCookies
          user={user}
          userDispatch={userDispatch}
          theme={theme}
          tenant={tenant}
        />)

        return <Modal component={comp} theme={theme} parentToggle={() => this.closeOptOutModal()} />
      }
      case 'tenant': {
        const comp = (<OptOutTenant
          user={user}
          userDispatch={userDispatch}
          theme={theme}
          tenant={tenant}
        />)

        return <Modal component={comp} theme={theme} parentToggle={() => this.closeOptOutModal()} />
      }
      case 'itsmycargo': {
        const comp = (<OptOutItsMyCargo
          user={user}
          userDispatch={userDispatch}
          theme={theme}
          tenant={tenant}
        />)

        return <Modal component={comp} theme={theme} parentToggle={() => this.closeOptOutModal()} />
      }
      default:
        return ''
    }
  }

  saveEdit () {
    const { authDispatch, user } = this.props
    authDispatch.updateUser(user, this.state.editObj)
    this.closeEdit()
  }
  toggleNewAlias () {
    this.setState({ newAliasBool: !this.state.newAliasBool })
  }
  handleFormChange (event) {
    const { name, value } = event.target
    this.setState({
      newAlias: {
        ...this.state.newAlias,
        [name]: value
      }
    })
  }
  deleteAlias (alias) {
    const { userDispatch } = this.props
    userDispatch.deleteAlias(alias.id)
  }
  saveNewAlias () {
    const { newAlias } = this.state
    const { userDispatch } = this.props
    userDispatch.newAlias(newAlias)
    this.toggleNewAlias()
  }
  render () {
    const {
      user, aliases, locations, theme, userDispatch, tenant, t
    } = this.props
    if (!user) {
      return ''
    }
    const {
      editBool, editObj, newAliasBool, newAlias, optOut, passwordResetSent, passwordResetRequested
    } = this.state
    const optOutModal = optOut ? this.generateModal(optOut) : ''
    const contactArr = aliases.map(cont => (
      <AdminClientTile client={cont} theme={theme} deleteable deleteFn={this.deleteAlias} flexClasses="flex-45" />
    ))
    const textStyle = theme && theme.colors
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }

    const currencySection = (
      <div className={`flex-40 layout-row layout-align-center-center layout-wrap ${styles.currency_box}`}>
        <div className="flex-75 layout-row layout-align-end-center layout-wrap">
          <div className={`flex-100 layout-row layout-align-center-center layout-wrap ${styles.currency_grey}`}>
            <p className="flex-none">{t('common:currency')}:</p>
            <span><strong>{user.currency}</strong></span>
          </div>
        </div>
        <div className="flex-75 layout-row layout-align-space-around-center layout-wrap" />
      </div>
    )

    const toggleEditCurrency = !tenant.data.scope.fixed_currency ? (
      <div className={`flex-40 layout-row layout-align-center-center layout-wrap ${styles.currency_box}`}>
        <div className="flex-75 layout-row layout-align-end-center layout-wrap">
          <div className="flex-100 layout-row layout-align-center-center ">
            <p className="flex-none">{t('common:currency')}:</p>
            <NamedSelect
              className="flex-100"
              options={currencyOptions}
              value={this.state.currentCurrency}
              placeholder={t('common:selectCurrency')}
              onChange={e => this.handleCurrencyUpdate(e)}
            />
          </div>
        </div>
      </div>
    ) : currencySection

    const newAliasBox = (
      <div
        className={`flex-none layout-row layout-wrap layout-align-center-center ${
          styles.new_contact
        }`}
      >
        <div
          className={`flex-none layout-row layout-wrap layout-align-center-center ${
            styles.new_contact_backdrop
          }`}
          onClick={this.toggleNewAlias}
        />
        <div
          className={`flex-none layout-row layout-wrap layout-align-start-start ${
            styles.new_contact_content
          }`}
        >
          <div
            className={` ${styles.contact_header} flex-100 layout-row layout-align-start-center margin-bottom`}
          >
            <i className="fa fa-user flex-10" style={textStyle} />
            <p className="flex-none">
              {t('user:newAlias')}
            </p>
          </div>
          <div className="flex-100 layout-row layout-align-center-center input_box_label relative">
            <label htmlFor="companyName">
              {t('user:companyName')}
            </label>
            <input
              className="flex"
              type="text"
              value={newAlias.companyName}
              name="companyName"
              id="companyName"
              placeholder={t('user:companyName')}
              onChange={this.handleFormChange}
            />
          </div>
          <div className="flex-50 layout-row layout-align-center-center input_box_label relative">
            <label htmlFor="firstName">
              {t('user:firstName')}
            </label>
            <input
              className="flex"
              type="text"
              value={newAlias.firstName}
              name="firstName"
              id="firstName"
              placeholder={t('user:firstName')}
              onChange={this.handleFormChange}
            />
          </div>
          <div className="flex-50 layout-row layout-align-center-center input_box_label relative">
            <label htmlFor="lastName">
              {t('user:lastName')}
            </label>
            <input
              className="flex"
              type="text"
              value={newAlias.lastName}
              name="lastName"
              id="lastName"
              placeholder={t('user:lastName')}
              onChange={this.handleFormChange}
            />
          </div>
          <div className="flex-50 layout-row layout-align-center-center input_box_label relative">
            <label htmlFor="email">
              {t('user:email')}
            </label>
            <input
              className="flex"
              type="text"
              value={newAlias.email}
              name="email"
              id="email"
              placeholder={t('user:email')}
              onChange={this.handleFormChange}
            />
          </div>
          <div className="flex-50 layout-row layout-align-center-center input_box_label relative">
            <label htmlFor="phone">
              {t('user:phone')}
            </label>
            <input
              className="flex"
              type="text"
              value={newAlias.phone}
              name="phone"
              id="phone"
              placeholder={t('user:phone')}
              onChange={this.handleFormChange}
            />
          </div>
          <div className="flex-75 layout-row layout-align-center-center input_box_label relative">
            <label htmlFor="street">
              {t('user:street')}
            </label>
            <input
              className="flex"
              type="text"
              value={newAlias.street}
              name="street"
              id="street"
              placeholder={t('user:street')}
              onChange={this.handleFormChange}
            />
          </div>
          <div className="flex-25 layout-row layout-align-center-center input_box_label relative">
            <label htmlFor="number">
              {t('user:number')}
            </label>
            <input
              className="flex"
              type="text"
              value={newAlias.number}
              name="number"
              id="number"
              placeholder={t('user:number')}
              onChange={this.handleFormChange}
            />
          </div>
          <div className="flex-20 layout-row layout-align-center-center input_box_label relative">
            <label htmlFor="zipCode">
              {t('user:postalCode')}
            </label>
            <input
              className="flex"
              type="text"
              value={newAlias.zipCode}
              name="zipCode"
              id="zipCode"
              placeholder={t('user:postalCode')}
              onChange={this.handleFormChange}
            />
          </div>
          <div className="flex-40 layout-row layout-align-center-center input_box_label relative">
            <label htmlFor="city">
              {t('user:city')}
            </label>
            <input
              className="flex"
              type="text"
              value={newAlias.city}
              name="city"
              id="city"
              placeholder={t('user:city')}
              onChange={this.handleFormChange}
            />
          </div>
          <div className="flex-40 layout-row layout-align-center-center input_box_label relative">
            <label htmlFor="country">
              {t('user:country')}
            </label>
            <input
              className="flex"
              type="text"
              value={newAlias.country}
              name="country"
              id="country"
              placeholder={t('user:country')}
              onChange={this.handleFormChange}
            />
          </div>
          <div className={`flex-100 layout-row layout-align-end-center ${styles.btn_row}`}>
            <RoundButton
              theme={theme}
              size="small"
              active
              text={t('common:save')}
              handleNext={this.saveNewAlias}
              iconClass="fa-floppy-o"
            />
          </div>
        </div>
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-center extra_padding">
        {newAliasBool ? newAliasBox : ''}
        <div className="flex-100 layout-row layout-wrap layout-align-start-center section_padding layout-padding">
          {editBool ? (
            <EditNameBox
              user={editObj}
              handleChange={this.handleChange}
              handlePasswordChange={this.handlePasswordChange}
              passwordResetSent={this.passwordResetSent}
            />
          ) : (
            <div className={`flex-100 layout-row layout-align-start-stretch ${styles.username_title}`}>
              <div className="layout-row flex-none layout-align-center-center">
                <i className={`fa fa-user clip ${styles.bigProfile}`} style={textStyle} />
              </div>
              <div className="layout-align-start-center layout-row flex">
                <p>
                  {t('common:greeting')}&nbsp;
                </p>
                <h1 className="flex-none cli">
                  {user.first_name} {user.last_name}
                </h1>
              </div>
            </div>
          )}
        </div>
        <div
          className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.section} `}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-space-between-stretch">
            <GreyBox
              wrapperClassName="flex-gt-sm-60 flex-100 layout-row layout-align-start-center "
              contentClassName="layout-row flex"
              content={(
                <div className="layout-row flex-100">
                  <EditProfileBox
                    hide={!editBool}
                    user={editObj}
                    style={textStyle}
                    theme={theme}
                    handleChange={this.handleChange}
                    handlePasswordChange={this.handlePasswordChange}
                    onSave={this.saveEdit}
                    close={this.closeEdit}
                    passwordResetSent={passwordResetSent}
                    passwordResetRequested={passwordResetRequested}
                  />
                  <ProfileBox hide={editBool} user={user} style={textStyle} theme={theme} edit={this.editProfile} />
                  {!editBool ? currencySection : toggleEditCurrency}
                </div>
              )}
            />
            <GreyBox
              title={t('user:yourData')}
              wrapperClassName="flex-gt-sm-35 flex-100 layout-row layout-align-stretch"
              contentClassName="layout-row layout-wrap flex layout-align-start-start"
              content={(
                <div className={`flex-100 layout-row layout-wrap ${styles.conditions_box}`}>
                  <div className="flex-100">
                    <p
                      className="emulate_link blue_link"
                      onClick={() => window.open('https://gdpr-info.eu/', '_blank')}
                    >
                      {t('common:moreInfo')}</p>
                  </div>
                  <div className="flex-gt-sm-100 flex-50 layout-row layout-align-space-between-center">
                    <div className="flex-66 layout-row layout-align-start-center">
                      <p className="flex-none">
                        {t('common:downloadAllData')}
                      </p>
                    </div>
                    <div className="flex-33 layout-row layout-align-center-center ">
                      <DocumentsDownloader
                        theme={theme}
                        target="gdpr"
                        size="full"
                        options={{ userId: user.id }}
                      />
                    </div>
                  </div>
                  <div className="flex-gt-sm-100 flex-50 layout-row layout-align-space-between-center">
                    <div className="flex-66 layout-row layout-align-start-center">
                      <p className="flex-none">
                        { tenant && tenant.data && tenant.data.name }
                        {' '}
                        <span
                          onClick={() => window.open('/terms_and_conditions', '_blank')}
                          className="emulate_link blue_link"
                        >
                          { t('footer:terms') }
                        </span>
                      </p>
                    </div>
                    <div className="flex-33 layout-row layout-align-center-center ">
                      <RoundButton
                        theme={theme}
                        size="full"
                        active
                        text={t('common:optOut')}
                        handleNext={() => this.optOut('tenant')}
                      />
                    </div>
                  </div>
                  <div className="flex-gt-sm-100 flex-50 layout-row layout-align-space-between-center">
                    <div className="flex-66 layout-row layout-align-start-center">
                      <p className="flex-none">
                        {t('imc:imc')}
                        {' '}
                        <span
                          onClick={() => window.open('https://www.itsmycargo.com/en/terms', '_blank')}
                          className="emulate_link blue_link"
                        >
                          { t('footer:terms') }
                        </span>
                      </p>
                    </div>
                    <div className="flex-33 layout-row layout-align-center-center ">
                      <RoundButton
                        theme={theme}
                        size="full"
                        active
                        text={t('common:optOut')}
                        handleNext={() => this.optOut('itsmycargo')}
                      />
                    </div>
                  </div>
                  <div className="flex-gt-sm-100 flex-50 layout-row layout-align-space-between-center">
                    <div className="flex-66 layout-row layout-align-start-center">
                      <p className="flex-none">
                        {t('imc:imcCookies')}
                      </p>
                    </div>
                    <div className="flex-33 layout-row layout-align-center-center ">
                      <RoundButton
                        theme={theme}
                        size="full"
                        active
                        text={t('common:optOut')}
                        handleNext={() => this.optOut('cookies')}
                      />
                    </div>
                  </div>
                </div>
              )}
            />
          </div>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          <div
            className={`flex-gt-sm-50 flex-100 layout-row layout-wrap layout-align-start-center section_padding card_padding_right ${
              styles.section
            } `}
          >
            <div
              className="flex-100 layout-align-start-center greyBg"
            >
              <span><b>{t('user:aliases')}</b></span>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-space-between-stretch">
              <div
                key="addNewAliasButton"
                className={`pointy ${styles.tile_padding} layout-row layout-align-center-stretch flex-45 margin_bottom`}
                onClick={this.toggleNewAlias}
              >
                <div
                  className={`${styles['location-box']} ${
                    styles['new-address']
                  } layout-row layout-align-start-center layout-wrap`}
                >
                  <div className="layout-row layout-align-center flex-100">
                    <div className={`${styles['plus-icon']}`} />
                  </div>

                  <div className="layout-row layout-align-center flex-100">
                    <h3>
                      {t('user:addAlias')}
                    </h3>
                  </div>
                </div>
              </div>
              {contactArr}
            </div>
          </div>

          <div
            className={`flex-gt-sm-50 flex-100 layout-row layout-wrap layout-align-start-center section_padding ${
              styles.section
            } `}
          >
            <div
              className="flex-100 layout-align-start-center greyBg"
            >
              <span><b>{t('user:savedLocations')}</b></span>
            </div>
            <UserLocations
              setNav={() => {}}
              locations={locations}
              makePrimary={this.makePrimary}
              userDispatch={userDispatch}
              theme={theme}
              cols={2}
              user={user}
            />
          </div>
        </div>
        {optOutModal}
      </div>
    )
  }
}

UserProfile.propTypes = {
  user: PropTypes.user.isRequired,
  t: PropTypes.func.isRequired,
  setNav: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  appDispatch: PropTypes.shape({
    setCurrency: PropTypes.func
  }).isRequired,
  aliases: PropTypes.arrayOf(PropTypes.object),
  locations: PropTypes.arrayOf(PropTypes.object),
  authDispatch: PropTypes.shape({
    updateUser: PropTypes.func
  }).isRequired,
  userDispatch: PropTypes.shape({
    makePrimary: PropTypes.func,
    newAlias: PropTypes.func,
    deleteAlias: PropTypes.func
  }).isRequired,
  tenant: PropTypes.tenant
}

UserProfile.defaultProps = {
  theme: null,
  aliases: [],
  locations: [],
  tenant: {}
}

export default translate(['common', 'footer', 'user', 'imc'])(UserProfile)

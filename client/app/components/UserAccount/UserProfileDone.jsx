import React, { Component } from 'react'
import { translate } from 'react-i18next'
import PropTypes from '../../prop-types'
import styles from './UserAccount.scss'
import { UserLocations } from './'
import { AdminClientTile } from '../Admin'
import { RoundButton } from '../RoundButton/RoundButton'
import '../../styles/select-css-custom.css'
import {
  gradientTextGenerator,
  authHeader
} from '../../helpers'
import DocumentsDownloader from '../Documents/Downloader'
import { Modal } from '../Modal/Modal'
import { BASE_URL } from '../../constants'
import GreyBox from '../GreyBox/GreyBox'
import {
  OptOutCookies,
  OptOutTenant,
  OptOutItsMyCargo
} from '../OptOut'
import { LoadingSpinner } from '../LoadingSpinner/LoadingSpinner'

const { fetch } = window

const ProfileBox = ({ user, style, edit }) => (
  <div
    className={`flex-100 layout-row layout-align-start-start
    layout-wrap section_padding relative ${styles.content_details}`}
  >
    <div className="flex-100 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          Company
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none"> {user.company_name}</p>
      </div>
    </div>
    <div className="flex-100 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          Email
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none"> {user.email}</p>
      </div>
    </div>
    <div className="flex-100 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          Phone
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none"> {user.phone}</p>
      </div>
    </div>
    <div className={`flex-none layout-row layout-align-center-center ${styles.profile_edit_icon}`} onClick={edit} >
      <i className="fa fa-pencil flex-none" />
    </div>
  </div>
)

ProfileBox.propTypes = {
  user: PropTypes.user.isRequired,
  edit: PropTypes.func.isRequired,
  style: PropTypes.objectOf(PropTypes.string)
}

ProfileBox.defaultProps = {
  style: {}
}

const EditNameBox = () => (
  <div className={`${styles.set_size} layout-row flex-100`} />
)

const EditProfileBox = ({
  user, handleChange, onSave, close, style, theme, handlePasswordChange, passwordResetSent, passwordResetRequested
}) => (
  <div className={`flex-100 layout-row layout-align-start-start layout-wrap section_padding ${styles.content_details}`}>
    <div className="layout-row flex-90" />
    <div className="flex-10 layout-row layout-align-end-center layout-wrap">
      <span className="layout-row flex-100 layout-align-center-stretch">
        <div
          onClick={onSave}
          className={`layout-row flex-50 ${styles.save} layout-align-center-center`}
        >
          <i className="fa fa-check" />
        </div>
        <div
          onClick={close}
          className={`layout-row flex-50 ${styles.cancel} layout-align-center-center`}
        >
          <i className="fa fa-times" />
        </div>
      </span>
    </div>
    <div
      className={`flex-100 layout-row layout-align-start-start layout-wrap
      ${styles.margin_top} margin_bottom`}
    >
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className={`clip flex-none ${styles.margin_label}`}>
          Company
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className={`flex-90 ${styles.input_style}`}
          type="text"
          value={user.company_name}
          onChange={handleChange}
          name="company_name"
        />
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap margin_bottom">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className={`clip flex-none ${styles.margin_label}`}>
            First Name
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className={`flex-none ${styles.input_style}`}
          type="text"
          value={user.first_name}
          onChange={handleChange}
          name="first_name"
        />
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap margin_bottom">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className={`clip flex-none ${styles.margin_label}`}>
            Last Name
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className={`flex-none ${styles.input_style}`}
          type="text"
          value={user.last_name}
          onChange={handleChange}
          name="last_name"
        />
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap margin_bottom">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className={`clip flex-none ${styles.margin_label}`}>
          Email
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className={`flex-none ${styles.input_style}`}
          type="text"
          value={user.email}
          onChange={handleChange}
          name="email"
        />
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className={`clip flex-none ${styles.margin_label}`}>
          Phone
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className={`flex-none ${styles.input_style}`}
          type="text"
          value={user.phone}
          onChange={handleChange}
          name="phone"
        />
      </div>
    </div>
    <div
      className={`flex-100 layout-row layout-align-center layout-wrap padding_top ${styles.form_group_submit_btn}`}
    >
      <div className="flex-50 layout-row layout-align-start-center">
        <RoundButton
          theme={theme}
          size="medium"
          active
          text="Change my Password"
          handleNext={handlePasswordChange}
        />
      </div>
      <div className={`${styles.spinner} flex-50 layout-row layout-align-start-start`}>
        {passwordResetRequested &&
        <LoadingSpinner
          size="extra_small"
        />}
      </div>
      { passwordResetSent && (
        <div className="flex-100 layout-row layout-align-center-start padding_top">
          <p>
            Please check your email for a link to change your password.
          </p>
        </div>
      )}
    </div>
  </div>
)

EditProfileBox.propTypes = {
  user: PropTypes.user.isRequired,
  theme: PropTypes.theme,
  handleChange: PropTypes.func.isRequired,
  onSave: PropTypes.func.isRequired,
  close: PropTypes.func.isRequired,
  style: PropTypes.objectOf(PropTypes.string),
  handlePasswordChange: PropTypes.func.isRequired,
  passwordResetSent: PropTypes.bool.isRequired,
  passwordResetRequested: PropTypes.bool.isRequired
}

EditProfileBox.defaultProps = {
  style: {},
  theme: null
}

export class UserProfile extends Component {
  constructor (props) {
    super(props)
    this.state = {
      editBool: false,
      editObj: {},
      newAlias: {},
      newAliasBool: false,
      passwordResetSent: false,
      passwordResetRequested: false,
      currencySelect: {
        label: this.props.user ? this.props.user.currency : 'EUR',
        value: this.props.user ? this.props.user.currency : 'EUR'
      }
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
    fetch(`${BASE_URL}/auth/password`, {
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
              placeholder="Company Name"
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
              placeholder="First Name"
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
              placeholder="Last Name"
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
              placeholder="Email"
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
              placeholder="Phone"
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
              placeholder="Street"
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
              placeholder="Number"
              onChange={this.handleFormChange}
            />
          </div>
          <div className="flex-20 layout-row layout-align-center-center input_box_label relative">
            <label htmlFor="zipCode">
              {t('user:zipCode')}
            </label>
            <input
              className="flex"
              type="text"
              value={newAlias.zipCode}
              name="zipCode"
              id="zipCode"
              placeholder="Postal Code"
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
              placeholder="City"
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
              placeholder="Country"
              onChange={this.handleFormChange}
            />
          </div>
          <div className={`flex-100 layout-row layout-align-end-center ${styles.btn_row}`}>
            <RoundButton
              theme={theme}
              size="small"
              active
              text="Save"
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
                  {editBool ? (
                    <EditProfileBox
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
                  ) : (
                    <ProfileBox user={user} style={textStyle} theme={theme} edit={this.editProfile} />
                  )}
                  <div className={`flex-40 layout-row layout-align-center-center layout-wrap ${styles.currency_box}`}>
                    <div className="flex-75 layout-row layout-align-end-center layout-wrap">
                      <div className={`flex-100 layout-row layout-align-center-center layout-wrap ${styles.currency_grey}`}>
                        <p className="flex-none">{t('common:currency')}:</p>
                        <span><strong>{user.currency}</strong></span>
                      </div>
                    </div>
                    <div className="flex-75 layout-row layout-align-space-around-center layout-wrap">
                      {/* <StyledSelect
                        name="currency"
                        className={`${styles.select}`}
                        value={this.state.currencySelect}
                        options={currencyOptions}
                        onChange={this.setCurrency}
                        clearable={false}
                      />
                      <div
                        onClick={this.saveCurrency}
                        className={`layout-row flex-25 ${styles.save} layout-align-center-center`}
                      >
                        <i className="fa fa-check" /> Save
                      </div> */}
                      {/* <div className={`flex-100 layout-row layout-align-end-center ${styles.btn_row} ${styles.btn_alignment}`}>
                        <RoundButton
                          theme={theme}
                          size="small"
                          active
                          text="Save"
                          handleNext={this.saveCurrency}
                          iconClass="fa-floppy-o"
                        />
                      </div> */}
                    </div>
                  </div>
                </div>
              )}
            />
            <GreyBox
              title="GDPR - Your Data"
              wrapperClassName="flex-gt-sm-35 flex-100 layout-row layout-align-start-start"
              contentClassName="layout-column flex"
              content={(
                <div className={`layout-row layout-wrap ${styles.conditions_box}`}>
                  <div className="flex-gt-sm-100 flex-50 layout-row layout-align-space-between-center">
                    <div className="flex-66 layout-row layout-align-start-center">
                      {/* <p className="flex-none">
                        Here you can download all the data that ItsMyCargo has related to your account.
                      </p> */}
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
                        {`${tenant && tenant.data ? tenant.data.name : ''}`} {t('footer:terms')}
                      </p>
                    </div>
                    <div className="flex-33 layout-row layout-align-center-center ">
                      <RoundButton
                        theme={theme}
                        size="full"
                        active
                        text="Opt Out"
                        handleNext={() => this.optOut('tenant')}
                      />
                    </div>
                  </div>
                  <div className="flex-gt-sm-100 flex-50 layout-row layout-align-space-between-center">
                    <div className="flex-66 layout-row layout-align-start-center">
                      <p className="flex-none">
                        {t('imc:imcTerms')}
                      </p>
                      {/* <p className="flex-none">
                        {`To opt out of the ItsMyCargo GMBH Terms and Conditions click the "Opt Out" button to the right`}
                      </p> */}
                    </div>
                    <div className="flex-33 layout-row layout-align-center-center ">
                      <RoundButton
                        theme={theme}
                        size="full"
                        active
                        text="Opt Out"
                        handleNext={() => this.optOut('itsmycargo')}
                      />
                    </div>
                  </div>
                  <div className="flex-gt-sm-100 flex-50 layout-row layout-align-space-between-center">
                    <div className="flex-66 layout-row layout-align-start-center">
                      <p className="flex-none">
                        {t('imc:imcCookes')}
                      </p>
                      {/* <p className="flex-none">
                        {`To opt out of the ItsMyCargo's use of cookies click the "Opt Out" button to the right`}
                      </p> */}
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

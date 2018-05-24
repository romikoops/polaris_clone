import React, { Component } from 'react'
import styled from 'styled-components'
import Select from 'react-select'
import PropTypes from '../../prop-types'
import styles from './UserAccount.scss'
import defaults from '../../styles/default_classes.scss'
import { UserLocations } from './'
import { AdminClientTile } from '../Admin'
import { RoundButton } from '../RoundButton/RoundButton'
import '../../styles/select-css-custom.css'
import { currencyOptions } from '../../constants'
import { gradientTextGenerator } from '../../helpers'
import DocumentsDownloader from '../Documents/Downloader'
import { Modal } from '../Modal/Modal'
import {
  OptOutCookies,
  OptOutTenant,
  OptOutItsMyCargo
} from '../OptOut'

const ProfileBox = ({ user, style, edit }) => (
  <div className="flex-100 layout-row layout-align-start-start layout-wrap section_padding">
    <div className="flex-100 layout-row layout-align-end-center layout-wrap">
      <div className="flex-15 layout-row layout-align-center-center" onClick={edit}>
        <i className="fa fa-pencil clip" style={style} />
      </div>
    </div>
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
    <div className="flex-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          First Name
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none"> {user.first_name}</p>
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          Last Name
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none"> {user.last_name}</p>
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          Email
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none"> {user.email}</p>
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          Phone
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none"> {user.phone}</p>
      </div>
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

const EditProfileBox = ({
  user, handleChange, onSave, close, style, theme
}) => (
  <div className="flex-100 layout-row layout-align-start-start layout-wrap section_padding">
    <div className="flex-100 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          Company
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-90"
          type="text"
          value={user.company_name}
          onChange={handleChange}
          name="company_name"
        />
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          First Name
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-none"
          type="text"
          value={user.first_name}
          onChange={handleChange}
          name="first_name"
        />
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          Last Name
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-none"
          type="text"
          value={user.last_name}
          onChange={handleChange}
          name="last_name"
        />
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          Email
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-none"
          type="text"
          value={user.email}
          onChange={handleChange}
          name="email"
        />
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          Phone
        </sup>
      </div>
      <div className="input_box flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-none"
          type="text"
          value={user.phone}
          onChange={handleChange}
          name="phone"
        />
      </div>
    </div>
    <div className="flex-100 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 flex-gt-sm-50 layout-row layout-align-center-center button_padding">
        <RoundButton
          theme={theme}
          handleNext={close}
          size="small"
          text="close"
          iconClass="fa-times"
        />
      </div>
      <div className="flex-100 flex-gt-sm-50 layout-row layout-align-center-center button_padding">
        <RoundButton
          theme={theme}
          handleNext={onSave}
          active
          size="small"
          text="Save"
          iconClass="fa-floppy-o"
        />
      </div>
    </div>
  </div>
)

EditProfileBox.propTypes = {
  user: PropTypes.user.isRequired,
  theme: PropTypes.theme,
  handleChange: PropTypes.func.isRequired,
  onSave: PropTypes.func.isRequired,
  close: PropTypes.func.isRequired,
  style: PropTypes.objectOf(PropTypes.string)
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
      user, aliases, locations, theme, userDispatch, tenant
    } = this.props
    if (!user) {
      return ''
    }

    const {
      editBool, editObj, newAliasBool, newAlias, optOut
    } = this.state
    const optOutModal = optOut ? this.generateModal(optOut) : ''
    const contactArr = aliases.map(cont => (
      <AdminClientTile client={cont} theme={theme} deleteable deleteFn={this.deleteAlias} />
    ))
    const StyledSelect = styled(Select)`
      width: 50%;
      .Select-control {
        background-color: #f9f9f9;
        box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
        border: 1px solid #f2f2f2 !important;
      }
      .Select-menu-outer {
        box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
        border: 1px solid #f2f2f2;
      }
      .Select-value {
        background-color: #f9f9f9;
        border: 1px solid #f2f2f2;
      }
      .Select-option {
        background-color: #f9f9f9;
      }
    `
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
            className={` ${styles.contact_header} flex-100 layout-row layout-align-start-center`}
          >
            <i className="fa fa-user flex-none" style={textStyle} />
            <p className="flex-none">New Alias</p>
          </div>
          <input
            className={styles.input_100}
            type="text"
            value={newAlias.companyName}
            name="companyName"
            placeholder="Company Name"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_50}
            type="text"
            value={newAlias.firstName}
            name="firstName"
            placeholder="First Name"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_50}
            type="text"
            value={newAlias.lastName}
            name="lastName"
            placeholder="Last Name"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_50}
            type="text"
            value={newAlias.email}
            name="email"
            placeholder="Email"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_50}
            type="text"
            value={newAlias.phone}
            name="phone"
            placeholder="Phone"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_street}
            type="text"
            value={newAlias.street}
            name="street"
            placeholder="Street"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_no}
            type="text"
            value={newAlias.number}
            name="number"
            placeholder="Number"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_zip}
            type="text"
            value={newAlias.zipCode}
            name="zipCode"
            placeholder="Postal Code"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_cc}
            type="text"
            value={newAlias.city}
            name="city"
            placeholder="City"
            onChange={this.handleFormChange}
          />
          <input
            className={styles.input_cc}
            type="text"
            value={newAlias.country}
            name="country"
            placeholder="Country"
            onChange={this.handleFormChange}
          />
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
      <div className="flex-100 layout-row layout-wrap layout-align-start-center">
        {newAliasBool ? newAliasBox : ''}
        <div className="flex-100 layout-row layout-wrap layout-align-start-center section_padding">
          <h1 className="sec_title_text flex-none cli" style={textStyle}>
            Profile
          </h1>
        </div>
        <div
          className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.section} `}
        >
          <div className="flex-100 layout-row layout-align-space-between-center sec_header">
            <p className="sec_header_text flex-none"> Account Details </p>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
            <div className="flex-50 layout-row layout-align-start-center">
              {editBool ? (
                <EditProfileBox
                  user={editObj}
                  style={textStyle}
                  theme={theme}
                  handleChange={this.handleChange}
                  onSave={this.saveEdit}
                  close={this.closeEdit}
                />
              ) : (
                <ProfileBox user={user} style={textStyle} theme={theme} edit={this.editProfile} />
              )}
            </div>
            <div className="flex-50 layout-row layout-align-end-center layout-wrap">
              <div className="flex-75 layout-row layout-align-end-center layout-wrap">
                <div className="flex-100 layout-row layout-align-end-center layout-wrap">
                  <h3 className="flex-none"> Currency Settings:</h3>
                </div>
                <div className="flex-100 layout-row layout-align-end-center layout-wrap">
                  <p className="flex-none">Current Selection: {user.currency}</p>
                </div>
              </div>
              <div className="flex-75 layout-row layout-align-end-center layout-wrap">
                <StyledSelect
                  name="currency"
                  className={`${styles.select}`}
                  value={this.state.currencySelect}
                  options={currencyOptions}
                  onChange={this.setCurrency}
                  clearable={false}
                />
                <div className={`flex-100 layout-row layout-align-end-center ${styles.btn_row} ${styles.btn_alignment}`}>
                  <RoundButton
                    theme={theme}
                    size="small"
                    active
                    text="Save"
                    handleNext={this.saveCurrency}
                    iconClass="fa-floppy-o"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
        <div
          className={`flex-100 layout-row layout-wrap layout-align-start-center section_padding ${
            styles.section
          } `}
        >
          <div className="flex-100 layout-row layout-align-space-between-center sec_header">
            <p className="sec_header_text flex-none"> Aliases </p>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-start-center">
            <div
              key="addNewAliasButton"
              className={`${defaults.pointy} ${styles.margin} flex-33`}
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
                  <h3>Add Alias</h3>
                </div>
              </div>
            </div>
            {contactArr}
          </div>
        </div>

        <div
          className={`flex-100 layout-row layout-wrap layout-align-start-center section_padding ${
            styles.section
          } `}
        >
          <div className="flex-100 layout-row layout-align-space-between-center sec_header">
            <p className="sec_header_text flex-none"> Saved Locations </p>
          </div>
          <UserLocations
            setNav={() => {}}
            locations={locations}
            makePrimary={this.makePrimary}
            userDispatch={userDispatch}
            theme={theme}
            user={user}
          />
        </div>
        <div
          className={`flex-100 layout-row layout-wrap layout-align-start-center section_padding ${
            styles.section
          } `}
        >
          <div className="flex-100 layout-row layout-align-space-between-center sec_header">
            <p className="sec_header_text flex-none"> GDPR - Your data </p>
          </div>
          <div className="flex-100 layout-row layout-align-space-between-center">
            <div className="flex-75 layout-row layout-align-start-center">
              <p className="flex-none">
                Here you can download all the data that ItsMyCargo has related to your account.
              </p>
            </div>
            <div className="flex-25 layout-row layout-align-end-center">
              <DocumentsDownloader
                theme={theme}
                target="gdpr"
                options={{ userId: user.id }}
              />
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-space-between-center">
            <div className="flex-75 layout-row layout-align-start-center">
              <p className="flex-none">
                {`To opt out of the ${tenant && tenant.data ? tenant.data.name : ''} Terms and Conditions click the "Opt Out" button to the right`}
              </p>
            </div>
            <div className="flex-25 layout-row layout-align-end-center">
              <RoundButton
                theme={theme}
                size="small"
                active
                text="Opt Out"
                handleNext={() => this.optOut('tenant')}
              />
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-space-between-center">
            <div className="flex-75 layout-row layout-align-start-center">
              <p className="flex-none">
                {`To opt out of the ItsMyCargo GMBH Terms and Conditions click the "Opt Out" button to the right`}
              </p>
            </div>
            <div className="flex-25 layout-row layout-align-end-center">
              <RoundButton
                theme={theme}
                size="small"
                active
                text="Opt Out"
                handleNext={() => this.optOut('itsmycargo')}
              />
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-space-between-center">
            <div className="flex-75 layout-row layout-align-start-center">
              <p className="flex-none">
                {`To opt out of the ItsMyCargo's use of cookies click the "Opt Out" button to the right`}
              </p>
            </div>
            <div className="flex-25 layout-row layout-align-end-center">
              <RoundButton
                theme={theme}
                size="small"
                active
                text="Opt Out"
                handleNext={() => this.optOut('cookies')}
              />
            </div>
          </div>
        </div>
        {optOutModal}
      </div>
    )
  }
}

UserProfile.propTypes = {
  user: PropTypes.user.isRequired,
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

export default UserProfile

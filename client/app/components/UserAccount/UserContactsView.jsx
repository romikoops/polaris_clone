import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
// import { UserShipmentRow } from './';
import AdminAddressTile from '../Admin/AdminAddressTile'
import styles from './UserAccount.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import { AdminSearchableShipments } from '../Admin/AdminSearchables'
import { gradientTextGenerator } from '../../helpers'
import GreyBox from '../GreyBox/GreyBox'

const UntranslatedEditProfileBox = ({
  user, handleChange, onSave, close, style, theme, t
}) => (
  <div className={`flex-100 layout-row layout-align-start-start layout-wrap section_padding ${styles.content_details}`}>
    <div className="flex-100 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:company')}
        </sup>
      </div>
      <div className="input_box_full flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-100"
          type="text"
          value={user.companyName}
          onChange={handleChange}
          name="companyName"
        />
      </div>
    </div>
    <div className={`flex-50 layout-row layout-align-start-start layout-wrap ${styles.input_box}`}>
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:firstName')}
        </sup>
      </div>
      <div className="input_box_full flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-none"
          type="text"
          value={user.firstName}
          onChange={handleChange}
          name="firstName"
        />
      </div>
    </div>
    <div className={`flex-50 layout-row layout-align-start-start layout-wrap ${styles.input_box}`}>
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:lastName')}
        </sup>
      </div>
      <div className="input_box_full flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-none"
          type="text"
          value={user.lastName}
          onChange={handleChange}
          name="lastName"
        />
      </div>
    </div>
    <div className={`flex-50 layout-row layout-align-start-start layout-wrap ${styles.input_box}`}>
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:email')}
        </sup>
      </div>
      <div className="input_box_full flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-none"
          type="text"
          value={user.email}
          onChange={handleChange}
          name="email"
        />
      </div>
    </div>
    <div className={`flex-50 layout-row layout-align-start-start layout-wrap ${styles.input_box}`}>
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:phone')}
        </sup>
      </div>
      <div className="input_box_full flex-100 layout-row layout-align-start-center ">
        <input
          className="flex-none"
          type="text"
          value={user.phone}
          onChange={handleChange}
          name="phone"
        />
      </div>
    </div>
    <div className="flex-100 layout-row layout-align-end-center layout-wrap">
      <div className="flex-50 layout-row layout-align-center-center button_padding">
        <RoundButton
          theme={theme}
          handleNext={close}
          size="small"
          text={t('common:close')}
          iconClass="fa-times"
        />
      </div>
      <div className="flex-50 layout-row layout-align-center-center button_padding">
        <RoundButton
          theme={theme}
          handleNext={onSave}
          active
          size="small"
          text={t('common:save')}
          iconClass="fa-floppy-o"
        />
      </div>
    </div>
  </div>
)

UntranslatedEditProfileBox.propTypes = {
  user: PropTypes.user.isRequired,
  t: PropTypes.func.isRequired,
  handleChange: PropTypes.func.isRequired,
  onSave: PropTypes.func.isRequired,
  close: PropTypes.func.isRequired,
  style: PropTypes.objectOf(PropTypes.string),
  theme: PropTypes.theme
}

UntranslatedEditProfileBox.defaultProps = {
  theme: null,
  style: {}
}

const EditProfileBox = withNamespaces(['user', 'common'])(UntranslatedEditProfileBox)

const UntranslatedProfileBox = ({
  user, style, edit, t
}) => (
  <div className={`flex-100 layout-row layout-align-start-start layout-wrap section_padding ${styles.content_details}`}>
    <div className="flex-100 layout-row layout-align-end-center layout-wrap">
      <div className="flex-15 layout-row layout-align-center-center" onClick={edit}>
        <i className="fa fa-pencil clip" style={style} />
      </div>
    </div>
    <div className="flex-100 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:company')}
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none"> {user.company_name}</p>
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:email')}
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none"> {user.email}</p>
      </div>
    </div>
    <div className="flex-50 layout-row layout-align-start-start layout-wrap">
      <div className="flex-100 layout-row layout-align-start-start ">
        <sup style={style} className="clip flex-none">
          {t('user:phone')}
        </sup>
      </div>
      <div className="flex-100 layout-row layout-align-start-center ">
        <p className="flex-none"> {user.phone}</p>
      </div>
    </div>
  </div>
)

UntranslatedProfileBox.propTypes = {
  user: PropTypes.user.isRequired,
  t: PropTypes.func.isRequired,
  edit: PropTypes.func.isRequired,
  style: PropTypes.objectOf(PropTypes.string)
}

UntranslatedProfileBox.defaultProps = {
  style: {}
}

const ProfileBox = withNamespaces('user')(UntranslatedProfileBox)

class UserContactsView extends Component {
  static prepShipment (baseShipment, user, hubsObj) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = user ? `${user.first_name} ${user.last_name}` : ''
    shipment.companyName = user ? `${user.company_name}` : ''

    return shipment
  }

  constructor (props) {
    super(props)
    this.state = {
      editBool: false,
      editObj: {}
    }
    this.editProfile = this.editProfile.bind(this)
    this.closeEdit = this.closeEdit.bind(this)
    this.saveEdit = this.saveEdit.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.goBack = this.goBack.bind(this)
  }
  componentDidMount () {
    const {
      contactData, loading, userDispatch, match
    } = this.props
    if (!contactData && !loading) {
      userDispatch.getContact(match.params.id, false)
    }
    window.scrollTo(0, 0)
  }
  goBack () {
    const { userDispatch } = this.props
    userDispatch.goBack()
  }
  editProfile () {
    const { contactData } = this.props
    const { contact } = contactData
    const newEditObj = {
      firstName: contact.first_name,
      lastName: contact.last_name,
      companyName: contact.company_name,
      phone: contact.phone,
      email: contact.email,
      id: contact.id
    }
    this.setState({
      editBool: true,
      editObj: newEditObj
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
  saveEdit () {
    const { userDispatch } = this.props
    userDispatch.updateContact(this.state.editObj)
    this.closeEdit()
  }
  render () {
    const {
      theme, contactData, hubs, userDispatch, t
    } = this.props
    if (!contactData) {
      return ''
    }
    const { contact, shipments, address } = contactData
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const { editBool, editObj } = this.state
    const shipArr = []
    shipments.forEach((ship) => {
      shipArr.push(UserContactsView.prepShipment(ship, contact, hubs))
    })

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start extra_padding">

        <div className={`flex-100 layout-row layout-align-start-stretch ${styles.username_title}`}>
          <span className="layout-row flex-none layout-align-start-center card_padding_right">
            <i className={`fa fa-user clip ${styles.bigProfile}`} style={textStyle} />
          </span>
          <div className="layout-align-start-center layout-row flex-70">
            <h1 className="flex-none cli">
              {contact.first_name} {contact.last_name}
            </h1>
          </div>
        </div>
        <div className="layout-row flex-100 layout-wrap layout-align-start-center margin_bottom">
          <GreyBox
            wrapperClassName="flex-gt-sm-66 flex-100 layout-row layout-align-start-center "
            contentClassName="layout-row flex"
            content={(
              <div className="layout-row flex-100">
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
                  <ProfileBox user={contact} style={textStyle} theme={theme} edit={this.editProfile} />
                )}
              </div>
            )}
          />

        </div>
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <AdminSearchableShipments
            title="Related Shipments"
            limit={5}
            seeAll={false}
            hubs={hubs}
            shipments={shipArr}
            theme={theme}
            dispatches={userDispatch}
            userView
            handleShipmentAction={this.handleShipmentAction}
          />
        </div>
        {address ? (
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            <div className="flex-100 layout-row layout-align-space-between-center">
              <div
                className="flex-100 layout-align-start-center greyBg"
              >
                <span><b>{t('shipment:locations')}</b></span>
              </div>
            </div>
            <AdminAddressTile
              key={v4()}
              address={address}
              theme={theme}
              client={contact}
              showDelete={false}
              saveEdit={userDispatch.saveAddressEdit}
              deleteAddress={userDispatch.deleteContactAddress}
            />
          </div>
        ) : (
          ''
        )}
      </div>
    )
  }
}
UserContactsView.propTypes = {
  theme: PropTypes.theme,
  loading: PropTypes.bool,
  match: PropTypes.match.isRequired,
  hubs: PropTypes.arrayOf(PropTypes.object),
  t: PropTypes.func.isRequired,
  contactData: PropTypes.shape({
    contact: PropTypes.contact,
    shipments: PropTypes.arrayOf(PropTypes.object),
    address: PropTypes.address
  }).isRequired,

  userDispatch: PropTypes.shape({
    goBack: PropTypes.func
  }).isRequired
}

UserContactsView.defaultProps = {
  theme: null,
  loading: false,
  hubs: []
}

export default withNamespaces(['common', 'user', 'shipment'])(UserContactsView)

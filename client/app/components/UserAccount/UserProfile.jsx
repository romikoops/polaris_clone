import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './UserAccount.scss'
import UserLocations from './UserLocations'
import ProfileBox from './ProfileBox'
import EditProfileBox from './EditProfileBox'
import { AdminClientTile } from '../Admin'
import { RoundButton } from '../RoundButton/RoundButton'
import '../../styles/select-css-custom.scss'
import {
  gradientTextGenerator,
  authHeader,
  isQuote
} from '../../helpers'
import { getTenantApiUrl } from '../../constants/api.constants'
import { currencyOptions } from '../../constants'
import DocumentsDownloader from '../Documents/Downloader'
import GreyBox from '../GreyBox/GreyBox'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import DeleteAccountModal from './DeleteAccountModal'

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
      passwordResetSent: false,
      passwordResetRequested: false,
      currentCurrency: {}
    }
    this.makePrimary = this.makePrimary.bind(this)
    this.editProfile = this.editProfile.bind(this)
    this.closeEdit = this.closeEdit.bind(this)
    this.saveEdit = this.saveEdit.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.setCurrency = this.setCurrency.bind(this)
    this.saveCurrency = this.saveCurrency.bind(this)
    this.handlePasswordChange = this.handlePasswordChange.bind(this)
    this.closeDeleteAccountModal = this.closeDeleteAccountModal.bind(this)
    this.showDeleteAccountModal = this.showDeleteAccountModal.bind(this)
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

  makePrimary (addressId) {
    const { userDispatch, user } = this.props
    userDispatch.makePrimary(user.id, addressId)
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

  closeDeleteAccountModal () {
    this.setState({ showDeleteAccountModal: false })
  }

  showDeleteAccountModal () {
    this.setState({ showDeleteAccountModal: true })
  }

  handlePasswordChange () {
    const payload = {
      email: this.props.user.email,
      redirect_url: ''
    }
    fetch(`${getTenantApiUrl()}/auth/password`, {
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

  saveEdit () {
    const { authDispatch, user } = this.props
    authDispatch.updateUser(user, this.state.editObj)
    this.closeEdit()
  }

  render () {
    const {
      user, addresses, theme, userDispatch, tenant, t
    } = this.props
    if (!user) {
      return ''
    }
    const {
      editBool, editObj, passwordResetSent, passwordResetRequested, showDeleteAccountModal
    } = this.state
    const textStyle = theme && theme.colors
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }

    const deleteAccountModal = showDeleteAccountModal
      ? <DeleteAccountModal closeModal={this.closeDeleteAccountModal} tenant={tenant} user={user} theme={theme} />
      : ''

    const currencySection = (
      <div className={`flex-40 layout-row layout-align-center-center layout-wrap ${styles.currency_box}`}>
        <div className="flex-75 layout-row layout-align-end-center layout-wrap">
          <div className={`flex-100 layout-row layout-align-center-center layout-wrap ${styles.currency_grey}`}>
            <p className="flex-none">
              {t('common:currency')}
              :
            </p>
            <span><strong>{user.currency}</strong></span>
          </div>
        </div>
        <div className="flex-75 layout-row layout-align-space-around-center layout-wrap" />
      </div>
    )

    const toggleEditCurrency = !tenant.scope.fixed_currency ? (
      <div className={`flex-40 layout-row layout-align-center-center layout-wrap ${styles.currency_box}`}>
        <div className="flex-75 layout-row layout-align-end-center layout-wrap">
          <div className="flex-100 layout-row layout-wrap layout-align-center-center">
            <p className="flex-none">
              {t('common:currency')}
              :
            </p>
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

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-center extra_padding">
        {deleteAccountModal}
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
                  {t('common:greeting')}
                    &nbsp;
                </p>
                <h1 className="flex-none cli">
                  {user.first_name}
                  {' '}
                  {user.last_name}
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
              wrapperClassName="flex layout-row layout-align-start-center"
              contentClassName="layout-row flex"
              content={(
                <div className="layout-row flex-100">
                  <EditProfileBox
                    hide={!editBool}
                    user={editObj}
                    style={textStyle}
                    theme={theme}
                    handleChange={this.handleChange}
                    onSave={this.saveEdit}
                    close={this.closeEdit}
                  />
                  <ProfileBox
                    hide={editBool}
                    user={user}
                    style={textStyle}
                    theme={theme}
                    edit={this.editProfile}
                    handlePasswordChange={this.handlePasswordChange}
                    passwordResetSent={passwordResetSent}
                    passwordResetRequested={passwordResetRequested}
                    hideEdit={isQuote(tenant)}
                  />
                  {
                    !isQuote(tenant) && (
                      !editBool ? currencySection : toggleEditCurrency
                    )
                  }
                </div>
              )}
            />
            {
              !isQuote(tenant) && (
                <GreyBox
                  title={t('user:yourData')}
                  wrapperClassName="flex-gt-md-35 offset-gt-md-5 flex-100 layout-row layout-align-stretch"
                  contentClassName="layout-row layout-wrap flex layout-align-start-start"
                  content={(
                    <div className={`flex-100 layout-row layout-wrap ${styles.conditions_box}`}>
                      <div className="flex-100">
                        <p
                          className="emulate_link blue_link"
                          onClick={() => window.open('https://gdpr-info.eu/', '_blank')}
                        >
                          {t('common:moreInfo')}
                        </p>
                      </div>
                      <div className="flex-gt-sm-100 flex-50 layout-row layout-align-space-between-center">
                        <div className="flex-66 layout-row layout-align-start-center">
                          <p className="flex-none">
                            {t('common:downloadAllData')}
                          </p>
                        </div>
                        <div className="flex-33 layout-row layout-align-start">
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
                            {t('account:deleteAccountRequest')}
                          </p>
                        </div>
                        <div className="flex-33 layout-row layout-align-start">
                          <RoundButton
                            theme={theme}
                            size="full"
                            text={t('account:request')}
                            handleNext={this.showDeleteAccountModal}
                          />
                        </div>
                      </div>
                    </div>
                  )}
                />
              )
            }
          </div>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          <div
            className={`flex-gt-sm-50 flex-100 layout-row layout-wrap layout-align-start-center section_padding card_padding_right ${
              styles.section
            } `}
          />
        </div>
      </div>
    )
  }
}

UserProfile.defaultProps = {
  theme: null,
  addresses: [],
  tenant: {}
}

export default withNamespaces(['common', 'footer', 'user', 'imc'])(UserProfile)

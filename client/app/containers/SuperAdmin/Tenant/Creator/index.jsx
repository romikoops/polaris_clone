import React from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Promise } from 'es6-promise-promise'
import Toggle from 'react-toggle'
import '../../../../styles/react-toggle.scss'
import PropTypes from '../../../../prop-types'
import SquareButton from '../../../../components/SquareButton'
import styles from './index.scss'
import { authHeader } from '../../../../helpers'
import { appActions } from '../../../../actions'
import FileUploader from '../../../../components/FileUploader/FileUploader'
import { NamedSelect } from '../../../../components/NamedSelect/NamedSelect'
import GenericError from '../../../../components/ErrorHandling/Generic'

const SA_BASE_URL =
  process.env.NODE_ENV === 'production'
    ? 'https://api.itsmycargo.com/subdomain/demo'
    : 'http://localhost:3000/subdomain/demo'
const { fetch } = window
class SuperAdminTenantCreator extends React.Component {
  static handleResponse (response) {
    if (!response.ok) {
      return Promise.reject(response.statusText)
    }
    return response.json()
  }
  constructor (props) {
    super(props)
    this.state = {
      newTenant: {
        scope: {
          modes_of_transport: {
            ocean: {},
            air: {},
            rail: {}
          },
          carriage_options: {
            on_carriage: {},
            pre_carriage: {}
          },
          terms: ['', '', '']
        },
        theme: {
          colors: {}
        },
        addresses: {},
        phones: {},
        emails: {
          support: {}
        }
      }
    }
  }
  componentWillMount () {
    const { appDispatch } = this.props
    appDispatch.fetchTenants()
  }
  setTheme (selection) {
    const { value } = selection
    const { appDispatch } = this.props
    appDispatch.setTheme(value.theme)
  }
  uploadImages (file, key) {
    const { newTenant } = this.state
    const formData = new window.FormData()
    formData.append('file', file)
    formData.append('key', key)
    formData.append('subdomain', newTenant.subdomain)
    const requestOptions = {
      method: 'POST',
      headers: { ...authHeader() },
      body: formData
    }
    const uploadUrl = `${SA_BASE_URL}/super_admins/upload_image`
    fetch(uploadUrl, requestOptions).then((promise) => {
      promise.json().then((response) => {
        this.setState({
          newTenant: {
            ...this.state.newTenant,
            theme: {
              ...this.state.newTenant.theme,
              [key]: response.data.url
            }
          }
        })
      })
    })

    return null
  }
  handleToggle (ev, key) {
    const keys = key.split('-')
    switch (keys.length) {
      case 1:
        this.setState({
          newTenant: {
            ...this.state.newTenant,
            scope: {
              ...this.state.newTenant.scope,
              [keys[0]]: ev
            }
          }
        })
        break
      case 2:
        this.setState({
          newTenant: {
            ...this.state.newTenant,
            scope: {
              ...this.state.newTenant.scope,
              [keys[0]]: {
                ...this.state.newTenant.scope[keys[0]],
                [keys[1]]: ev
              }
            }
          }
        })
        break
      case 3:
        this.setState({
          newTenant: {
            ...this.state.newTenant,
            scope: {
              ...this.state.newTenant.scope,
              [keys[0]]: {
                ...this.state.newTenant.scope[keys[0]],
                [keys[1]]: {
                  ...this.state.newTenant.scope[keys[0]][keys[1]],
                  [keys[2]]: ev
                }
              }
            }
          }
        })
        break
      default:
        this.setState({
          newTenant: {
            ...this.state.newTenant,
            scope: {
              ...this.state.newTenant.scope,
              [keys[0]]: ev
            }
          }
        })
        break
    }
  }
  handleChange (ev) {
    const { name, value } = ev.target
    const nameKeys = name.split('-')
    switch (nameKeys.length) {
      case 1:
        this.setState({
          newTenant: {
            ...this.state.newTenant,
            [nameKeys[0]]: value
          }
        })
        break
      case 2:
        this.setState({
          newTenant: {
            ...this.state.newTenant,
            [nameKeys[0]]: {
              ...this.state.newTenant[nameKeys[0]],
              [nameKeys[1]]: value
            }
          }
        })
        break
      case 3:
        this.setState({
          newTenant: {
            ...this.state.newTenant,
            [nameKeys[0]]: {
              ...this.state.newTenant[nameKeys[0]],
              [nameKeys[1]]: {
                ...this.state.newTenant[nameKeys[0]][nameKeys[1]],
                [nameKeys[2]]: value
              }
            }
          }
        })
        break
      default:
        this.setState({
          newTenant: {
            ...this.state.newTenant,
            [nameKeys[0]]: value
          }
        })
        break
    }
  }
  handleSelect (ev) {
    const { name, value } = ev
    this.setState({
      newTenant: {
        ...this.state.newTenant,
        [name]: value
      }
    })
  }
  handleTermsChange (ev) {
    const { name, value } = ev.target
    const { terms } = this.state.newTenant.scope
    terms[parseInt(name, 10)] = value
    this.setState({
      newTenant: {
        ...this.state.newTenant,
        scope: {
          ...this.state.newTenant.scope,
          terms
        }
      }
    })
  }

  render () {
    const { theme, tenants } = this.props
    const tenantsArr = tenants || []
    const { newTenant, selectedTenant } = this.state
    const incoOptions = [{ value: 'simple', label: 'Simple' }, { value: 'text', label: 'Label' }]
    const carriageOptions = [
      { value: 'mandatory', label: 'Mandatory' },
      { value: 'optional', label: 'Optional' }
    ]
    const toggleCSS = `
      .react-toggle--checked .react-toggle-track {
        background: 
          ${theme.colors.brightPrimary} !important;
        border: 0.5px solid rgba(0, 0, 0, 0);
      }
      .react-toggle-track {
        background: #686868 !important;
      }
      .react-toggle:hover .react-toggle-track{
        background: rgba(0, 0, 0, 0.5) !important;
      }
    `
    const styleTagJSX = theme ? <style>{toggleCSS}</style> : ''

    return (
      <GenericError theme={theme}>
        <div className="flex-100 layout-row layout-wrap layout-align-center-start ">
          <div className="flex-100 layout-row layout-align-start-center">
            <h2 className="flex-100">Set Theme</h2>
            <div className="flex-50 layout-row layout-align-start-center layout-wrap">
              <p className="flex-100">Choose Theme</p>
              <NamedSelect
                className="flex-100"
                theme={theme}
                value={selectedTenant}
                options={tenantsArr}
                onChange={e => this.setTheme(e)}
                name="incoterm_info_level"
              />
            </div>
          </div>
          <div className="flex-80 layout-row layout-align-start-start layout-wrap">
            <div className="flex-100 layout-row layout-align-start-center">
              <h1 className="flex-none">Tenant Creator</h1>
            </div>
            <div className="flex-100 layout-row layout-align-start-center layout-wrap">
              <h4 className="flex-100">Basic Info</h4>
              <div className="flex-40 layout-row layout-align-start-center input_box">
                <input
                  type="text"
                  value={newTenant.subdomain}
                  onChange={e => this.handleChange(e)}
                  name="subdomain"
                  placeholder="Subdomain"
                  className="flex-none"
                />
              </div>
              <div className="flex-40 layout-row layout-align-start-center input_box">
                <input
                  type="text"
                  value={newTenant.name}
                  onChange={e => this.handleChange(e)}
                  name="name"
                  placeholder="Name"
                  className="flex-none"
                />
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-center layout-wrap">
              <h4 className="flex-100">Theme</h4>
              <div className="flex-40 layout-row layout-align-start-center input_box">
                <input
                  type="text"
                  value={newTenant.theme.colors.primary}
                  onChange={e => this.handleChange(e)}
                  name="theme-colors-primary"
                  placeholder="Primary Color"
                  className="flex-none"
                />
                <div
                  className={`${styles.demo_color} flex-20`}
                  style={{ background: newTenant.theme.colors.primary }}
                />
              </div>
              <div className="flex-40 layout-row layout-align-start-center input_box">
                <input
                  type="text"
                  value={newTenant.theme.colors.secondary}
                  onChange={e => this.handleChange(e)}
                  name="theme-colors-secondary"
                  placeholder="Secondary Color"
                  className="flex-none"
                />
                <div
                  className={`${styles.demo_color} flex-20`}
                  style={{ background: newTenant.theme.colors.secondary }}
                />
              </div>
              <div className="flex-40 layout-row layout-align-start-center input_box">
                <input
                  type="text"
                  value={newTenant.theme.colors.brightPrimary}
                  onChange={e => this.handleChange(e)}
                  name="theme-colors-brightPrimary"
                  placeholder="Bright Primary Color"
                  className="flex-none"
                />
                <div
                  className={`${styles.demo_color} flex-20`}
                  style={{ background: newTenant.theme.colors.brightPrimary }}
                />
              </div>
              <div className="flex-40 layout-row layout-align-start-center input_box">
                <input
                  type="text"
                  value={newTenant.theme.colors.brightSecondary}
                  onChange={e => this.handleChange(e)}
                  name="theme-colors-brightSecondary"
                  placeholder="Bright Secondary Color"
                  className="flex-none"
                />
                <div
                  className={`${styles.demo_color} flex-20`}
                  style={{ background: newTenant.theme.colors.brightSecondary }}
                />
              </div>
              <div
                className="flex-50 layout-row
                layout-align-start-center layout-wrap "
              >
                <div className="flex-50 layout-row layout-wrap">
                  <p className="flex-100">Logo - Large</p>
                  <FileUploader
                    dispatchFn={file => this.uploadImages(file, 'logoLarge')}
                    theme={theme}
                  />
                </div>
                <div className="flex-50 layout-row layout-wrap">
                  <div
                    className={`${styles.demo_img} flex-none`}
                    style={{ background: newTenant.theme.logoLarge }}
                  />
                </div>
              </div>
              <div
                className="flex-50 layout-row
                layout-align-start-center layout-wrap "
              >
                <div className="flex-50 layout-row layout-wrap">
                  <p className="flex-100">Logo - Small</p>
                  <FileUploader
                    dispatchFn={file => this.uploadImages(file, 'logoSmall')}
                    theme={theme}
                  />
                </div>
                <div className="flex-50 layout-row layout-wrap">
                  <div
                    className={`${styles.demo_img} flex-none`}
                    style={{ background: newTenant.theme.logoSmall }}
                  />
                </div>
              </div>
              <div
                className="flex-50 layout-row
                layout-align-start-center layout-wrap "
              >
                <div className="flex-50 layout-row layout-wrap">
                  <p className="flex-100">Logo - White</p>
                  <FileUploader
                    dispatchFn={file => this.uploadImages(file, 'logoWhite')}
                    theme={theme}
                  />
                </div>
                <div className="flex-50 layout-row layout-wrap">
                  <div
                    className={`${styles.demo_img} flex-none`}
                    style={{ background: newTenant.theme.logoWhite }}
                  />
                </div>
              </div>
              <div className="flex-50 layout-row layout-align-start-center layout-wrap ">
                <div className="flex-50 layout-row layout-wrap">
                  <p className="flex-100">Logo - Wide</p>
                  <FileUploader
                    dispatchFn={file => this.uploadImages(file, 'logoWide')}
                    theme={theme}
                  />
                </div>
                <div className="flex-50 layout-row layout-wrap">
                  <div
                    className={`${styles.demo_img} flex-none`}
                    style={{ background: newTenant.theme.logoWide }}
                  />
                </div>
              </div>
              <div
                className="flex-50 layout-row
                layout-align-start-center layout-wrap "
              >
                <div className="flex-50 layout-row layout-wrap">
                  <p className="flex-100">Background</p>
                  <FileUploader
                    dispatchFn={file => this.uploadImages(file, 'background')}
                    theme={theme}
                  />
                </div>
                <div className="flex-50 layout-row layout-wrap">
                  <div
                    className={`${styles.demo_img} flex-none`}
                    style={{ background: newTenant.theme.background }}
                  />
                </div>
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-center layout-wrap">
              <h4 className="flex-100">Addresses</h4>
              <div className="flex-40 layout-row layout-align-start-center input_box_full">
                <input
                  type="text"
                  value={newTenant.addresses.main}
                  onChange={e => this.handleChange(e)}
                  name="addresses-main"
                  placeholder="Main Address"
                  className="flex-none"
                />
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-center layout-wrap">
              <h4 className="flex-100">Phone Numbers</h4>
              <div className="flex-40 layout-row layout-align-start-center input_box_full">
                <input
                  type="text"
                  value={newTenant.phones.main}
                  onChange={e => this.handleChange(e)}
                  name="phones-main"
                  placeholder="Main Phone Number"
                  className="flex-none"
                />
              </div>
              <div className="flex-40 layout-row layout-align-start-center input_box_full">
                <input
                  type="text"
                  value={newTenant.phones.support}
                  onChange={e => this.handleChange(e)}
                  name="phones-support"
                  placeholder="Support Phone Number"
                  className="flex-none"
                />
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-center layout-wrap">
              <h4 className="flex-100">Emails</h4>
              <div className="flex-40 layout-row layout-align-start-center input_box_full">
                <input
                  type="text"
                  value={newTenant.emails.sales}
                  onChange={e => this.handleChange(e)}
                  name="emails-sales"
                  placeholder="Sales Email Address"
                  className="flex-none"
                />
              </div>
              <div className="flex-40 layout-row layout-align-start-center input_box_full">
                <input
                  type="text"
                  value={newTenant.emails.support.general}
                  onChange={e => this.handleChange(e)}
                  name="emails-support-general"
                  placeholder="General Support Email"
                  className="flex-none"
                />
              </div>
              <div className="flex-40 layout-row layout-align-start-center input_box_full">
                <input
                  type="text"
                  value={newTenant.emails.support.sea}
                  onChange={e => this.handleChange(e)}
                  name="emails-support-sea"
                  placeholder="Ocean Freight Support Email"
                  className="flex-none"
                />
              </div>
              <div className="flex-40 layout-row layout-align-start-center input_box_full">
                <input
                  type="text"
                  value={newTenant.emails.support.air}
                  onChange={e => this.handleChange(e)}
                  name="emails-support-air"
                  placeholder="Air Freight Support Email"
                  className="flex-none"
                />
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-start-center layout-wrap">
              <h4 className="flex-100">Scope</h4>
              <div className="flex-100 layout-row layout-wrap">
                <h5 className="flex-none">Cargo Modes of Transport</h5>
                <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                  <p className="flex-100">Ocean - Container</p>
                  <Toggle
                    checked={newTenant.scope.modes_of_transport.ocean.container}
                    onChange={e => this.handleToggle(e, 'modes_of_transport-ocean-container')}
                  />
                </div>
                <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                  <p className="flex-100">Ocean - Cargo item</p>
                  <Toggle
                    checked={newTenant.scope.modes_of_transport.ocean.cargo_item}
                    onChange={e => this.handleToggle(e, 'modes_of_transport-ocean-cargo_item')}
                  />
                </div>
                <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                  <p className="flex-100">Air - Container</p>
                  <Toggle
                    checked={newTenant.scope.modes_of_transport.air.container}
                    onChange={e => this.handleToggle(e, 'modes_of_transport-air-container')}
                  />
                </div>
                <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                  <p className="flex-100">Air - Cargo item</p>
                  <Toggle
                    checked={newTenant.scope.modes_of_transport.air.cargo_item}
                    onChange={e => this.handleToggle(e, 'modes_of_transport-air-cargo_item')}
                  />
                </div>
                <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                  <p className="flex-100">Rail - Container</p>
                  <Toggle
                    checked={newTenant.scope.modes_of_transport.rail.container}
                    onChange={e => this.handleToggle(e, 'modes_of_transport-rail-container')}
                  />
                </div>
                <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                  <p className="flex-100">Rail - Cargo item</p>
                  <Toggle
                    checked={newTenant.scope.modes_of_transport.rail.cargo_item}
                    onChange={e => this.handleToggle(e, 'modes_of_transport-rail-cargo_item')}
                  />
                </div>
              </div>
              <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                <p className="flex-100">Dangerous Goods</p>
                <Toggle
                  checked={newTenant.scope.dangerous_goods}
                  onChange={e => this.handleToggle(e, 'dangerous_goods')}
                />
              </div>
              <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                <p className="flex-100">Detailed Billing</p>
                <Toggle
                  checked={newTenant.scope.detailed_billing}
                  onChange={e => this.handleToggle(e, 'detailed_billing')}
                />
              </div>
              <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                <p className="flex-100">Has Insurance</p>
                <Toggle
                  checked={newTenant.scope.has_insurance}
                  onChange={e => this.handleToggle(e, 'has_insurance')}
                />
              </div>
              <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                <p className="flex-100">Has Customs</p>
                <Toggle
                  checked={newTenant.scope.has_customs}
                  onChange={e => this.handleToggle(e, 'has_customs')}
                />
              </div>
              <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                <p className="flex-100">Incoterm Detail</p>
                <NamedSelect
                  theme={theme}
                  value={newTenant.scope.incoterm_info_level}
                  options={incoOptions}
                  onChange={e => this.handleSelect(e)}
                  name="incoterm_info_level"
                />
              </div>
              <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                <p className="flex-100">Cargo Detail</p>
                <NamedSelect
                  theme={theme}
                  value={newTenant.scope.cargo_info_level}
                  options={incoOptions}
                  onChange={e => this.handleSelect(e)}
                  name="cargo_info_level"
                />
              </div>
              <div className="flex-100 layout-row layout-wrap">
                <h5 className="flex-100">Carriage options</h5>
                <div className="flex-100 layout-row layout-wrap">
                  <p className="flex-100">On Carriage</p>
                  <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                    <p className="flex-100">Import</p>
                    <NamedSelect
                      theme={theme}
                      value={newTenant.scope.carriage_options.on_carriage.import}
                      options={carriageOptions}
                      onChange={e => this.handleSelect(e)}
                      name="carriage_options-on_carriage-import"
                    />
                  </div>
                  <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                    <p className="flex-100">Export</p>
                    <NamedSelect
                      theme={theme}
                      value={newTenant.scope.carriage_options.on_carriage.import}
                      options={carriageOptions}
                      onChange={e => this.handleSelect(e)}
                      name="carriage_options-on_carriage-export"
                    />
                  </div>
                </div>
                <div className="flex-100 layout-row layout-wrap">
                  <p className="flex-100">Pre Carriage</p>
                  <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                    <p className="flex-100">Import</p>
                    <NamedSelect
                      theme={theme}
                      value={newTenant.scope.carriage_options.pre_carriage.import}
                      options={carriageOptions}
                      onChange={e => this.handleSelect(e)}
                      name="carriage_options-pre_carriage-import"
                    />
                  </div>
                  <div className="flex-50 layout-row layout-align-start-center layout-wrap">
                    <p className="flex-100">Export</p>
                    <NamedSelect
                      theme={theme}
                      value={newTenant.scope.carriage_options.pre_carriage.import}
                      options={carriageOptions}
                      onChange={e => this.handleSelect(e)}
                      name="carriage_options-pre_carriage-export"
                    />
                  </div>
                </div>
              </div>
              <div className="flex-100 layout-row layout-wrap">
                <h5 className="flex-100">Terms</h5>
                <div className="flex-100 layout-row layout-wrap">
                  <div className="flex-100 layout-row layout-align-start-center input_box_full">
                    <input
                      type="text"
                      value={newTenant.scope.terms[0]}
                      onChange={e => this.handleTermsChange(e)}
                      name="0"
                      placeholder="Support Phone Number"
                      className="flex-none"
                    />
                  </div>
                  <div className="flex-100 layout-row layout-align-start-center input_box_full">
                    <input
                      type="text"
                      value={newTenant.scope.terms[1]}
                      onChange={e => this.handleTermsChange(e)}
                      name="1"
                      placeholder="Support Phone Number"
                      className="flex-none"
                    />
                  </div>
                  <div className="flex-100 layout-row layout-align-start-center input_box_full">
                    <input
                      type="text"
                      value={newTenant.scope.terms[2]}
                      onChange={e => this.handleTermsChange(e)}
                      name="2"
                      placeholder="Support Phone Number"
                      className="flex-none"
                    />
                  </div>
                </div>
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-end-center">
              <SquareButton theme={theme} handleNext={() => this.saveTenant()} text="Save" />
            </div>
          </div>
          {styleTagJSX}
        </div>
      </GenericError>
    )
  }
}

SuperAdminTenantCreator.propTypes = {
  theme: PropTypes.theme,
  tenants: PropTypes.arrayOf(PropTypes.any),
  appDispatch: PropTypes.objectOf(PropTypes.func).isRequired
}

SuperAdminTenantCreator.defaultProps = {
  theme: null,
  tenants: []
}

function mapStateToProps (state) {
  const { authentication, tenant, app } = state
  const { user, loggedIn } = authentication
  const { theme } = tenant.data
  const { tenants } = app
  return {
    user,
    tenant,
    loggedIn,
    theme,
    tenants
  }
}
function mapDispatchToProps (dispatch) {
  return {
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(SuperAdminTenantCreator)

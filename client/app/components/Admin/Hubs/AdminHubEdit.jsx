import React, { Component } from 'react'
// import Select from 'react-select'
// import styled from 'styled-components'
import PropTypes from '../../../prop-types'
import styles from './index.scss'
import GmapsWrapper from '../../../hocs/GmapsWrapper'
import PlaceSearch from '../../Maps/PlaceSearch'
import '../../../styles/select-css-custom.scss'
import SquareButton from '../../SquareButton'
import { gradientTextGenerator } from '../../../helpers'

export class AdminHubEdit extends Component {
  constructor (props) {
    super(props)
    this.state = {
      address: props.hub.address,
      hub: props.hub
    }
    this.handlePlaceChange = this.handlePlaceChange.bind(this)
    this.handleAddressChange = this.handleAddressChange.bind(this)
    this.resetAuto = this.resetAuto.bind(this)
    this.saveHubEdit = this.saveHubEdit.bind(this)
    this.handleTruckingType = this.handleTruckingType.bind(this)
    this.handleHubType = this.handleHubType.bind(this)
  }
  componentDidMount () {
    if (this.props.hub) {
      this.setExistingLocation(this.props.hub.address)
    }
  }
  componentWillReceiveProps (nextProps) {
    if (nextProps.hub && !this.state.hub.id) {
      this.setState({ hub: nextProps.hub })
    }
    if (nextProps.hub && nextProps.hub.address && !this.state.address.id) {
      this.setExistingLocation(nextProps.hub.address)
    }
  }
  setExistingLocation (addressObj) {
    const address = {
      ...addressObj,
      country: addressObj.country.name
    }
    this.setState({ address })
  }
  handlePlaceChange (place) {
    const tmpAddress = {
      number: '',
      street: '',
      zipCode: '',
      city: '',
      country: '',
      fullAddress: ''
    }

    place.address_components.forEach((ac) => {
      if (ac.types.includes('street_number')) {
        tmpAddress.street_number = ac.long_name
      }

      if (ac.types.includes('route') || ac.types.includes('premise')) {
        tmpAddress.street = ac.long_name
      }

      if (ac.types.includes('locality')) {
        tmpAddress.city = ac.long_name
      }

      if (ac.types.includes('postal_code')) {
        tmpAddress.zipCode = ac.long_name
      }

      if (ac.types.includes('country')) {
        tmpAddress.country = ac.long_name
      }
    })
    tmpAddress.latitude = place.geometry.location.lat()
    tmpAddress.longitude = place.geometry.location.lng()
    tmpAddress.fullAddress = place.formatted_address
    tmpAddress.geocoded_address = place.formatted_address
    this.setState({
      address: tmpAddress,
      hub: {
        ...this.state.hub,
        name: tmpAddress.city
      },
      autocomplete: { ...this.state.autocomplete, address: true }
    })
  }
  handleAddressChange (event) {
    const eventKeys = event.target.name.split('-')
    const key1 = eventKeys[0]
    const key2 = eventKeys[1]
    const val = event.target.value
    this.setState({
      [key1]: {
        ...this.state[key1],
        [key2]: val
      }
    })
  }
  handleImageUpload (e) {
    const { adminDispatch, hub } = this.props
    const file = e.target.files[0]
    adminDispatch.newHubImage(hub.id, file)
  }

  clickUploaderInput (e) {
    e.preventDefault()
    this.uploaderInput.click()
  }
  resetAuto () {
    this.setState({
      autocomplete: { ...this.state.autocomplete, address: false }
    })
  }
  handleTruckingType (ev) {
    this.setState({
      hub: {
        ...this.state.hub,
        truckingType: ev.value
      }
    })
  }
  handleHubType (ev) {
    const { hub } = this.state
    let newName
    if (hub.name) {
      newName = `${hub.name} ${ev.label}`
    } else {
      newName = ''
    }

    this.setState({
      hub: {
        ...this.state.hub,
        name: newName,
        hubType: ev.value
      }
    })
  }

  saveHubEdit () {
    const { hub, address } = this.state
    const preppedLocation = {}
    const preppedHub = {}
    preppedLocation.street_number = address.street_number
    preppedLocation.street = address.street
    preppedLocation.zip_code = address.zip_code
    preppedLocation.city = address.city
    preppedLocation.country = address.country
    preppedLocation.latitude = address.latitude
    preppedLocation.longitude = address.longitude
    preppedLocation.geocoded_address = address.geocoded_address

    preppedHub.name = hub.name
    preppedHub.latitude = address.latitude
    preppedHub.longitude = address.longitude
    this.props.adminDispatch
      .editHub(hub.id, { data: preppedHub, address: preppedLocation })
    this.props.close()
  }

  render () {
    const { theme, close } = this.props
    const { hub, address } = this.state
    const iconStyle = gradientTextGenerator(theme.colors.primary, theme.colors.secondary)

    return (
      <div
        className={`flex-none layout-align-center-center layout-row ${styles.editor_backdrop}`}
      >
        <div className={`flex-none ${styles.editor_fade}`} onClick={() => close()} />
        <div
          className={`${styles.hub_form} layout-row flex-none layout-wrap layout-align-center`}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-start-center">
            <div className="flex-5" />
            <h2 className="flex-none letter_3 no_m" >
              Edit Hub
            </h2>
          </div>
          <div className="flex-100 layout-row layout-align-start-center layout-wrap">
            <GmapsWrapper
              theme={theme}
              component={PlaceSearch}
              handlePlaceChange={this.handlePlaceChange}
              address={hub.address}
            />
          </div>
          <div
            className={`flex-100 layout-row layout-wrap layout-align-start-center ${
              styles.form_padding
            }`}
          >
            <div className="flex-50 layout-row layout-wrap layout-align-start-start height_100">
              <div className="flex-100 layout-row layout-wrap layout-align-start-start">

                <div
                  className={`flex-80 layout-row layout-wrap layout-align-center-center ${styles.material_input}`}
                >
                  <p className="flex-100">Hub Name</p>
                  <input
                    name="hub-name"
                    className="flex-none"
                    type="string"
                    onChange={this.handleAddressChange}
                    value={hub.name}
                    placeholder="Name"
                  />
                </div>
              </div>
              <div className="flex-100 layout-row layout-align-start-start">
                <div className="flex-50 layout-row layout-wrap layout-align-center-center">

                  <div
                    className={`flex-80 layout-row layout-wrap layout-align-center-center ${styles.material_input}`}
                  >
                    <p className="flex-100">Latitude</p>
                    <input
                      name="address-latitude"
                      className="flex-none"
                      type="string"
                      onChange={this.handleAddressChange}
                      value={address.latitude}
                      placeholder="Latitude"
                    />
                  </div>
                </div>
                <div className="flex-50 layout-row layout-wrap layout-align-center-center">

                  <div
                    className={`flex-80 layout-row layout-wrap layout-align-center-center ${styles.material_input}`}
                  >
                    <p className="flex-100">Longitude</p>
                    <input
                      name="address-longitude"
                      className="flex-none"
                      type="string"
                      onChange={this.handleAddressChange}
                      value={address.longitude}
                      placeholder="Longitude"
                    />
                  </div>
                </div>

              </div>
              <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                <div className={`flex-none layout-row ${styles.upload_btn_wrapper} `}>
                  <form>
                    <div
                      className={`${styles.upload_image} flex-none pointy layout-row layout-align-space-around-center`}
                      onClick={e => this.clickUploaderInput(e)}
                    >
                      <p className={`${styles.upload_title}`}>Upload New Image</p>
                      <i className="fa fa-cloud-upload clip flex-none" style={iconStyle} />
                    </div>
                    <input
                      type="file"
                      onChange={e => this.handleImageUpload(e)}
                      name="hub_image"
                      ref={(input) => {
                        this.uploaderInput = input
                      }}
                    />
                  </form>
                </div>
              </div>

            </div>
            <div className="flex-50 layout-row layout-wrap layout-align-end-space-around">
              <div className="flex-100 layout-row layout-align-space-around-center">
                <div className={`flex-20 layout-row layout-wrap layout-align-center-center ${styles.material_input}`}>
                  <p className="flex-100">No.</p>
                  <input
                    id="not-auto"
                    name="address-street_number"
                    className="flex-none"
                    type="string"
                    onChange={this.handleAddressChange}
                    value={address.street_number}
                    placeholder="Number"
                  />
                </div>
                <div className={`flex-75 layout-row layout-wrap layout-align-center-center ${styles.material_input}`}>
                  <p className="flex-100">Street</p>
                  <input
                    name="address-street"
                    className="flex-none"
                    type="string"
                    onChange={this.handleAddressChange}
                    value={address.street}
                    placeholder="Street"
                  />
                </div>
              </div>
              <div className="flex-100 layout-row layout-align-space-around-center">
                <div className={`flex-30 layout-row layout-wrap layout-align-center-center ${styles.material_input}`}>
                  <p className="flex-100">Zipcode</p>
                  <input
                    name="address-zipCode"
                    className="flex-none"
                    type="string"
                    onChange={this.handleAddressChange}
                    value={address.zip_code}
                    placeholder="Zip Code"
                  />
                </div>
                <div className={`flex-65 layout-row layout-wrap ayout-align-center-center ${styles.material_input}`}>
                  <p className="flex-100">City</p>
                  <input
                    name="address-city"
                    className="flex-none"
                    type="string"
                    onChange={this.handleAddressChange}
                    value={address.city}
                    placeholder="City"
                  />
                </div>
              </div>

              <div className="flex-100 layout-row layout-align-space-around-center">
                <div className={`flex-100 layout-row layout-wrap layout-align-center-center ${styles.material_input}`}>
                  <p className="flex-100">Country</p>
                  <input
                    name="address-country"
                    className="flex-none"
                    type="string"
                    onChange={this.handleAddressChange}
                    value={address.country}
                    placeholder="Country"
                  />
                </div>
              </div>
            </div>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-center-center">
            <div className="flex-none layout-row">
              <SquareButton
                theme={theme}
                size="small"
                text="Save Hub"

                handleNext={this.saveHubEdit}
                iconClass="fa-floppy"
              />
            </div>
            <div className="flex-5" />
          </div>
        </div>
      </div>
    )
  }
}

AdminHubEdit.propTypes = {
  theme: PropTypes.theme,
  hub: PropTypes.hub.isRequired,
  close: PropTypes.func.isRequired,
  adminDispatch: PropTypes.objectOf(PropTypes.func)
}

AdminHubEdit.defaultProps = {
  theme: null,
  adminDispatch: {}
}

export default AdminHubEdit

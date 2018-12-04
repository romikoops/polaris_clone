import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import Select from 'react-select'
import styled from 'styled-components'
import PropTypes from '../../../prop-types'
import styles from '../Admin.scss'
import GmapsWrapper from '../../../hocs/GmapsWrapper'
import PlaceSearch from '../../Maps/PlaceSearch'
import '../../../styles/select-css-custom.scss'
import { RoundButton } from '../../RoundButton/RoundButton'

export class AdminHubForm extends Component {
  constructor (props) {
    super(props)
    this.state = {
      address: {},
      hub: {
        name: '',
        hubType: '',
        truckingType: ''
      }
    }
    this.handlePlaceChange = this.handlePlaceChange.bind(this)
    this.handleAddressChange = this.handleAddressChange.bind(this)
    this.resetAuto = this.resetAuto.bind(this)
    this.saveNewHub = this.saveNewHub.bind(this)
    this.handleTruckingType = this.handleTruckingType.bind(this)
    this.handleHubType = this.handleHubType.bind(this)
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
    // console.log(this.state[key1]);
  }

  resetAuto () {
    // this.state.autoListener[target].clearListeners();
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

  saveNewHub () {
    const { hub, address } = this.state
    const preppedLocation = {}
    const preppedHub = {}
    preppedLocation.street_number = address.street_number
    preppedLocation.street = address.street
    preppedLocation.zip_code = address.zipCode
    preppedLocation.city = address.city
    preppedLocation.country = address.country
    preppedLocation.latitude = address.latitude
    preppedLocation.longitude = address.longitude
    preppedLocation.geocoded_address = address.geocoded_address

    preppedHub.name = hub.name
    preppedHub.hub_type = hub.hubType
    preppedHub.trucking_type = hub.truckingType
    preppedHub.latitude = address.latitude
    preppedHub.longitude = address.longitude
    this.props.saveHub(preppedHub, preppedLocation)
    this.props.close()
  }

  render () {
    const { theme, t } = this.props
    const { hub, address } = this.state
    const hubTypes = [
      { value: 'ocean', label: t('admin:port') },
      { value: 'air', label: t('admin:airport') },
      { value: 'rail', label: t('admin:railyard') },
      { value: 'trucking', label: t('admin:truckingDepot') }
    ]

    const StyledSelect = styled(Select)`
      width: 100%;
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
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }

    return (

      <div className={`${styles.hub_form} layout-row flex-none layout-wrap layout-align-center`}>
        <div className="flex-100 layout-row layout-wrap layout-align-start-center">
          <div className="flex-5" />
          <h2 className="flex-none clip letter_3 margin_5" style={textStyle}>
            {t('admin:addNewHub')}
          </h2>
        </div>
        <div className={`flex-100 layout-row layout-align-start-center layout-wrap ${styles.map_padding}`}>
          <div className="flex-100 layout-row layout-align-start-center margin_5">
            <p className="flex-none offset-5">{t('admin:findHubOrLocation')}</p>
          </div>
          <GmapsWrapper
            theme={theme}
            component={PlaceSearch}
            handlePlaceChange={this.handlePlaceChange}
          />
        </div>
        <div
          className={`flex-100 layout-row layout-wrap layout-align-start-center ${
            styles.form_padding
          }`}
        >
          <div className="flex-50 layout-row layout-wrap layout-align-start-start height_100">
            <p className="flex-100">{t('admin:ensureNameHub')}</p>
            <div className="flex-80 layout-row layout-align-center-center input_box_full">
              <input
                name="hub-name"
                className={`flex-none ${styles.input}`}
                type="string"
                onChange={this.handleAddressChange}
                value={hub.name}
                placeholder={t('admin:name')}
              />
            </div>
            <div className="flex-80 layout-row layout-align-center-center">
              <StyledSelect
                placeholder={t('admin:hubType')}
                className={styles.select}
                name="hub-type"
                value={hub.hubType}
                options={hubTypes}
                onChange={this.handleHubType}
              />
            </div>
          </div>
          <div className="flex-50 layout-row layout-wrap layout-align-end-space-around">
            <p className="flex-100">{t('admin:fillAddress')}</p>
            <div className="flex-100 layout-row layout-align-space-around-center">
              <div className="flex-20 layout-row layout-align-center-center input_box_full">
                <input
                  id="not-auto"
                  name="address-street_number"
                  className={`flex-none ${styles.input}`}
                  type="string"
                  onChange={this.handleAddressChange}
                  value={address.street_number}
                  placeholder={t('user:number')}
                />
              </div>
              <div className="flex-75 layout-row layout-align-center-center input_box_full">
                <input
                  name="address-street"
                  className={`flex-none ${styles.input}`}
                  type="string"
                  onChange={this.handleAddressChange}
                  value={address.street}
                  placeholder={t('user:street')}
                />
              </div>
            </div>
            <div className="flex-100 layout-row layout-align-space-around-center">
              <div className="flex-30 layout-row layout-align-center-center input_box_full">
                <input
                  name="address-zipCode"
                  className={`flex-none ${styles.input}`}
                  type="string"
                  onChange={this.handleAddressChange}
                  value={address.zipCode}
                  placeholder={t('user:zipCode')}
                />
              </div>
              <div className="flex-65 layout-row layout-align-center-center input_box_full">
                <input
                  name="address-city"
                  className={`flex-none ${styles.input}`}
                  type="string"
                  onChange={this.handleAddressChange}
                  value={address.city}
                  placeholder={t('user:city')}
                />
              </div>
            </div>

            <div className="flex-100 layout-row layout-align-space-around-center">
              <div className="flex-100 layout-row layout-align-center-center input_box_full">
                <input
                  name="address-country"
                  className={`flex-none ${styles.input}`}
                  type="string"
                  onChange={this.handleAddressChange}
                  value={address.country}
                  placeholder={t('user:country')}
                />
              </div>
            </div>
          </div>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-space-around-center">
          <div
            className="flex-none layout-row"
          >
            <RoundButton
              theme={theme}
              size="small"
              text={t('common:clear')}
              handleNext={() => this.resetAuto('address')}
              iconClass="fa-times"
            />
          </div>
          <div className="flex-none layout-row">
            <RoundButton
              theme={theme}
              size="small"
              text={t('admin:saveHub')}
              active
              handleNext={this.saveNewHub}
              iconClass="fa-floppy"
            />
          </div>
          <div className="flex-5" />
        </div>
      </div>

    )
  }
}

AdminHubForm.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  saveHub: PropTypes.func.isRequired,
  close: PropTypes.func.isRequired
}

AdminHubForm.defaultProps = {
  theme: null
}

export default withNamespaces(['admin', 'user', 'common'])(AdminHubForm)

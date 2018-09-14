import React, { Component } from 'react'
import { translate } from 'react-i18next'
import { v4 } from 'uuid'
import Truncate from 'react-truncate'
import PropTypes from '../../prop-types'
import styles from './UserAccount.scss'
import defaults from '../../styles/default_classes.scss'
// eslint-disable-next-line no-named-as-default
import EditLocation from './EditLocation'
// eslint-disable-next-line no-named-as-default
import EditLocationWrapper from '../../hocs/EditLocationWrapper'
import { gradientTextGenerator } from '../../helpers'

class UserLocations extends Component {
  constructor (props) {
    super(props)
    this.state = {
      activeView: 'allLocations'
    }
    this.saveLocation = this.saveLocation.bind(this)
    this.toggleActiveView = this.toggleActiveView.bind(this)
    this.destroyLocation = this.destroyLocation.bind(this)
    this.makePrimary = this.makePrimary.bind(this)
    this.editLocation = this.editLocation.bind(this)
    this.saveLocationEdit = this.saveLocationEdit.bind(this)
  }

  componentDidMount () {
    this.props.setNav('locations')
    window.scrollTo(0, 0)
  }

  destroyLocation (locationId) {
    const { userDispatch, user } = this.props
    userDispatch.destroyLocation(user.id, locationId, false)
  }

  saveLocationEdit (location) {
    const { userDispatch, user } = this.props
    userDispatch.editUserLocation(user.id, location)
    this.setState({ activeView: 'allLocations' })
  }

  editLocation (location) {
    this.setState({
      activeView: 'editLocation',
      editLocation: location
    })
  }

  toggleActiveView (key) {
    this.setState({
      activeView: key
    })
  }
  saveLocation (data) {
    const { userDispatch, user } = this.props
    userDispatch.newUserLocation(user.id, data)
    this.toggleActiveView()
  }

  makePrimary (locationId) {
    const { userDispatch, user } = this.props
    userDispatch.makePrimary(user.id, locationId)
  }

  render () {
    const { theme, cols, t } = this.props
    const locInfo = this.props.locations

    const LocationView = (locInfo, makePrimary, toggleActiveView, destroyLocation, editLocation, gradient, cols) => [
      <div
        key="addLocationButton"
        className={`${defaults.pointy} ${cols === 2 ? 'flex-45' : 'flex-30'} flex-md-45 margin_bottom layout-row layout-align-start-stretch tile_padding`}
        onClick={() => toggleActiveView('newLocation')}
      >
        <div
          className={`${styles['location-box']} ${
            styles['new-address']
          } layout-row layout-align-center-center layout-wrap`}
        >
          <div className="layout-row layout-align-center flex-100">
            <div className={`${styles['plus-icon']}`} />
          </div>

          <div className="layout-row layout-align-center flex-100">
            <h3>
              {t('user:addLocation')}
            </h3>
          </div>
        </div>
      </div>,
      locInfo.sort((a, b) => b.user.primary - a.user.primary).map(op => (
        <div
          key={v4()}
          className={`${cols === 2 ? 'flex-45' : 'flex-30'} flex-md-45 margin_bottom tile_padding layout-row layout-align-start-stretch ${styles.loc_info}`}
        >
          <div className={`${styles['location-box']} flex-100 layout-column`}>
            <div className={`${styles.header} layout-row layout-align-end-center`}>
              {op.user.primary ? (
                <i className={`fa fa-star clip ${styles.icon_primary}`} style={gradient} />
              ) : (
                <div className={`layout-row ${styles.icon_primary}`}>
                  <div className="layout-row">
                    <div
                      className={`${styles.makePrimary} pointy`}
                      onClick={() => makePrimary(op.location.id)}
                    >
                      <i className="fa fa-star-o clip" style={gradient} />
                    </div>
                  </div>
                </div>
              )}
              <span className={`${defaults.emulate_link}`} onClick={() => editLocation(op.location)}>
                <i className="fa fa-pencil" />
              </span>
              <span
                className={`${defaults.emulate_link}`}
                onClick={() =>
                  destroyLocation(op.location.id)
                }
              >
                <i className={`fa fa-trash ${styles.icon_trash}`} />
              </span>
            </div>
            <div className={`layout-row flex-100 ${styles.location_address}`}>
              <i className="flex-10 fa fa-map-marker clip" style={gradient} />
              <div className={`${styles.content} flex layout-wrap layout-align-space-between`}>
                {op && op.location.street_number && op.location.street ? (
                  <p className="flex-100">{op.location.street_number} {op.location.street} </p>
                ) : ''}
                {op.location.city ? (
                  <p className="flex-100"><strong>{op.location.city}</strong></p>
                ) : ''}
                {op.location.zip_code ? (
                  <p className="flex-100">{op.location.zip_code}</p>
                ) : ''}
                {op.location.country ? (
                  <p className="flex-100"> <Truncate lines={2}>{op.location.country} </Truncate></p>
                ) : ''}
              </div>
            </div>
          </div>
        </div>
      ))
    ]

    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    let activeView
    switch (this.state.activeView) {
      case 'allLocations':
        activeView = locInfo
          ? LocationView(
            locInfo,
            this.makePrimary,
            this.toggleActiveView,
            this.destroyLocation,
            this.editLocation,
            gradientFontStyle,
            cols,
            t
          )
          : undefined
        break
      case 'addLocation':
        activeView = undefined
        break
      case 'newLocation':
        activeView = (
          <EditLocationWrapper
            theme={this.props.theme}
            component={EditLocation}
            toggleActiveView={this.toggleActiveView}
            locationId={undefined}
            saveLocation={this.saveLocation}
          />
        )
        break
      case 'editLocation':
        activeView = (
          <EditLocationWrapper
            theme={this.props.theme}
            component={EditLocation}
            toggleActiveView={this.toggleActiveView}
            locationId={undefined}
            location={this.state.editLocation}
            saveLocation={this.saveLocationEdit}
          />
        )
        break
      default:
        activeView = LocationView(locInfo, gradientFontStyle, cols, t)
    }

    return (
      <div className="layout-row flex-100 layout-wrap layout-margin">{activeView}</div>
    )
  }
}

UserLocations.propTypes = {
  user: PropTypes.user.isRequired,
  t: PropTypes.func.isRequired,
  setNav: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  userDispatch: PropTypes.shape({
    makePrimary: PropTypes.func,
    newUserLocation: PropTypes.func,
    destroyLocation: PropTypes.func
  }).isRequired,
  cols: PropTypes.number,
  locations: PropTypes.arrayOf(PropTypes.location)
}

UserLocations.defaultProps = {
  theme: null,
  locations: [],
  cols: 3
}

export default translate('common')(UserLocations)

import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
// eslint-disable-next-line no-named-as-default
import EditLocation from './EditLocation'
// eslint-disable-next-line no-named-as-default
import EditLocationWrapper from '../../hocs/EditLocationWrapper'
import { gradientTextGenerator } from '../../helpers'
import UserLocationsBox from './UserLocationsBox'

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
    this.toggleActiveView()
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

    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    let activeView
    switch (this.state.activeView) {
      case 'allLocations':
        activeView = locInfo
          ? (<UserLocationsBox
            locations={locInfo}
            makePrimary={this.makePrimary}
            toggleActiveView={this.toggleActiveView}
            destroyLocation={this.destroyLocation}
            editLocation={this.editLocation}
            gradient={gradientFontStyle}
            cols={cols}
            t={t}
          />)
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
        activeView = locInfo
          ? (<UserLocationsBox
            locations={locInfo}
            makePrimary={this.makePrimary}
            toggleActiveView={this.toggleActiveView}
            destroyLocation={this.destroyLocation}
            editLocation={this.editLocation}
            gradient={gradientFontStyle}
            cols={cols}
            t={t}
          />)
          : undefined
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

export default withNamespaces(['common', 'user'])(UserLocations)

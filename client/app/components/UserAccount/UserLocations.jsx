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
    this.destroyAddress = this.destroyAddress.bind(this)
    this.makePrimary = this.makePrimary.bind(this)
    this.editLocation = this.editLocation.bind(this)
    this.saveLocationEdit = this.saveLocationEdit.bind(this)
  }

  componentDidMount () {
    this.props.setNav('addresses')
    window.scrollTo(0, 0)
  }

  destroyAddress (addressId) {
    const { userDispatch, user } = this.props
    userDispatch.destroyAddress(user.id, addressId, false)
  }

  saveLocationEdit (address) {
    const { userDispatch, user } = this.props
    userDispatch.editUserAddress(user.id, address)
    this.toggleActiveView()
  }

  editLocation (address) {
    this.setState({
      activeView: 'editLocation',
      editLocation: address
    })
  }

  toggleActiveView (key) {
    this.setState({
      activeView: key
    })
  }
  saveLocation (data) {
    const { userDispatch, user } = this.props
    userDispatch.newUserAddress(user.id, data)
    this.toggleActiveView()
  }

  makePrimary (addressId) {
    const { userDispatch, user } = this.props
    userDispatch.makePrimary(user.id, addressId)
  }

  render () {
    const { theme, cols, t } = this.props
    const locInfo = this.props.addresses

    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    let activeView
    switch (this.state.activeView) {
      case 'allLocations':
        activeView = locInfo
          ? (<UserLocationsBox
            addresses={locInfo}
            makePrimary={this.makePrimary}
            toggleActiveView={this.toggleActiveView}
            destroyAddress={this.destroyAddress}
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
            addressId={undefined}
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
            addressId={undefined}
            address={this.state.editLocation}
            saveLocation={this.saveLocationEdit}
          />
        )
        break
      default:
        activeView = locInfo
          ? (<UserLocationsBox
            addresses={locInfo}
            makePrimary={this.makePrimary}
            toggleActiveView={this.toggleActiveView}
            destroyAddress={this.destroyAddress}
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
    newUserAddress: PropTypes.func,
    destroyAddress: PropTypes.func
  }).isRequired,
  cols: PropTypes.number,
  addresses: PropTypes.arrayOf(PropTypes.address)
}

UserLocations.defaultProps = {
  theme: null,
  addresses: [],
  cols: 3
}

export default withNamespaces(['common', 'user'])(UserLocations)

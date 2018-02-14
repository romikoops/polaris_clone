import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import { RouteSelector } from '../RouteSelector/RouteSelector'

export class AvailableRoutes extends Component {
  constructor (props) {
    super(props)
    this.viewShipment = this.viewShipment.bind(this)
    this.makePrimary = this.makePrimary.bind(this)
    this.startBooking = this.startBooking.bind(this)
    this.routeSelected = this.routeSelected.bind(this)
  }
  viewShipment (shipment) {
    const { userDispatch } = this.props
    userDispatch.getShipment(shipment.id, true)
  }
  startBooking () {
    this.props.userDispatch.goTo('/booking')
  }
  makePrimary (locationId) {
    const { userDispatch, user } = this.props
    userDispatch.makePrimary(user.id, locationId)
  }
  routeSelected (route) {
    this.props.routeSelected(route)
  }
  render () {
    const { user, theme, routes } = this.props
    return (
      <RouteSelector
        user={user}
        theme={theme}
        routes={routes}
        routeSelected={this.routeSelected}
      />
    )
  }
}
AvailableRoutes.propTypes = {
  routes: PropTypes.arrayOf(PropTypes.route),
  theme: PropTypes.theme,
  user: PropTypes.user,
  userDispatch: PropTypes.shape({
    getShipment: PropTypes.func,
    goTo: PropTypes.func
  }).isRequired,
  routeSelected: PropTypes.func.isRequired
}

AvailableRoutes.defaultProps = {
  theme: null,
  routes: [],
  user: null
}

export default AvailableRoutes

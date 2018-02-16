import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import { RouteSelector } from '../RouteSelector/RouteSelector'

export class AvailableRoutes extends Component {
  constructor (props) {
    super(props)
    this.startBooking = this.startBooking.bind(this)
    this.routeSelected = this.routeSelected.bind(this)
  }
  startBooking () {
    this.props.userDispatch.goTo('/booking')
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

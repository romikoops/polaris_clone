import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import { AdminShipmentsComp } from '../Admin/Shipments/Comp'

export class UserShipments extends Component {
  componentDidMount () {
    window.scrollTo(0, 0)
    this.props.setNav('shipments')
    this.props.setCurrentUrl(this.props.match.url)
  }

  render () {
    return (
      <div
        className="flex-100 layout-row layout-wrap layout-align-start-start
        extra_padding header_buffer"
      >
        <AdminShipmentsComp isUser />
      </div>
    )
  }
}

UserShipments.propTypes = {
  setNav: PropTypes.func.isRequired,
  setCurrentUrl: PropTypes.func.isRequired
}

UserShipments.defaultProps = {
}

export default UserShipments

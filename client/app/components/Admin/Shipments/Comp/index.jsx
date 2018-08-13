import React, { PureComponent } from 'react'
import PropTypes from 'prop-types'
import ShipmentsCompUser from './User' // eslint-disable-line
import ShipmentsCompAdmin from './Admin' // eslint-disable-line

export class AdminShipmentsComp extends PureComponent {
  render () {
    const {
      isUser
    } = this.props
    return isUser ? <ShipmentsCompUser /> : <ShipmentsCompAdmin />
  }
}
AdminShipmentsComp.propTypes = {
  isUser: PropTypes.bool
}

AdminShipmentsComp.defaultProps = {
  isUser: false
}

export default AdminShipmentsComp

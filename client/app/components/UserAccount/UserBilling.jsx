import React, { Component } from 'react'
import PropTypes from 'prop-types'
// import styles from './UserAccount.scss';

export class UserBilling extends Component {
  componentDidMount () {
    this.props.setNav('billing')
  }

  render () {
    return <h1>UserBilling</h1>
  }
}

UserBilling.propTypes = {
  setNav: PropTypes.func.isRequired
}

export default UserBilling

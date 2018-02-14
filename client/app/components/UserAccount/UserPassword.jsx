import React, { Component } from 'react'
import PropTypes from '../../prop-types'
// import styles from './UserAccount.scss';

export class UserPassword extends Component {
  componentDidMount () {
    this.props.setNav('password')
  }

  render () {
    return <h1>UserPassword</h1>
  }
}

UserPassword.propTypes = {
  setNav: PropTypes.func.isRequired
}

export default UserPassword

import React, { Component } from 'react'
import PropTypes from 'prop-types'
// import styles from './UserAccount.scss';

export class UserEmails extends Component {
  componentDidMount () {
    this.props.setNav('emails')
  }

  render () {
    return <h1>UserEmails</h1>
  }
}

UserEmails.propTypes = {
  setNav: PropTypes.func.isRequired
}

export default UserEmails

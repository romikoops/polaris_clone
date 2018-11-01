import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
// import styles from './UserAccount.scss';

class UserEmails extends Component {
  componentDidMount () {
    this.props.setNav('emails')
  }

  render () {
    const { t } = this.props

    return (
      <h1>
        {t('user:userEmails')}
      </h1>)
  }
}

UserEmails.propTypes = {
  t: PropTypes.func.isRequired,
  setNav: PropTypes.func.isRequired
}

export default withNamespaces('user')(UserEmails)

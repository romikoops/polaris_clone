import React, { Component } from 'react'
import { translate } from 'react-i18next'
import PropTypes from '../../prop-types'

class UserPassword extends Component {
  componentDidMount () {
    this.props.setNav('password')
  }

  render () {
    const { t } = this.props

    return (<h1>
      {t('user:userPassword')}
    </h1>)
  }
}

UserPassword.propTypes = {
  t: PropTypes.func.isRequired,
  setNav: PropTypes.func.isRequired
}

export default translate('user')(UserPassword)

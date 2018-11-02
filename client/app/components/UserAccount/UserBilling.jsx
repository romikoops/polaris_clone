import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'

class UserBilling extends Component {
  componentDidMount () {
    this.props.setNav('billing')
  }

  render () {
    const { t } = this.props

    return <h1>{t('user:userBilling')}</h1>
  }
}

UserBilling.propTypes = {
  setNav: PropTypes.func.isRequired,
  t: PropTypes.func.isRequired
}

export default withNamespaces('user')(UserBilling)

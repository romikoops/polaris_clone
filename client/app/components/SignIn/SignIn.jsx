import React from 'react'
import { withNamespaces } from 'react-i18next'
import { PageHeader } from 'react-bootstrap'
import { EmailSignInForm } from 'redux-auth/bootstrap-theme'
import { browserHistory } from 'react-router'
import PropTypes from '../../prop-types'

function SignIn ({ t }) {
  return (
    <div>
      <PageHeader>{t('account:signInFirst')}</PageHeader>
      <p>{t('account:unauthenticated')}</p>
      <EmailSignInForm next={() => browserHistory.push('/account')} />
    </div>
  )
}

SignIn.propTypes = {
  t: PropTypes.func.isRequired
}
export default withNamespaces('account')(SignIn)

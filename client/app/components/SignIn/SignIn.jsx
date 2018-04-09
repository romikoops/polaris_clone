import React from 'react'
import { PageHeader } from 'react-bootstrap'

import { EmailSignInForm } from 'redux-auth/bootstrap-theme'
import { browserHistory } from 'react-router'

export function SignIn () {
  return (
    <div>
      <PageHeader>Sign In First</PageHeader>
      <p>Unauthenticated users can't access the account page.</p>
      <EmailSignInForm next={() => browserHistory.push('/account')} />
    </div>
  )
}

export default SignIn

import React, {Component} from 'react';
import { PageHeader } from 'react-bootstrap';

import { EmailSignInForm } from 'redux-auth/bootstrap-theme';
import { browserHistory } from 'react-router';

export class SignIn extends Component {
    render() {
        return (
          <div>
            <PageHeader>Sign In First</PageHeader>
            <p>Unauthenticated users can't access the account page.</p>
            <EmailSignInForm next={() => browserHistory.push('/account')} />
          </div>
        );
    }
}


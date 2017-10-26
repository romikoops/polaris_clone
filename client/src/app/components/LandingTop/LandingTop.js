import React, {Component} from 'react';
import {EmailSignInForm} from 'redux-auth/bootstrap-theme';
export class LandingTop extends Component {
  render() {
    return (
      <div className="landing_top col-12 row">
        <div className="col-xs-12 col-md-6 col-lg-6">
          <EmailSignInForm/>
        </div>
        <div className="col-xs-12 col-md-6 col-lg-6">
          <h1> {'Signu'} </h1>
        </div>
      </div>
    );
  }
}

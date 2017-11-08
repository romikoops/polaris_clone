import React, {Component} from 'react';
// import {EmailSignInForm} from 'redux-auth/bootstrap-theme';
import './Footer.scss';
// import SignIn from '../SignIn/SignIn';
export class Footer extends Component {
    render() {
        return (
      <div className="footer layout-row flex-100 layout-wrap">
        <div className="flex-100 button_row layout-row layout-align-end-center">
          <div className="flex-50 buttons layout-row layout-align-end-center">
            <div className="flex-25 layout-row layout-align-center-center">
              <h4 className="flex-none"> About Us</h4>
            </div>
            <div className="flex-25 layout-row layout-align-center-center">
              <h4 className="flex-none"> Privacy Policy</h4>
            </div>
            <div className="flex-25 layout-row layout-align-center-center">
              <h4 className="flex-none"> Terms and Conditions</h4>
            </div>
            <div className="flex-25 layout-row layout-align-center-center">
              <h4 className="flex-none"> Imprint </h4>
            </div>

          </div>
          <div className="flex-20">
          </div>
        </div>
        <div className="flex-100 copyright">
          <div className="flex-80 layout-row layout-align-end-center">
            <p className="flex-none"> Copyright © 2017 Greencarrier </p>
          </div>
          <div className="flex-20">
          </div>
        </div>
      </div>
    );
    }
}

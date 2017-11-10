import React, {Component} from 'react';
import {LoginPage} from '../../containers/LoginPage';
import './LandingTop.scss';
import PropTypes from 'prop-types';
// import SignIn from '../SignIn/SignIn';  default LandingTop;
export class LandingTop extends Component {
    render() {
        console.log(this.props);
        let logo;
        if (this.props.tenant && this.props.tenant.theme) {
            logo = this.props.tenant.theme.logo;
        } else {
            logo = '';
        }
        return (
            <div className="landing_top layout-row flex-100 layout-align-center">
              <div className="landing_top layout-row flex-75 layout-wrap">
                <div className="top_row flex-100 layout-row">
                  <div className="logo_row flex-50 layout-row layout-align-start-center">
                    <img className="tenant_logo" src={logo} />
                  </div>
                  <div className="sign_in_row flex-50 layout-row layout-align-end-center">
                  </div>
                </div>
                <div className="flex-100 flex-gt-sm-50">
                  <LoginPage />
                </div>
                <div className="flex-100 flex-gt-sm-50">
                  <h1> {'Signup'} </h1>
                </div>
              </div>
            </div>
        );
    }
}

LandingTop.propTypes = {
    tenant: PropTypes.object
};



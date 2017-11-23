import React, {Component} from 'react';
import {LoginPage} from '../../containers/LoginPage';
import './LandingTop.scss';
import PropTypes from 'prop-types';
import { RoundButton } from '../RoundButton/RoundButton';

// import SignIn from '../SignIn/SignIn';  default LandingTop;
export class LandingTop extends Component {
    render() {
        console.log(this.props);
        let logo;
        const theme = this.props.theme;
        if (theme) {
            logo = theme.logo;
        } else {
            logo = '';
        }
        return (
            <div className="landing_top layout-row flex-100 layout-align-center">
              <div className="layout-row flex-75 layout-wrap">
                <div className="top_row flex-100 layout-row">
                  <div className="logo_row flex-50 layout-row layout-align-start-center">
                    <img className="tenant_logo" src={logo} />
                  </div>
                  <div className="sign_in_row flex-50 layout-row layout-align-end-center">
                  </div>
                </div>
                <div className="flex-100 flex-gt-sm-50">
                  <LoginPage theme={theme} />
                </div>
                <div className="flex-100 flex-gt-sm-50 sign_up">
                  <h2>Never spend precious time on trasportation again LCL shipping made simple</h2>
                  <h3>Enjoy the most advanced and easy to use booking system in the market</h3>
                  <RoundButton text="sign up" theme={theme} active/>
                </div>
              </div>
            </div>
        );
    }
}

LandingTop.propTypes = {
    theme: PropTypes.object
};



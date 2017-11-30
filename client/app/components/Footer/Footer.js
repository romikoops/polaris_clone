import React, { Component } from 'react';
// import {EmailSignInForm} from 'redux-auth/bootstrap-theme';
import './Footer.scss';
// import SignIn from '../SignIn/SignIn';
export class Footer extends Component {
    render() {
        const { theme } = this.props;
        const primaryColor = {
            color: theme && theme.colors ? theme.colors.primary : 'black'
        };
        let logo = theme && theme.logoLarge ? theme.logoLarge : '';
        if (!logo && theme && theme.logoSmall) logo = theme.logoSmall;
        return (
            <div>
                <div className="contact_bar flex-100 layout-row layout-align-center-center">
                    <div className="flex-none content-width layout-row">
                        <div className="flex-50 layout-row layout-align-start-center">
                            <img src={logo} />
                        </div>
                        <div className="flex-50 layout-row layout-align-end-end">
                            <div className="flex-none layout-row layout-align-center-center contact_elem">
                                 <i className="fa fa-envelope" aria-hidden="true" style={primaryColor}></i>
                                 [ TBD - support@greencarrier.com ]
                            </div>
                            <div className="flex-none layout-row layout-align-center-end contact_elem">
                                 <i className="fa fa-phone" aria-hidden="true" style={primaryColor}></i>
                                 [ TBD - 0172 304 203 1020 ]
                            </div>
                        </div>
                    </div>
                </div>

                <div className="footer layout-row flex-100 layout-wrap">
                    <div className="flex-100 button_row layout-row layout-align-end-center">
                        <div className="flex-50 buttons layout-row layout-align-end-center">
                            <div className="flex-25 layout-row layout-align-center-center">
                                <a href="#">About Us</a>
                            </div>
                            <div className="flex-25 layout-row layout-align-center-center">
                                <a href="#">Privacy Policy</a>
                            </div>
                            <div className="flex-25 layout-row layout-align-center-center">
                                <a href="#">Terms and Conditions</a>
                            </div>
                            <div className="flex-25 layout-row layout-align-center-center">
                                <a href="#">Imprint</a>
                            </div>
                        </div>
                        <div className="flex-20" />
                    </div>
                    <div className="flex-100 layout-row copyright">
                        <div className="flex-80 layout-row layout-align-end-center">
                            <p className="flex-none">
                                [ TBD - Copyright © 2017 Greencarrier ]
                            </p>
                        </div>
                        <div className="flex-20" />
                    </div>
                </div>
            </div>
        );
    }
}

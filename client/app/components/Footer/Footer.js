import React, { Component } from 'react';
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
        );
    }
}

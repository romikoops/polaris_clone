import React, {Component} from 'react';
import {CardLinkRow} from '../CardLinkRow/CardLinkRow';
import './LandingTopAuthed.scss';
import PropTypes from 'prop-types';
// import SignIn from '../SignIn/SignIn';  default LandingTop;
export class LandingTopAuthed extends Component {
    constructor(props) {
        super(props);
        this.state = {
            shops: [
                {
                    name: 'Open Shop',
                    url: '/open',
                    img: 'https://assets.itsmycargo.com/assets/images/welcome/country/performance.jpg'
                },
                {
                    name: 'Dedicated Shop',
                    url: '/dedicated',
                    img: 'https://assets.itsmycargo.com/assets/images/welcome/country/shipping-containers.jpg'
                }
            ]
        };
    }
    render() {
        console.log(this.props);
        let logo;
        if (this.props.theme) {
            logo = this.props.theme.logo;
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
                <div className="flex-100 layout-wrap layout-row">
                  <CardLinkRow theme={this.props.theme} cardArray={this.state.shops} />
                </div>
              </div>
            </div>
        );
    }
}

LandingTopAuthed.propTypes = {
    theme: PropTypes.object
};

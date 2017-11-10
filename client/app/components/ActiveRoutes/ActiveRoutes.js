import React, {Component} from 'react';
// import {EmailSignInForm} from 'redux-auth/bootstrap-theme';
import './ActiveRoutes.scss';
import PropTypes from 'prop-types';
// import SignIn from '../SignIn/SignIn';
export class ActiveRoutes extends Component {
    render() {
        const activeRoutesData = [
            {
                name: 'New York',
                country: 'USA',
                image: 'https://s3.eu-central-1.amazonaws.com/imcdev/assets/images/welcome/country/NY.jpg'
            },
            {
                name: 'Shanghai',
                country: 'China',
                image: 'https://s3.eu-central-1.amazonaws.com/imcdev/assets/images/welcome/country/shanghai.jpg'
            },
            {
                name: 'Singapore',
                country: 'Singapore',
                image: 'https://s3.eu-central-1.amazonaws.com/imcdev/assets/images/welcome/country/Singapore.jpg'
            },
            {
                name: 'Seoul',
                country: 'South Korea',
                image: 'https://s3.eu-central-1.amazonaws.com/imcdev/assets/images/welcome/country/seoul.jpg'
            },
            {
                name: 'Hanoi',
                country: 'Vietnam',
                image: 'https://s3.eu-central-1.amazonaws.com/imcdev/assets/images/welcome/country/Hanoi.jpg'
            },
            {
                name: 'Shenzhen',
                country: 'China',
                image: 'https://s3.eu-central-1.amazonaws.com/imcdev/assets/images/welcome/country/Shenzhen.jpg'
            }
        ];
        const theme = this.props.tenant.theme;
        const activeRouteBoxes = [];
        activeRoutesData.map((route, index) => {
            let divStyle = {
                backgroundImage: 'url(' + route.image + ')',
            };
            let textStyle = {
                background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
            };

            const arb = (<div key={index} className="active_route flex-33 layout-row layout-align-center-center" style={divStyle}>
                <div className="flex-none layout-column layout-align-center-center">
                  <h2 className="city flex-none" style={textStyle} > {route.name} </h2>
                  <h5 className="country flex-none"> {route.name} </h5>
                </div>
            </div>);
            activeRouteBoxes.push(arb);
        });
        return (
      <div className="layout-row flex-100 layout-wrap active_routes">
        <div className="service_label layout-row layout-align-center-center flex-100">
            <h2 className="flex-none"> Active LCL Routes </h2>
        </div>
        {activeRouteBoxes}
      </div>
    );
    }
}

ActiveRoutes.propTypes = {
    tenant: PropTypes.object
};

import React, { Component } from 'react';
// import {EmailSignInForm} from 'redux-auth/bootstrap-theme';
import styles from './ActiveRoutes.scss';
import PropTypes from 'prop-types';
// import SignIn from '../SignIn/SignIn';
export class ActiveRoutes extends Component {
    render() {
        const activeRoutesData = [
            {
                name: 'New York',
                country: 'USA',

                image: 'https://assets.itsmycargo.com/assets/cityimages/NY_sm.jpg'
            },
            {
                name: 'Shanghai',
                country: 'China',
                image: 'https://assets.itsmycargo.com/assets/cityimages/shanghai_sm.jpg'
            },
            {
                name: 'Singapore',
                country: 'Singapore',

                image: 'https://assets.itsmycargo.com/assets/cityimages/Singapore_sm.jpg'
            },
            {
                name: 'Seoul',
                country: 'South Korea',

                image: 'https://assets.itsmycargo.com/assets/cityimages/seoul_sm.jpg'

            },
            {
                name: 'Hanoi',
                country: 'Vietnam',

                image: 'https://assets.itsmycargo.com/assets/cityimages/Hanoi_sm.jpg'

            },
            {
                name: 'Shenzhen',
                country: 'China',

                image: 'https://assets.itsmycargo.com/assets/cityimages/Shenzhen_sm.jpg'

            }
        ];
        // const theme = this.props.theme;
        const activeRouteBoxes = [];
        activeRoutesData.map((route, index) => {
            const divStyle = {
                backgroundImage: 'url(' + route.image + ')'
            };


            const arb = (<div key={index} className={styles.active_route + ' flex-33 layout-row layout-align-center-center'} style={divStyle}>
                <div className="flex-none layout-column layout-align-center-center">
                    <h2 className={styles.city + ' flex-none'}> {route.name} </h2>
                    <h5 className={styles.country + ' flex-none'}> {route.country} </h5>
                </div>
                </div>
            );
            activeRouteBoxes.push(arb);
        });
        return (
            <div className={'layout-row flex-100 layout-wrap ' + styles.active_routes}>
                <div className={styles.service_label + ' layout-row layout-align-center-center flex-100'}>

                    <h2 className="flex-none">Active LCL Routes</h2>
                </div>
                {activeRouteBoxes}
            </div>
        );
    }
}

ActiveRoutes.propTypes = {
    theme: PropTypes.object
};

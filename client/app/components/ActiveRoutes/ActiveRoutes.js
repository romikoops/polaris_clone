import React, { Component } from 'react';
// import {EmailSignInForm} from 'redux-auth/bootstrap-theme';
import styles from './ActiveRoutes.scss';
import PropTypes from 'prop-types';
import {Carousel} from '../Carousel/Carousel';
// import SignIn from '../SignIn/SignIn';
export class ActiveRoutes extends Component {
    render() {
        const activeRoutesData = [
            {
                header: 'New York',
                subheader: 'USA',

                image: 'https://assets.itsmycargo.com/assets/cityimages/NY_sm.jpg'
            },
            {
                header: 'Shanghai',
                subheader: 'China',
                image: 'https://assets.itsmycargo.com/assets/cityimages/shanghai_sm.jpg'
            },
            {
                header: 'Singapore',
                subheader: 'Singapore',

                image: 'https://assets.itsmycargo.com/assets/cityimages/Singapore_sm.jpg'
            },
            {
                header: 'Seoul',
                subheader: 'South Korea',

                image: 'https://assets.itsmycargo.com/assets/cityimages/seoul_sm.jpg'

            },
            {
                header: 'Hanoi',
                subheader: 'Vietnam',

                image: 'https://assets.itsmycargo.com/assets/cityimages/Hanoi_sm.jpg'

            },
            {
                header: 'Shenzhen',
                subheader: 'China',

                image: 'https://assets.itsmycargo.com/assets/cityimages/Shenzhen_sm.jpg'

            }
        ];

        return (
            <div className={'layout-row flex-100 layout-wrap ' + styles.active_routes}>
                <div className={styles.service_label + ' layout-row layout-align-center-center flex-100'}>

                    <h2 className="flex-none">Active LCL Routes</h2>
                </div>
                <Carousel theme={this.props.theme} slides={activeRoutesData} noSlides={4}/>
            </div>
        );
    }
}

ActiveRoutes.propTypes = {
    theme: PropTypes.object
};

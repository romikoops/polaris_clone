import React, { Component } from 'react';
// import {EmailSignInForm} from 'redux-auth/bootstrap-theme';
import styles from './ActiveRoutes.scss';
import PropTypes from 'prop-types';
import {Carousel} from '../Carousel/Carousel';
import { activeRoutesData } from '../../constants';
const actRoutesData = activeRoutesData;
export class ActiveRoutes extends Component {
    render() {
        return (
            <div className={'layout-row flex-100 layout-wrap ' + styles.active_routes}>
                <div className={styles.service_label + ' layout-row layout-align-center-center flex-100'}>
                    <h2 className="flex-none">Active LCL Routes</h2>
                </div>
                <Carousel theme={this.props.theme} slides={actRoutesData} noSlides={4}/>
            </div>
        );
    }
}

ActiveRoutes.propTypes = {
    theme: PropTypes.object
};

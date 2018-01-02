import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import { AdminShipmentRow, AdminHubTile} from './';
import styles from './Admin.scss';
// import {v4} from 'node-uuid';
export class AdminAddressTile extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, address, hubs} = this.props;
        if (!address) {
            return '';
        }
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        console.log(hubs);
        return(
            <div className={` ${styles.address_card} flex-none layout-row layout-wrap layout-align-start-start`}>
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}>
                    <p className={` ${styles.sec_header_text} ${styles.clip} flex-none`} style={textStyle}>User Location</p>

                </div>

                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className="flex-100 layout-row layout-align-space-between-center">
                        <p className="flex-none"> Street No. </p>
                        <p className="flex-none"> {address.street_number} </p>
                    </div>
                    <div className="flex-100 layout-row layout-align-space-between-center">
                        <p className="flex-none"> Street </p>
                        <p className="flex-none"> {address.street } </p>
                    </div>
                    <div className="flex-100 layout-row layout-align-space-between-center">
                        <p className="flex-none"> City </p>
                        <p className="flex-none"> {address.city} </p>
                    </div>
                    <div className="flex-100 layout-row layout-align-space-between-center">
                        <p className="flex-none"> Zip Code </p>
                        <p className="flex-none"> {address.zip_code} </p>
                    </div>
                    <div className="flex-100 layout-row layout-align-space-between-center">
                        <p className="flex-none"> Country </p>
                        <p className="flex-none"> {address.country} </p>
                    </div>
                </div>
            </div>
        );
    }
}
AdminAddressTile.propTypes = {
    theme: PropTypes.object,
    address: PropTypes.array
};

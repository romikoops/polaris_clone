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
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                    <p className={` ${styles.sec_subheader_text} ${styles.clip} flex-none no_m`} style={textStyle}>User Location</p>

                </div>

                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                        <p className={`flex-100 ${styles.super}`}> Street No. </p>
                        <p className="flex-none no_m"> {address.street_number} </p>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                        <p className={`flex-100 ${styles.super}`}> Street </p>
                        <p className="flex-none no_m"> {address.street } </p>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                        <p className={`flex-100 ${styles.super}`}> City </p>
                        <p className="flex-none no_m"> {address.city} </p>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                        <p className={`flex-100 ${styles.super}`}> Zip Code </p>
                        <p className="flex-none no_m"> {address.zip_code} </p>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                        <p className={`flex-100 ${styles.super}`}> Country </p>
                        <p className="flex-none no_m"> {address.country} </p>
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

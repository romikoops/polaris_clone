import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './UserAccount.scss';

export class UserMergedShipment extends Component  {
    constructor(props) {
        super(props);
    }
    render() {
        const { ship } = this.props;
        return (
            <div className={`flex-100 layout-row layout-align-start-center ${styles.ship_row}`} onClick={() => this.viewShipment(ship)}>
                <div className={`flex-40 layout-row layout-align-start-center ${styles.ship_row_cell}`}>
                    <p className="flex-none">{ship.originHub} - {ship.destinationHub}</p>
                </div>
                <div className={`flex-15 layout-row layout-align-start-center ${styles.ship_row_cell}`}>
                    <p className="flex-none">{ship.imc_reference}</p>
                </div>
                <div className={`flex-15 layout-row layout-align-start-center ${styles.ship_row_cell}`}>
                    <p className="flex-none">{ship.status}</p>
                </div>
                <div className={`flex-15 layout-row layout-align-start-center ${styles.ship_row_cell}`}>
                    <p className="flex-none">{ship.incoterm}</p>
                </div>
                <div className={`flex-15 layout-row layout-align-start-center ${styles.ship_row_cell}`}>
                    <p className="flex-none"> Yes </p>
                </div>
            </div>
        );
    }
}

UserMergedShipment.propTypes = {
    ship: PropTypes.object,
};

import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
export class AdminDashboard extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }

    render() {
        // const {selectedShipment} = this.state;
        // const { theme, hubs, shipments, clients, shipment } = this.props;
        // // debugger;
        // if (!shipments || !hubs || !clients) {
        //     return <h1>NO SHIPMENTS DATA</h1>;
        // }
        // const textStyle = {
        //     background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        // };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <h1 className={` ${styles.sec_title_text} flex-none`} >Dashboard</h1>
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                     <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Requested Shipments</p>
                    </div>
                </div>
            </div>
        );
    }
}
AdminDashboard.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};

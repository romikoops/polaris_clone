import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { UserShipmentRow } from './';
import {v4} from 'node-uuid';
export class UserDashboard extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
        this.viewShipment = this.viewShipment.bind(this);
        this.handleShipmentAction = this.handleShipmentAction.bind(this);
    }
    viewShipment(shipment) {
        const { adminDispatch } = this.props;
        adminDispatch.getShipment(shipment.id, true);
        this.setState({selectedShipment: true});
    }
    
    handleShipmentAction(id, action) {
        const { adminDispatch } = this.props;
        adminDispatch.confirmShipment(id, action);
    }
    dynamicSort(property) {
        let sortOrder = 1;
        let prop;
        if(property[0] === '-') {
            sortOrder = -1;
            prop = property.substr(1);
        } else {
            prop = property;
        }
        return function(a, b) {
            const result1 = a[prop] < b[prop] ? -1 : a[prop] > b[prop];
            const result2 = result1 ? 1 : 0;
            return result2 * sortOrder;
        };
    }

    render() {
        const { theme, dashData, clients } = this.props;
        // debugger;
        if (!dashData) {
            return <h1>NO DASHBOARD DATA</h1>;
        }
        const { routes, shipments, hubs, air, ocean} = dashData;
        const clientHash = {};
        clients.forEach(cl => {
            clientHash[cl.id] = cl;
        });
        const schedArr = [];
        const openShipments = shipments && shipments.open && shipments.open.shipments ? shipments.open.shipments.map((ship) => {
            return <UserShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.viewShipment} handleAction={this.handleShipmentAction} client={clientHash[ship.shipper_id]}/>;
        }) : '';

        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <h1 className={` ${styles.sec_title_text} flex-none`} style={textStyle} >Dashboard</h1>
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Requested Shipments</p>
                    </div>
                    { openShipments }
                </div>
                
            </div>
        );
    }
}
UserDashboard.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};

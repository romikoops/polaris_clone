import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import styles from './UserAccount.scss';
import { UserShipmentRow } from './';
import {v4} from 'node-uuid';
import styles from '../Admin/Admin.scss';
export class UserShipments extends Component {
    constructor(props) {
        super(props);
        this.viewShipment = this.viewShipment.bind(this);
    }
    componentDidMount() {
        this.props.setNav('shipments');
    }
     viewShipment(shipment) {
        const { userDispatch, user } = this.props;
        userDispatch.getShipment(user.data.id, shipment.id, true);
        this.setState({selectedShipment: true});
    }

    render() {
      const { theme, hubs, shipments, user } = this.props;
        // debugger;
        if (!user) {
            return <h1>NO DATA</h1>;
        }

        const openShipments = shipments && shipments.open ? shipments.open.map((ship) => {
            return <UserShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.viewShipment} handleAction={this.handleShipmentAction} client={user}/>;
        }) : '';
        const reqShipments = shipments && shipments.requested ? shipments.requested.map((ship) => {
            return <UserShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.viewShipment} handleAction={this.handleShipmentAction} client={user}/>;
        }) : '';
        const finishedShipments = shipments && shipments.finished ? shipments.finished.map((ship) => {
            return <UserShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.viewShipment} handleAction={this.handleShipmentAction} client={user}/>;
        }) : '';

        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return (
             <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <h1 className={` ${styles.sec_title_text} flex-none`} style={textStyle} >Shipments</h1>
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Open Shipments</p>
                    </div>
                    { openShipments }
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Requested Shipments</p>
                    </div>
                    { reqShipments }
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Finished Shipments</p>
                    </div>
                    { finishedShipments }
                </div>

            </div>
        );
    }
}

UserShipments.propTypes = {
    user: PropTypes.object
};

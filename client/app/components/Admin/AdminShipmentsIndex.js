import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import {AdminShipmentRow } from './';
import {v4} from 'node-uuid';

export class AdminShipmentsIndex extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedShipment: null,
            currentView: 'open'
        };
        this.viewShipment = this.viewShipment.bind(this);
    }
    viewShipment(shipment) {
        this.props.viewShipment(shipment);
    }

    render() {
        console.log(this.props);
        // const {selectedShipment} = this.state;
        const { theme, hubs, shipments, clients, handleShipmentAction } = this.props;
        // debugger;
        if (!shipments || !hubs || !clients) {
            return '';
        }
        const clientHash = {};
        clients.forEach(cl => {
            clientHash[cl.id] = cl;
        });

        // const textStyle = {
        //     background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        // };
        // debugger;
        const openShipments = shipments.open.map((ship) => {
            return <AdminShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.viewShipment} handleAction={handleShipmentAction} client={clientHash[ship.shipper_id]}/>;
        });

        const requestedShipments = shipments.requested.map((ship) => {
            return <AdminShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.viewShipment} handleAction={handleShipmentAction} client={clientHash[ship.shipper_id]}/>;
        });

        const finishedShipments = shipments.finished.map((ship) => {
            return <AdminShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.viewShipment} handleAction={handleShipmentAction} client={clientHash[ship.shipper_id]}/>;
        });
        const listView = (
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  >Requested Shipments</p>
                    </div>
                    {requestedShipments}
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  >Open Shipments</p>
                    </div>
                    {openShipments}
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  >Finished Shipments</p>
                    </div>
                    {finishedShipments}
                </div>
            </div>
        );

        return (
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                { listView }
            </div>
        );
    }
}
AdminShipmentsIndex.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    shipments: PropTypes.object,
    clients: PropTypes.array,
    handleShipmentAction: PropTypes.func
};

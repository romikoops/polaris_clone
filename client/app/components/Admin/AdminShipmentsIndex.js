import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
// import {AdminShipmentRow } from './';
// import {v4} from 'node-uuid';
import { AdminSearchableShipments } from './AdminSearchables';

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
    prepShipment(shipment, clients, hubsObj) {
        shipment.clientName = clients[shipment.shipper_id] ? `${clients[shipment.shipper_id].first_name} ${clients[shipment.shipper_id].last_name}` : '';
        shipment.companyName = clients[shipment.shipper_id] ? `${clients[shipment.shipper_id].company_name}` : '';
        const hubKeys = shipment.schedule_set[0].hub_route_key.split('-');
        shipment.originHub = hubsObj[hubKeys[0]] ? hubsObj[hubKeys[0]].name : '';
        shipment.destinationHub = hubsObj[hubKeys[1]] ? hubsObj[hubKeys[1]].name : '';
        return shipment;
    }

    render() {
        console.log(this.props);
        // const {selectedShipment} = this.state;
        const { theme, hubs, shipments, clients, handleShipmentAction, hubHash } = this.props;
        // ;
        if (!shipments || !hubs || !clients) {
            return '';
        }
        const clientHash = {};
        clients.forEach(cl => {
            clientHash[cl.id] = cl;
        });

        const mergedOpenShipments = shipments.open.map((sh) => {
            return this.prepShipment(sh, clientHash, hubHash);
        });
        const mergedReqShipments = shipments.requested.map((sh) => {
            return this.prepShipment(sh, clientHash, hubHash);
        });
        const mergedFinishedShipments = shipments.finished.map((sh) => {
            return this.prepShipment(sh, clientHash, hubHash);
        });

        const listView = (
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">

                { mergedOpenShipments.length !== 0 ?
                    <AdminSearchableShipments hubs={hubHash} shipments={mergedOpenShipments} title="Open Shipments" theme={theme} handleShipmentAction={handleShipmentAction}/>
                    // <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
                    //     <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                    //         <p className={` ${styles.sec_subheader_text} flex-none`}  > Open</p>
                    //     </div>
                    //     { openShipments }
                    // </div>
                    :
                    ''
                }
                { mergedReqShipments.length !== 0 ?
                    <AdminSearchableShipments hubs={hubHash} shipments={mergedReqShipments} title="Requested Shipments" theme={theme} handleShipmentAction={handleShipmentAction}/>
                    // <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
                    //     <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                    //         <p className={` ${styles.sec_subheader_text} flex-none`}  > Requested</p>
                    //     </div>
                    //     { requestedShipments }
                    // </div>
                    : ''
                }
                { mergedFinishedShipments.length !== 0 ?
                    <AdminSearchableShipments hubs={hubHash} shipments={mergedFinishedShipments} title="Finished Shipments" theme={theme} handleAction={handleShipmentAction}/>
                    // <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
                    //     <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                    //         <p className={` ${styles.sec_subheader_text} flex-none`}  > Finished</p>
                    //     </div>
                    //     { finishedShipments }
                    // </div>
                    : ''
                }
                { mergedOpenShipments.length === 0 && mergedReqShipments.length === 0 && mergedFinishedShipments.length === 0 ?
                    <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
                        <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                            <p className={` ${styles.sec_subheader_text} flex-none`}  > No Shipments yet</p>
                        </div>
                        <p className="flex-none"  > As shipments are requested, they will appear here</p>
                    </div> :
                    ''
                }
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

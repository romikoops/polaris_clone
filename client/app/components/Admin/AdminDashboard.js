import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import { AdminScheduleLine } from './';
import { AdminSearchableRoutes, AdminSearchableHubs, AdminSearchableClients, AdminSearchableShipments } from './AdminSearchables';
import {v4} from 'node-uuid';
import { Loading } from '../../components/Loading/Loading';
export class AdminDashboard extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
        this.viewShipment = this.viewShipment.bind(this);
        this.handleShipmentAction = this.handleShipmentAction.bind(this);
    }

    componentDidMount() {
        const { dashData, loading, adminDispatch } = this.props;
        if (!dashData && !loading) {
            adminDispatch.getDashboard(false);
        } else if (dashData && !dashData.schedules) {
            adminDispatch.getDashboard(false);
        }
    }
    viewShipment(shipment) {
        const { adminDispatch } = this.props;
        adminDispatch.getShipment(shipment.id, true);
        this.setState({selectedShipment: true});
    }
    viewHub(hub) {
        const { adminDispatch } = this.props;
        adminDispatch.getHub(hub.id, true);
        this.setState({selectedHub: true});
    }
    handleShipmentAction(id, action) {
        const { adminDispatch } = this.props;
        adminDispatch.confirmShipment(id, action);
    }
    prepShipment(shipment, clients, hubsObj) {
        shipment.clientName = clients[shipment.shipper_id] ? `${clients[shipment.shipper_id].first_name} ${clients[shipment.shipper_id].last_name}` : '';
        shipment.companyName = clients[shipment.shipper_id] ? `${clients[shipment.shipper_id].company_name}` : '';
        const hubKeys = shipment.schedule_set[0].hub_route_key.split('-');
        shipment.originHub = hubsObj[hubKeys[0]] ? hubsObj[hubKeys[0]].name : '';
        shipment.destinationHub = hubsObj[hubKeys[1]] ? hubsObj[hubKeys[1]].name : '';
        return shipment;
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
        return (a, b) => {
            const result1 = a[prop] < b[prop] ? -1 : a[prop] > b[prop];
            const result2 = result1 ? 1 : 0;
            return result2 * sortOrder;
        };
    }

    render() {
        const { theme, dashData, clients, hubs, hubHash, adminDispatch } = this.props;
        // ;
        if (!dashData) {
            return <Loading theme={theme} />;
        }
        const { routes, shipments, air, ocean} = dashData;
        const clientHash = {};

        console.log(hubHash);

        if (clients) {
            clients.forEach(cl => {
                clientHash[cl.id] = cl;
            });
        }
        const filteredClients = clients ? clients.filter(x => !x.guest) : [];
        const schedArr = [];

        console.log(shipments);

        const mergedRequestedShipments = shipments && shipments.requested ?
            shipments.requested.map((sh) => {
                return this.prepShipment(sh, clientHash, hubHash);
            }) : false;

        const mergedOpenShipments = shipments && shipments.open ?
            shipments.open.map((sh) => {
                return this.prepShipment(sh, clientHash, hubHash);
            }) : false;

        const mergedFinishedShipments = shipments && shipments.finished ?
            shipments.finished.map((sh) => {
                return this.prepShipment(sh, clientHash, hubHash);
            }) : false;

        const requestedShipments = mergedRequestedShipments ?
            <AdminSearchableShipments
                title="Requested Shipments"
                limit={3}
                hubs={hubHash}
                shipments={mergedRequestedShipments}
                adminDispatch={adminDispatch}
                theme={theme}
                handleClick={this.viewShipment}
                handleShipmentAction={this.handleShipmentAction}
            /> : '';

        const openShipments = mergedOpenShipments ?
            <AdminSearchableShipments
                title="Open Shipments"
                limit={3}
                hubs={hubHash}
                shipments={mergedOpenShipments}
                adminDispatch={adminDispatch}
                theme={theme}
                handleClick={this.viewShipment}
                handleShipmentAction={this.handleShipmentAction}
            /> : '';

        const finishedShipments = mergedFinishedShipments ?
            <AdminSearchableShipments
                title="Finished Shipments"
                limit={3}
                hubs={hubHash}
                shipments={mergedFinishedShipments}
                adminDispatch={adminDispatch}
                theme={theme}
                handleClick={this.viewShipment}
                handleShipmentAction={this.handleShipmentAction}
            /> : '';

        if (air) {
            air.forEach(asched => {
                schedArr.push(<AdminScheduleLine key={v4()} schedule={asched} hubs={hubs} theme={theme}/>);
            });
        }
        if (ocean) {
            ocean.forEach(osched => {
                schedArr.push(<AdminScheduleLine key={v4()} schedule={osched} hubs={hubs} theme={theme}/>);
            });
        }
        const shortSchedArr = schedArr.sort(this.dynamicSort('etd')).slice(0, 5);

        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.sec_title}`}>
                    <h1 className={` ${styles.sec_title_text} flex-none`} style={textStyle} >Dashboard</h1>
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    { requestedShipments }
                    { openShipments }
                    { finishedShipments }
                </div>
                <AdminSearchableRoutes routes={routes} theme={theme} hubs={hubs} adminDispatch={adminDispatch} sideScroll/>
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Schedules </p>
                    </div>
                    { shortSchedArr }
                </div>
                <AdminSearchableHubs theme={theme} hubs={hubs} adminDispatch={adminDispatch} sideScroll/>
                <AdminSearchableClients theme={theme} clients={filteredClients} adminDispatch={adminDispatch}/>
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

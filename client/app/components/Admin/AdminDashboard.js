import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import {AdminShipmentRow, AdminRouteTile, AdminScheduleLine, AdminHubTile } from './';
import {v4} from 'node-uuid';
export class AdminDashboard extends Component {
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
    viewHub(hub) {
        const { adminDispatch } = this.props;
        adminDispatch.getHub(hub.id, true);
        this.setState({selectedHub: true});
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
            return <AdminShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.viewShipment} handleAction={this.handleShipmentAction} client={clientHash[ship.shipper_id]}/>;
        }) : '';
        let routesArr;
        if (routes) {
            routesArr = routes.map((rt, i) => {
                if (i <= 5) {
                    return  <AdminRouteTile key={v4()} hubs={hubs} route={rt} theme={theme} handleClick={this.setRoute}/>;
                }
                return '';
            });
        }
        air.forEach(asched => {
            schedArr.push(<AdminScheduleLine key={v4()} schedule={asched} hubs={hubs} theme={theme}/>);
        });
        ocean.forEach(osched => {
            schedArr.push(<AdminScheduleLine key={v4()} schedule={osched} hubs={hubs} theme={theme}/>);
        });
        const hubList = hubs.map((hub, i) =>{
                if (i <= 5) {
                    return <AdminHubTile key={v4()} hub={hub} theme={theme} handleClick={this.viewHub}/>;
                }
                return '';
            }
        );
        const shortSchedArr = schedArr.sort(this.dynamicSort('etd')).slice(0, 5);

        // const requestedShipments = shipments.requested.shipments.map((ship) => {
        //     return <AdminShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.viewShipment} handleAction={handleShipmentAction} client={clientHash[ship.shipper_id]}/>;
        // });

        // const finishedShipments = shipments.finished.shipments.map((ship) => {
        //     return <AdminShipmentRow key={v4()} shipment={ship} hubs={hubs} theme={theme} handleSelect={this.viewShipment} handleAction={handleShipmentAction} client={clientHash[ship.shipper_id]}/>;
        // });
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
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Routes </p>
                    </div>
                    { routesArr }
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Schedules </p>
                    </div>
                    { shortSchedArr }
                </div>
                 <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Hubs </p>
                    </div>
                    { hubList }
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

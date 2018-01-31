import React, { Component } from 'react';
import PropTypes from 'prop-types';
import defaults from '../../styles/default_classes.scss';
import { AdminScheduleLine } from './';
import { AdminSearchableRoutes, AdminSearchableHubs, AdminSearchableClients, AdminSearchableShipments } from './AdminSearchables';
import { RoundButton } from '../RoundButton/RoundButton';
import {v4} from 'node-uuid';
import { Loading } from '../../components/Loading/Loading';
import {Carousel} from '../Carousel/Carousel';
import { activeRoutesData } from '../../constants';
import style from './AdminDashboard.scss';
import { MainTextHeading } from '../TextHeadings/MainTextHeading';
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
            shipments.open.sort(this.dynamicSort('updated_at')).map((sh) => {
                return this.prepShipment(sh, clientHash, hubHash);
            }) : false;

        const mergedFinishedShipments = shipments && shipments.finished ?
            shipments.finished.sort(this.dynamicSort('updated_at')).map((sh) => {
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
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">

                <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${style.dashboard_main}`}>
                    <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${style.dashboard_top}`}>
                        <div className={`flex-100 layout-row ${style.left} layout-align-center-center`}>
                            <div className={`flex-100 layout-row layout-align-start-center ${style.welcome}`}>
                                <h2 className="flex-none">
                                    Welcome back, Admin
                                </h2>
                            </div>
                            <div className={`flex-none layout-row layout-align-center-center ${style.carousel}`}>
                                <Carousel theme={this.props.theme} slides={activeRoutesData} noSlides={1} fade/>
                            </div>
                            <div className={`flex-none layout-row layout-align-center-center ${style.dash_btn}`}>
                                <RoundButton theme={theme} handleNext={this.startBooking} active size="large" text="Make a Booking" iconClass="fa-archive"/>
                            </div>
                            <div className={`flex-50 layout-row ${style.right} layout-wrap layout-align-space-between-space-between`}>
                                <div className={`flex-none layout-row layout-align-center-center ${style.stat_box}`}>
                                    <h1 className="flex-none">
                                        {mergedOpenShipments.length + mergedFinishedShipments.length + mergedRequestedShipments.length}
                                    </h1>
                                    <div className={`flex-none layout-row layout-align-center-center ${style.stat_box_title}`}>
                                        <h3 className="flex-none">
                                            Total Shipments
                                        </h3>
                                    </div>
                                </div>
                                <div className={`flex-none layout-row layout-align-center-center ${style.stat_box}`}>
                                    <h1 className="flex-none">
                                        {mergedRequestedShipments.length}
                                    </h1>
                                    <div className={`flex-none layout-row layout-align-center-center ${style.stat_box_title}`}>
                                        <h3 className="flex-none">
                                            Requested Shipments
                                        </h3>
                                    </div>
                                </div>
                                <div className={`flex-none layout-row layout-align-center-center ${style.stat_box}`}>
                                    <h1 className="flex-none">
                                        {mergedOpenShipments.length}
                                    </h1>
                                    <div className={`flex-none layout-row layout-align-center-center ${style.stat_box_title}`}>
                                        <h3 className="flex-none">
                                            Shipments in Progress
                                        </h3>
                                    </div>
                                </div>
                                <div className={`flex-none layout-row layout-align-center-center ${style.stat_box}`}>
                                    <h1 className="flex-none">
                                        { mergedFinishedShipments.length }
                                    </h1>
                                    <div className={`flex-none layout-row layout-align-center-center ${style.stat_box_title}`}>
                                        <h3 className="flex-none">
                                            Completed Shipments
                                        </h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className={'layout-row flex-100 layout-wrap layout-align-center-center ' + defaults.border_divider}>
                        <MainTextHeading theme={theme} text="Dashboard" />
                        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                            { requestedShipments }
                        </div>
                        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                            { openShipments }
                        </div>
                        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                            { finishedShipments }
                        </div>
                    </div>

                    <div className={'layout-row flex-100 layout-wrap layout-align-center-center ' + defaults.border_divider}>
                        <AdminSearchableRoutes routes={routes} theme={theme} hubs={hubs} adminDispatch={adminDispatch} sideScroll/>
                    </div>
                    <div className={'layout-row flex-100 layout-wrap layout-align-center-center ' + defaults.border_divider}>
                        <MainTextHeading theme={theme} text="Schedules"  />
                    </div>
                    { shortSchedArr }
                    <div className={'layout-row flex-100 layout-wrap layout-align-center-center ' + defaults.border_divider}>
                        <AdminSearchableHubs theme={theme} hubs={hubs} adminDispatch={adminDispatch} sideScroll/>
                    </div>
                    <div className={'layout-row flex-100 layout-wrap layout-align-center-center ' + defaults.border_divider}>
                        <AdminSearchableClients theme={theme} clients={filteredClients} adminDispatch={adminDispatch}/>
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

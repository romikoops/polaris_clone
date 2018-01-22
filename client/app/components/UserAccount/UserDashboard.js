import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin/Admin.scss';
import ustyles from './UserAccount.scss';
import { UserLocations } from './';
import { RoundButton } from '../RoundButton/RoundButton';
// import {v4} from 'node-uuid';
import {Carousel} from '../Carousel/Carousel';
import { activeRoutesData } from '../../constants';
import { AdminSearchableClients } from '../Admin/AdminSearchables';
const actRoutesData = activeRoutesData;

export class UserDashboard extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
        this.viewShipment = this.viewShipment.bind(this);
        this.makePrimary = this.makePrimary.bind(this);
        this.startBooking = this.startBooking.bind(this);
    }
    componentDidMount() {
        this.props.setNav('dashboard');
    }
    viewShipment(shipment) {
        const { userDispatch } = this.props;
        userDispatch.getShipment(shipment.id, true);
        this.setState({selectedShipment: true});
    }
    startBooking() {
        this.props.userDispatch.goTo('/booking');
    }
    prepShipment(shipment, user, hubsObj) {
        shipment.clientName = user ? `${user.first_name} ${user.last_name}` : '';
        shipment.companyName = user ? `${user.company_name}` : '';
        const hubKeys = shipment.schedule_set[0].hub_route_key.split('-');
        shipment.originHub = hubsObj[hubKeys[0]] ? hubsObj[hubKeys[0]].data.name : '';
        shipment.destinationHub = hubsObj[hubKeys[1]] ? hubsObj[hubKeys[1]].data.name : '';
        return shipment;
    }


    doNothing() {
        console.log('');
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
    makePrimary(locationId) {
        const { userDispatch, user } = this.props;
        userDispatch.makePrimary(user.id, locationId);
    }

    render() {
        const { theme, hubs, dashboard, user, userDispatch } = this.props;
        // ;
        if (!user || !dashboard) {
            return <h1>NO DATA</h1>;
        }
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const { shipments, pricings, contacts, locations} = dashboard;
        console.log(pricings);
        const mergedOpenShipments = shipments && shipments.open ? shipments.open.map((sh) => {
            return this.prepShipment(sh, user, hubs);
        }) : false;
        const mergedRequestedShipments = shipments && shipments.requested ? shipments.requested.map((sh) => {
            return this.prepShipment(sh, user, hubs);
        }) : false;
        const mergedFinishedShipments = shipments && shipments.finished ? shipments.finished.map((sh) => {
            return this.prepShipment(sh, user, hubs);
        }) : false;

        // const openShipments = mergedOpenShipments.length > 0 ? <AdminSearchableShipments hubs={hubs} shipments={mergedRequestedShipments} title="Open Shipments" theme={theme} handleClick={this.viewShipment} userView handleShipmentAction={this.handleShipmentAction} seeAll={() => userDispatch.getShipments(true)}/> : '';
        // const reqShipments = mergedRequestedShipments.length > 0 ? <AdminSearchableShipments hubs={hubs} shipments={mergedRequestedShipments} title="Requested Shipments" theme={theme} handleClick={this.viewShipment} userView handleShipmentAction={this.handleShipmentAction} seeAll={() => userDispatch.getShipments(true)}/> : '';
        // const finishedShipments = mergedFinishedShipments.length > 0 ? <AdminSearchableShipments hubs={hubs} shipments={mergedRequestedShipments} title="Finished Shipments" theme={theme} handleClick={this.viewShipment} userView handleShipmentAction={this.handleShipmentAction} seeAll={() => userDispatch.getShipments(true)}/> : '';
        const newReqShips = mergedRequestedShipments.length > 0 ? mergedRequestedShipments.map((ship) => {
            return (
                <div className={`flex-100 layout-row layout-align-start-center ${ustyles.ship_row}`}>
                    <div className={`flex-40 layout-row layout-align-start-center ${ustyles.ship_row_cell}`}>
                        <p className="flex-none">{ship.originHub} - {ship.destinationHub}</p>
                    </div>
                    <div className={`flex-15 layout-row layout-align-start-center ${ustyles.ship_row_cell}`}>
                        <p className="flex-none">{ship.imc_reference}</p>
                    </div>
                    <div className={`flex-15 layout-row layout-align-start-center ${ustyles.ship_row_cell}`}>
                        <p className="flex-none">{ship.status}</p>
                    </div>
                    <div className={`flex-15 layout-row layout-align-start-center ${ustyles.ship_row_cell}`}>
                        <p className="flex-none">{ship.incoterm}</p>
                    </div>
                    <div className={`flex-15 layout-row layout-align-start-center ${ustyles.ship_row_cell}`}>
                        <p className="flex-none"> Yes </p>
                    </div>
                </div>
            );
        }) :
            (<div className="flex-100 layout-row layout-align-start-center">
                <p className="flex-none" > No Shipments requested.</p>
            </div>);
        const newOpenShips = mergedOpenShipments.length > 0 ? mergedOpenShipments.map((ship) => {
            return (
                <div className={`flex-100 layout-row layout-align-start-center ${ustyles.ship_row}`}>
                    <div className={`flex-40 layout-row layout-align-start-center ${ustyles.ship_row_cell}`}>
                        <p className="flex-none">{ship.originHub} - {ship.destinationHub}</p>
                    </div>
                    <div className={`flex-15 layout-row layout-align-start-center ${ustyles.ship_row_cell}`}>
                        <p className="flex-none">{ship.imc_reference}</p>
                    </div>
                    <div className={`flex-15 layout-row layout-align-start-center ${ustyles.ship_row_cell}`}>
                        <p className="flex-none">{ship.status}</p>
                    </div>
                    <div className={`flex-15 layout-row layout-align-start-center ${ustyles.ship_row_cell}`}>
                        <p className="flex-none">{ship.incoterm}</p>
                    </div>
                    <div className={`flex-15 layout-row layout-align-start-center ${ustyles.ship_row_cell}`}>
                        <p className="flex-none"> Yes </p>
                    </div>
                </div>
            );
        }) :
            (<div className="flex-100 layout-row layout-align-start-center">
                <p className="flex-none" > No Shipments in process.</p>
            </div>);
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${ustyles.dashboard_main}`}>
                    <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${ustyles.dashboard_top}`}>

                        <div className={`flex-100 layout-row ${ustyles.left} layout-align-center-center`}>
                            <div className={`flex-100 layout-row layout-align-start-center ${ustyles.welcome}`}>
                                <h2 className="flex-none">Welcome back, {user.first_name}</h2>
                            </div>

                            <div className={`flex-none layout-row layout-align-center-center ${ustyles.carousel}`}>
                                <Carousel theme={this.props.theme} slides={actRoutesData} noSlides={1} fade/>
                            </div>
                            <div className={`flex-none layout-row layout-align-center-center ${ustyles.dash_btn}`}>
                                <RoundButton theme={theme} handleNext={this.startBooking} active size="large" text="Make a Booking" iconClass="fa-archive"/>
                            </div>
                            {/* </div>*/}
                            <div className={`flex-50 layout-row ${ustyles.right} layout-wrap layout-align-space-between-space-between`}>
                                <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box}`}>
                                    <h1 className="flex-none">{mergedOpenShipments.length + mergedFinishedShipments.length + mergedRequestedShipments.length}</h1>
                                    <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box_title}`}>
                                        <h3 className="flex-none " >Total Shipments</h3>
                                    </div>
                                </div>
                                <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box}`}>
                                    <h1 className="flex-none">{mergedRequestedShipments.length}</h1>
                                    <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box_title}`}>
                                        <h3 className="flex-none " >Requested Shipments</h3>
                                    </div>
                                </div>
                                <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box}`}>
                                    <h1 className="flex-none">{mergedOpenShipments.length}</h1>
                                    <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box_title}`}>
                                        <h3 className="flex-none " >Shipments in Progress</h3>
                                    </div>
                                </div>
                                <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box}`}>
                                    <h1 className="flex-none">{ mergedFinishedShipments.length }</h1>
                                    <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box_title}`}>
                                        <h3 className="flex-none " >Completed Shipments</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${ustyles.dashboard_shipments}`}>
                        <div className="flex-100 layout-row layout-align-start-center">
                            <h3 className="flex-none clip" style={textStyle}>Shipments</h3>
                        </div>
                        <div className="flex-100 layout-row layout-align-start-center">
                            <div className="flex-40 layout-row layout-align-start-center">
                                <h3 className="flex-none">Requested Shipments </h3>
                            </div>
                            <div className="flex-15 layout-row layout-align-start-center">
                                <h3 className="flex-none"> Reference </h3>
                            </div>
                            <div className="flex-15 layout-row layout-align-start-center">
                                <h3 className="flex-none">Status </h3>
                            </div>
                            <div className="flex-15 layout-row layout-align-start-center">
                                <h3 className="flex-none">Incoterm </h3>
                            </div>
                            <div className="flex-15 layout-row layout-align-start-center">
                                <h3 className="flex-none">Requires Action </h3>
                            </div>
                        </div>
                        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
                            {newReqShips}
                        </div>
                        <div className="flex-100 layout-row layout-align-start-center">
                            <div className="flex-40 layout-row layout-align-start-center">
                                <h3 className="flex-none">In Process </h3>
                            </div>
                            <div className="flex-15 layout-row layout-align-start-center">
                                <h3 className="flex-none"> Reference </h3>
                            </div>
                            <div className="flex-15 layout-row layout-align-start-center">
                                <h3 className="flex-none">Status </h3>
                            </div>
                            <div className="flex-15 layout-row layout-align-start-center">
                                <h3 className="flex-none">Incoterm </h3>
                            </div>
                            <div className="flex-15 layout-row layout-align-start-center">
                                <h3 className="flex-none">Requires Action </h3>
                            </div>
                        </div>
                        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
                            {newOpenShips}
                        </div>
                    </div>
                </div>
                <AdminSearchableClients theme={theme} clients={contacts} title="Contacts" handleClick={this.viewClient} seeAll={() => userDispatch.goTo('/account/contacts')}/>

                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > My Shipment Addresses </p>
                    </div>
                    <UserLocations setNav={this.doNothing} userDispatch={userDispatch} locations={locations} makePrimary={this.makePrimary} theme={theme} user={user}/>
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

import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin/Admin.scss';
import ustyles from './UserAccount.scss';
import { UserLocations } from './';
import { RoundButton } from '../RoundButton/RoundButton';
// import {v4} from 'node-uuid';
import {Carousel} from '../Carousel/Carousel';
import { activeRoutesData } from '../../constants';
import { AdminSearchableClients, AdminSearchableShipments } from '../Admin/AdminSearchables';
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
        shipment.originHub = hubsObj[hubKeys[0]] ? hubsObj[hubKeys[0]].name : '';
        shipment.destinationHub = hubsObj[hubKeys[1]] ? hubsObj[hubKeys[1]].name : '';
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

        const openShipments = mergedOpenShipments.length > 0 ? <AdminSearchableShipments hubs={hubs} shipments={mergedRequestedShipments} title="Open Shipments" theme={theme} handleClick={this.viewShipment} userView handleShipmentAction={this.handleShipmentAction} seeAll={() => userDispatch.getShipments(true)}/> : '';
        const reqShipments = mergedRequestedShipments.length > 0 ? <AdminSearchableShipments hubs={hubs} shipments={mergedRequestedShipments} title="Requested Shipments" theme={theme} handleClick={this.viewShipment} userView handleShipmentAction={this.handleShipmentAction} seeAll={() => userDispatch.getShipments(true)}/> : '';
        const finishedShipments = mergedFinishedShipments.length > 0 ? <AdminSearchableShipments hubs={hubs} shipments={mergedRequestedShipments} title="Finished Shipments" theme={theme} handleClick={this.viewShipment} userView handleShipmentAction={this.handleShipmentAction} seeAll={() => userDispatch.getShipments(true)}/> : '';

        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <h1 className={` ${styles.sec_title_text} flex-none`} style={textStyle} >Dashboard</h1>
                </div>

                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className="flex-100 flex-gt-sm-50 layout-row layout-align-center-center button_padding">
                        <RoundButton theme={theme} handleNext={this.startBooking} active size="large" text="Make a Booking" iconClass="fa-archive"/>
                    </div>
                    <div className="flex-100 flex-gt-sm-50 layout-row layout-align-center-center button_padding">
                        <Carousel theme={this.props.theme} slides={actRoutesData} noSlides={1}/>
                    </div>
                </div>
                <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${ustyles.section}`}>
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Shipments</p>
                    </div>
                    { openShipments }
                    { reqShipments }
                    { finishedShipments }
                    { mergedOpenShipments.length === 0 && mergedRequestedShipments.length === 0 && mergedFinishedShipments.length === 0 ?
                        <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
                            <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                                <p className={` ${styles.sec_subheader_text} flex-none`}  > No Shipments yet</p>
                            </div>
                            <p className="flex-none"  > Click 'Make a Booking' to begin!</p>
                        </div> :
                        ''
                    }
                </div>
                <AdminSearchableClients theme={theme} clients={contacts} title="Contacts" handleClick={this.viewClient} seeAll={() => userDispatch.goTo('/account/contacts')}/>

                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Saved Locations </p>
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

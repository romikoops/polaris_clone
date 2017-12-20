import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin/Admin.scss';
import { UserShipmentRow, UserLocations } from './';
import { AdminClientTile } from '../Admin';
import { RoundButton } from '../RoundButton/RoundButton';
import {v4} from 'node-uuid';
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
        const { userDispatch, user } = this.props;
        userDispatch.getShipment(user.id, shipment.id, true);
        this.setState({selectedShipment: true});
    }
    startBooking() {
        this.props.userDispatch.goTo('/booking');
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
        const { theme, hubs, dashboard, user } = this.props;
        // debugger;
        if (!user || !dashboard) {
            return <h1>NO DATA</h1>;
        }
         const { shipments, pricings, contacts, locations} = dashboard;
        console.log(pricings);
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
        const contactArr  = contacts.map(cont => {
            return (
                <AdminClientTile client={cont} theme={theme} />
            );
        });
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <h1 className={` ${styles.sec_title_text} flex-none`} style={textStyle} >Dashboard</h1>
                </div>

                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className="flex-100 flex-gt-sm-50 layout-row layout-align-center-center button_padding">
                        <RoundButton theme={theme} handleNext={this.startBooking} active size="large" text="Make a Booking" iconClass="fa-archive"/>
                    </div>
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

                 <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Contacts </p>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
                        { contactArr }
                    </div>
                </div>

                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                    <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}>
                        <p className={` ${styles.sec_header_text} flex-none`}  > Saved Locations </p>
                    </div>
                    <UserLocations setNav={this.doNothing} locations={locations} makePrimary={this.makePrimary} theme={theme} user={user.data}/>
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

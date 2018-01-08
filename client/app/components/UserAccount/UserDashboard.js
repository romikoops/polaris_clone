import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin/Admin.scss';
import ustyles from './UserAccount.scss';
import { UserShipmentRow, UserLocations } from './';
import { RoundButton } from '../RoundButton/RoundButton';
import {v4} from 'node-uuid';
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
                    { openShipments.length !== 0 ?
                        <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
                            <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                                <p className={` ${styles.sec_subheader_text} flex-none`}  > Open</p>
                            </div>
                            { openShipments }
                        </div> :
                        ''
                    }
                    { reqShipments.length !== 0 ?
                        <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
                            <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                                <p className={` ${styles.sec_subheader_text} flex-none`}  > Requested</p>
                            </div>
                            { reqShipments }
                        </div> :
                        ''
                    }
                    { finishedShipments.length !== 0 ?
                        <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
                            <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                                <p className={` ${styles.sec_subheader_text} flex-none`}  > Finished</p>
                            </div>
                            { finishedShipments }
                        </div> :
                        ''
                    }
                    { openShipments.length === 0 && reqShipments.length === 0 && finishedShipments.length === 0 ?
                        <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
                            <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
                                <p className={` ${styles.sec_subheader_text} flex-none`}  > No Shipments yet</p>
                            </div>
                            <p className="flex-none"  > Click 'Make a Booking' to begin!</p>
                        </div> :
                        ''
                    }
                </div>
                <AdminSearchableClients theme={theme} clients={contacts} title="Contacts" handleClick={this.viewClient} />

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

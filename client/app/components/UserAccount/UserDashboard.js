import React, { Component } from 'react';
import PropTypes from 'prop-types';
import ustyles from './UserAccount.scss';
import defaults from '../../styles/default_classes.scss';
import { UserLocations } from './';
import { RoundButton } from '../RoundButton/RoundButton';
// import {v4} from 'node-uuid';
import {Carousel} from '../Carousel/Carousel';
import { activeRoutesData } from '../../constants';
import { AdminSearchableClients } from '../Admin/AdminSearchables';
import { MainTextHeading } from '../TextHeadings/MainTextHeading';
import { UserMergedShipment} from './UserMergedShipment';
import { UserMergedShipHeaders} from './UserMergedShipHeaders';
export class UserDashboard extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
        this.viewShipment = this.viewShipment.bind(this);
        this.makePrimary = this.makePrimary.bind(this);
        this.startBooking = this.startBooking.bind(this);
        this.limitArray = this.limitArray.bind(this);
        this.seeAll = this.seeAll.bind(this);
    }
    componentDidMount() {
        this.props.setNav('dashboard');
        window.scrollTo(0, 0);
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
        console.log('doing nothing');
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
    makePrimary(locationId) {
        const { userDispatch, user } = this.props;
        userDispatch.makePrimary(user.id, locationId);
    }
    limitArray(shipments, limit) {
        return limit ?
            shipments.slice(0, limit)
            : shipments;
    }
    // handleReqClick() {
    //     this.seeAll('account/shipments');
    // }
    // handleOpClick() {
    //    this.seeAll('account/shipments');
    // }
    seeAll() {
        const { userDispatch, seeAll } = this.props;
        if(seeAll) {
            this.seeAll();
        } else {
            userDispatch.goTo('/account/shipments');
        }
    }
    render() {
        const { theme, hubs, dashboard, user, userDispatch, seeAll} = this.props;
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
        const newReqShips = mergedRequestedShipments.length > 0 ? this.limitArray(mergedRequestedShipments, 3).map((ship) => {
            return (
                <UserMergedShipment ship={ship} viewShipment={this.viewShipment}/>
            );
        }) :
            (<div className="flex-100 layout-row layout-align-start-center">
                <p className="flex-none" > No Shipments requested.</p>
            </div>);
        const newOpenShips = mergedOpenShipments.length > 0 ? this.limitArray(mergedOpenShipments, 3).map((ship) => {
            return (
                <UserMergedShipment ship={ship} viewShipment={this.viewShipment}/>
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
                                <h2 className="flex-none">
                                Welcome back, {user.first_name}
                                </h2>
                            </div>
                            <div className={`flex-none layout-row layout-align-center-center ${ustyles.carousel}`}>
                                <Carousel theme={this.props.theme} slides={activeRoutesData} noSlides={1} fade/>
                            </div>
                            <div className={`flex-none layout-row layout-align-center-center ${ustyles.dash_btn}`}>
                                <RoundButton theme={theme} handleNext={this.startBooking} active size="large" text="Make a Booking" iconClass="fa-archive"/>
                            </div>
                            <div className={`flex-50 layout-row ${ustyles.right} layout-wrap layout-align-space-between-space-between`}>
                                <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box}`}>
                                    <h1 className="flex-none">
                                        {mergedOpenShipments.length + mergedFinishedShipments.length + mergedRequestedShipments.length}
                                    </h1>
                                    <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box_title}`}>
                                        <h3 className="flex-none">
                                            Total Shipments
                                        </h3>
                                    </div>
                                </div>
                                <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box}`}>
                                    <h1 className="flex-none">
                                        {mergedRequestedShipments.length}
                                    </h1>
                                    <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box_title}`}>
                                        <h3 className="flex-none">
                                            Requested Shipments
                                        </h3>
                                    </div>
                                </div>
                                <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box}`}>
                                    <h1 className="flex-none">
                                        {mergedOpenShipments.length}
                                    </h1>
                                    <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box_title}`}>
                                        <h3 className="flex-none">
                                            Shipments in Progress
                                        </h3>
                                    </div>
                                </div>
                                <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box}`}>
                                    <h1 className="flex-none">
                                        { mergedFinishedShipments.length }
                                    </h1>
                                    <div className={`flex-none layout-row layout-align-center-center ${ustyles.stat_box_title}`}>
                                        <h3 className="flex-none">
                                            Completed Shipments
                                        </h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className={'layout-row flex-100 layout-wrap layout-align-center-center ' + defaults.border_divider}>
                        <div className="flex-100 layout-row layout-wrap layout-align-start-start">

                            <MainTextHeading className="flex-non clip" theme={theme} text="Shipments" />
                            <UserMergedShipHeaders title="Requested Shipments" total={mergedRequestedShipments.length}/>

                            <div className="flex-100 layout-row layout-align-start-center layout-wrap">
                                {newReqShips}
                                { seeAll !== false ? (<div className="flex-100 layout-row layout-align-end-center">
                                    <div className="flex-none layout-row layout-align-center-center" value="1" onClick={this.seeAll}>
                                        <p className="flex-none">See all</p>
                                    </div>
                                </div>) : ''}
                            </div>
                            <UserMergedShipHeaders title="In Process" total={mergedOpenShipments.length}/>
                            <div className="flex-100 layout-row layout-align-start-center layout-wrap">
                                {newOpenShips}
                                { seeAll !== false ? (<div className="flex-100 layout-row layout-align-end-center">
                                    <div className="flex-none layout-row layout-align-center-center" value="2" onClick={this.seeAll}>
                                        <p className="flex-none">See all</p>
                                    </div>
                                </div>) : ''}
                            </div>
                        </div>
                    </div>

                    <div className={'layout-row flex-100 layout-wrap layout-align-center-center ' + defaults.border_divider}>
                        <AdminSearchableClients theme={theme} clients={contacts} title="Most used Contacts" handleClick={this.viewClient} seeAll={() => userDispatch.goTo('/account/contacts')}/>
                    </div>
                    <div className={'layout-row flex-100 layout-wrap layout-align-center-center ' + defaults.border_divider}>
                        <MainTextHeading theme={theme} text="My Shipment Addresses" />
                        <UserLocations setNav={this.doNothing} userDispatch={userDispatch} locations={locations} makePrimary={this.makePrimary} theme={theme} user={user}/>
                    </div>
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

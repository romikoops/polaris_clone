import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { RouteFilterBox } from '../RouteFilterBox/RouteFilterBox';
import { BestRoutesBox } from '../BestRoutesBox/BestRoutesBox';
import { RouteResult } from '../RouteResult/RouteResult';
import { moment } from '../../constants';
import styles from './ChooseRoute.scss';
import { FlashMessages } from '../FlashMessages/FlashMessages';
import defs from '../../styles/default_classes.scss';
import { RoundButton } from '../RoundButton/RoundButton';
import {v4} from 'node-uuid';
import { BookingTextHeading } from '../TextHeadings/BookingTextHeading';
export class ChooseRoute extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedMoT: 'ocean',
            durationFilter: 40,
            pickupDate: this.props.selectedDay,
            limits: {
                focus: true,
                alt: true
            },
            fastestTime: '',
            longestTime: ''
        };
        this.chooseResult = this.chooseResult.bind(this);
        this.setDuration = this.setDuration.bind(this);
        this.setMoT = this.setMoT.bind(this);
        this.setDepDate = this.setDepDate.bind(this);
        this.toggleLimits = this.toggleLimits.bind(this);
    }
    componentDidMount() {
        const { prevRequest, setStage } = this.props;
        if (prevRequest && prevRequest.shipment) {
            // this.loadPrevReq(prevRequest.shipment);
        }
        window.scrollTo(0, 0);
        setStage(3);
        console.log('######### MOUNTED ###########');
    }
    setDuration(val) {
        this.setState({ durationFilter: val });
    }
    setMoT(val) {
        this.setState({ selectedMoT: val });
    }
    setDepDate(val) {
        this.setState({ pickupDate: val });
    }
    toggleLimits(target) {
        this.setState({limits: {...this.state.limits, [target]: !this.state.limits[target]}});
    }

    chooseResult(obj) {
        this.props.chooseRoute(obj);
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
        const { shipmentData, messages, user, shipmentDispatch, theme } = this.props;

        const { limits } = this.state;

        let smallestDiff = 100;
        if (!shipmentData) {
            return '';
        }
        const {
            shipment,
            originHubs,
            destinationHubs,
            schedules,
            cargoUnits
        } = shipmentData;
        const depDay = shipment ? shipment.planned_pickup_date : new Date();
        schedules.sort(this.dynamicSort('etd'));
        const idArrays = {
            closest: '',
            focus: [],
            alternative: []
        };
        schedules.forEach(sched => {
            const newTime = moment(sched.eta).diff(depDay, 'days');
            !this.state.fastestTime || ( this.state.fastestTime > newTime ) ? this.setState({fastestTime: newTime})
                : '';
            !this.state.longestTime || ( this.state.longestTime < newTime ) ? this.setState({longestTime: newTime})
                : '';
        });
        const closestRoute = [];
        const focusRoutes = [];
        const altRoutes = [];
        schedules.forEach(sched => {
            const transportTime = moment(sched.eta).diff(depDay, 'days');
            if (
                Math.abs(moment(sched.etd).diff(sched.eta, 'days')) <=
                        this.state.durationFilter
            ) {
                if (
                    Math.abs(moment(sched.etd).diff(depDay, 'days')) <
                            smallestDiff && sched.mode_of_transport === this.state.selectedMoT
                ) {
                    smallestDiff = Math.abs(
                        moment(sched.etd).diff(depDay, 'days')
                    );
                    idArrays.closest = sched.id;
                    closestRoute.push(
                        <RouteResult
                            key={v4()}
                            selectResult={this.chooseResult}
                            theme={this.props.theme}
                            originHubs={originHubs}
                            destinationHubs={destinationHubs}
                            fees={shipment.schedules_charges}
                            schedule={sched}
                            user={user}
                            loadType={shipment.load_type}
                            pickupDate={shipment.planned_pickup_date}
                            transportTime={transportTime}
                        />
                    );
                }
                if (
                    sched.mode_of_transport === this.state.selectedMoT &&
                            !idArrays.focus.includes(sched.id) && sched.id !== idArrays.closest
                ) {
                    idArrays.focus.push(sched.id);
                    focusRoutes.push(
                        <RouteResult
                            key={v4()}
                            selectResult={this.chooseResult}
                            theme={this.props.theme}
                            originHubs={originHubs}
                            destinationHubs={destinationHubs}
                            fees={shipment.schedules_charges}
                            schedule={sched}
                            user={user}
                            loadType={shipment.load_type}
                            pickupDate={shipment.planned_pickup_date}
                            transportTime={transportTime}
                        />
                    );
                } else if (
                    sched.mode_of_transport !== this.state.selectedMoT &&
                            !idArrays.alternative.includes(sched.id)
                ) {
                    idArrays.alternative.push(sched.id);
                    altRoutes.push(
                        <RouteResult
                            key={v4()}
                            selectResult={this.chooseResult}
                            theme={this.props.theme}
                            originHubs={originHubs}
                            destinationHubs={destinationHubs}
                            fees={shipment.schedules_charges}
                            schedule={sched}
                            user={user}
                            loadType={shipment.load_type}
                            pickupDate={shipment.planned_pickup_date}
                            transportTime={transportTime}
                        />
                    );
                }
            }
        });


        const filterBox = (
            <RouteFilterBox theme={theme}
                pickup={shipment.has_pre_carriage}
                setDurationFilter={this.setDuration}
                durationFilter={this.state.durationFilter}
                setMoT={this.setMoT} moT={this.state.selectedMoT}
                departureDate={depDay}
                setDepartureDate={this.setDepDate}
                fastestTime={this.state.fastestTime ? this.state.fastestTime : 1 }
                longestTime={this.state.longestTime ? this.state.longestTime : 90 }
            />
        );

        const limitedFocus = limits.focus ? focusRoutes.slice(0, 3) : focusRoutes;
        const limitedAlts = limits.alt ? altRoutes.slice(0, 3) : altRoutes;
        const cargoText = cargoUnits.length > 1 ? 'Cargo Items' : 'Cargo Item';
        const containerText = cargoUnits.length > 1 ? 'Containers' : 'Container';
        const flash = messages && messages.length > 0 ? <FlashMessages messages={messages} /> : '';
        const shipmentHeadline = 'Shipping ' + cargoUnits.length + ' x ' + ( shipment.load_type === 'cargo_item' ? cargoText : containerText + ' to ' + destinationHubs[0].name.split(' ')[0] );
        return (
            <div className="flex-100 layout-row layout-align-center-start layout-wrap" style={{marginTop: '62px', marginBottom: '166px'}}>
                {flash}
                <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>

                    <div className="flex-20 layout-row layout-wrap">
                        {filterBox}
                    </div>
                    <div className="flex-75 offset-5 layout-row layout-wrap">
                        <div className="flex-100 layout-row layout-align-start-center">
                            <p className={`flex-none ${styles.one_line_summ}`}>
                                <BookingTextHeading theme={theme} size={2} text={shipmentHeadline} />
                            </p>
                        </div>
                        <div className="flex-100 layout-row">
                            <BestRoutesBox moT={this.state.selectedMoT} user={user} chooseResult={this.chooseResult} theme={this.props.theme} shipmentData={this.props.shipmentData}/>
                        </div>
                        <div className="flex-100 layout-row layout-wrap">
                            <div className={`flex-100 layout-row layout-align-start ${styles.route_header}`}>
                                <p className="flex-none">
                                    <BookingTextHeading theme={theme} size={3} text="This is the closest departure to the specified pickup date" />
                                </p>
                            </div>
                            {closestRoute}
                        </div>
                        <div className="flex-100 layout-row layout-wrap">
                            <div className={`flex-100 layout-row layout-align-start ${styles.route_header}`}>
                                <p className="flex-none">
                                    <BookingTextHeading theme={theme} size={3} text="Alternative departures" />
                                </p>

                            </div>
                            {limitedFocus}
                            { limitedFocus.length !== focusRoutes.length ?
                                <div className="flex-100 layout-row layout-align-center-center">
                                    <div className="flex-33 layout-row layout-align-space-around-center" onClick={() => this.toggleLimits('focus')}>
                                        {limits.focus ? <i className="flex-none fa fa-angle-double-down"></i> : <i className="flex-none fa fa-angle-double-up"></i> }
                                        <div className="flex-5"></div>
                                        {limits.focus ? <p className="flex-none">More</p> : <p className="flex-none">Less</p> }
                                        <div className="flex-5"></div>
                                        {limits.focus ? <i className="flex-none fa fa-angle-double-down"></i> : <i className="flex-none fa fa-angle-double-up"></i> }
                                    </div>
                1                </div>
                                : '' }
                        </div>
                        <div className="flex-100 layout-row layout-wrap">
                            <div className={`flex-100 layout-row layout-align-start ${styles.route_header}`}>
                                <p className="flex-none">
                                    <BookingTextHeading theme={theme} size={3} text="Alternative modes of transport" />
                                </p>
                            </div>
                            {limitedAlts}
                            { limitedAlts.length !== altRoutes.length ?
                                <div className="flex-100 layout-row layout-align-center-center">
                                    <div className="flex-33 layout-row layout-align-space-around-center" onClick={() => this.toggleLimits('alt')}>
                                        {limits.alt ? <i className="flex-none fa fa-angle-double-down"></i> : <i className="flex-none fa fa-angle-double-up"></i> }
                                        <div className="flex-5"></div>
                                        {limits.alt ? <p className="flex-none">More</p> : <p className="flex-none">Less</p> }
                                        <div className="flex-5"></div>
                                        {limits.alt ? <i className="flex-none fa fa-angle-double-down"></i> : <i className="flex-none fa fa-angle-double-up"></i> }
                                    </div>
                                </div> : ''
                            }
                        </div>
                    </div>
                </div>

                <div className={`${styles.back_to_dash_sec} flex-100 layout-row layout-wrap layout-align-center`}>
                    <div className="content_width flex-none layout-row layout-align-start-center">
                        <RoundButton theme={theme} text="Back to dashboard" back iconClass="fa-angle0-left" handleNext={() => shipmentDispatch.goTo('/account')}/>
                    </div>
                </div>
            </div>
        );
    }
}
ChooseRoute.propTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    chooseRoute: PropTypes.func,
    selectedDay: PropTypes.string,
    messages: PropTypes.array
    // shipment: PropTypes.object,
    // schedules: PropTypes.array
};

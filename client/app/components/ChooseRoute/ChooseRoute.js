import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { RouteFilterBox } from '../RouteFilterBox/RouteFilterBox';
import { BestRoutesBox } from '../BestRoutesBox/BestRoutesBox';
import { RouteResult } from '../RouteResult/RouteResult';
import { moment } from '../../constants';
import styles from './ChooseRoute.scss';
import { FlashMessages } from '../FlashMessages/FlashMessages';
import defs from '../../styles/default_classes.scss';
import {v4} from 'node-uuid';
export class ChooseRoute extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selectedMoT: 'ocean',
            durationFilter: 40,
            pickupDate: this.props.selectedDay
        };
        this.chooseResult = this.chooseResult.bind(this);
        this.setDuration = this.setDuration.bind(this);
        this.setMoT = this.setMoT.bind(this);
        this.setDepDate = this.setDepDate.bind(this);
    }
    componentDidMount() {
        const { setStage } = this.props;
        setStage(2);
        window.scrollTo(0, 0);
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

    chooseResult(obj) {
        this.props.chooseRoute(obj);
    }
    render() {
        const { shipmentData, messages } = this.props;
        const focusRoutes = [];
        const altRoutes = [];
        let closestRoute;
        let smallestDiff = 100;
        if (shipmentData) {
            const {
                shipment,
                originHubs,
                destinationHubs,
                schedules
            } = shipmentData;
            const depDay = shipment ? shipment.planned_pickup_date : new Date();
            if (schedules) {
                schedules.forEach(sched => {
                    if (
                        Math.abs(moment(sched.etd).diff(sched.eta, 'days')) <=
                        this.state.durationFilter
                    ) {
                        if (
                            Math.abs(moment(sched.etd).diff(depDay, 'days')) <
                            smallestDiff
                        ) {
                            smallestDiff = Math.abs(
                                moment(sched.etd).diff(depDay, 'days')
                            );
                            closestRoute = (
                                <RouteResult
                                    key={v4()}
                                    selectResult={this.chooseResult}
                                    theme={this.props.theme}
                                    originHubs={originHubs}
                                    destinationHubs={destinationHubs}
                                    fees={shipment.generated_fees}
                                    schedule={sched}
                                    pickupDate={shipment.planned_pickup_date}
                                />
                            );
                        }
                        if (
                            sched.mode_of_transport === this.state.selectedMoT
                        ) {
                            focusRoutes.push(
                                <RouteResult
                                    key={v4()}
                                    selectResult={this.chooseResult}
                                    theme={this.props.theme}
                                    originHubs={originHubs}
                                    destinationHubs={destinationHubs}
                                    fees={shipment.generated_fees}
                                    schedule={sched}
                                    pickupDate={shipment.planned_pickup_date}
                                />
                            );
                        } else {
                            altRoutes.push(
                                <RouteResult
                                    key={v4()}
                                    selectResult={this.chooseResult}
                                    theme={this.props.theme}
                                    originHubs={originHubs}
                                    destinationHubs={destinationHubs}
                                    fees={shipment.generated_fees}
                                    schedule={sched}
                                    pickupDate={shipment.planned_pickup_date}
                                />
                            );
                        }
                    }
                });
            }
        }
        const flash = messages && messages.length > 0 ? <FlashMessages messages={messages} /> : '';
        return (

            <div className="flex-100 layout-row layout-align-center-start" style={{marginTop: '62px', marginBottom: '166px'}}>
                {flash}
                <div className={`flex-none ${defs.content_width} layout-row layout-wrap`}>
                    <div className="flex-20 layout-row layout-wrap">
                        <RouteFilterBox theme={this.props.theme} setDurationFilter={this.setDuration} durationFilter={this.state.durationFilter} setMoT={this.setMoT} moT={this.state.selectedMoT} setDepartureDate={this.setDepDate}/>
                    </div>
                    <div className="flex-75 offset-5 layout-row layout-wrap">
                        <div className="flex-100 layout-row">
                            <BestRoutesBox theme={this.props.theme} shipmentData={this.props.shipmentData}/>
                        </div>
                        <div className="flex-100 layout-row layout-wrap">
                            <div className={`flex-100 layout-row layout-align-start ${styles.route_header}`}>
                                <p className="flex-none">This is the closest departure to the specified pickup date</p>
                            </div>
                            {closestRoute}
                        </div>
                        <div className="flex-100 layout-row layout-wrap">
                            <div className={`flex-100 layout-row layout-align-start ${styles.route_header}`}>
                                <p className="flex-none">Alternative departures</p>

                            </div>
                            {focusRoutes}
                        </div>
                        <div className="flex-100 layout-row layout-wrap">
                            <div
                                className={`flex-100 layout-row layout-align-start ${
                                    styles.route_header
                                }`}
                            >
                                <p className="flex-none">
                                    Other modes of transport
                                </p>
                            </div>
                            {altRoutes}
                        </div>
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

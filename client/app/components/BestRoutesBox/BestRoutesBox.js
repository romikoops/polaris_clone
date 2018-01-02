import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { moment } from '../../constants';
import { Price } from '../Price/Price';
import styles from './BestRoutesBox.scss';
export class BestRoutesBox extends Component {
    constructor(props) {
        super(props);
    }
    calcFastest(schedules, fees) {
        let fastestTime;
        // let fastestSchedule;
        let fastestFare;
        schedules.forEach(sched => {
            if (sched.mode_of_transport === this.props.moT) {
                const travelTime = moment(sched.eta).diff(sched.etd);
                const schedKey = sched.hub_route_key;
                if (!fastestTime || travelTime < fastestTime) {
                    fastestTime = travelTime;
                    // fastestSchedule = sched;
                    fastestFare = fees[schedKey].total;
                }
            }
        });
        return (
            <div
                className={`flex-none layout-row layout-wrap ${
                    styles.best_card
                }`}
            >
                <div className="flex-100 layout-row">
                    <h4 className="flex-none">Fastest route</h4>
                </div>
                <div className="flex-100 layout-row">
                    <Price value={fastestFare} scale="0.75" />
                </div>
            </div>
        );
    }

    calcCheapest(schedules, fees) {
        let cheapestFare;
        // let cheapestSchedule;
        schedules.forEach(sched => {
            if (sched.mode_of_transport === this.props.moT) {
                const schedKey = sched.hub_route_key;
                if (!fees[schedKey]) {
                    debugger;
                }
                const fare = fees[schedKey].total;
                if (!cheapestFare || fare < cheapestFare) {
                    cheapestFare = fare;
                    // cheapestSchedule = sched;
                }
            }
        });
        return (
            <div
                className={`flex-none layout-row layout-wrap ${
                    styles.best_card
                }`}
            >
                <div className="flex-100 layout-row">
                    <h4 className="flex-none">Cheapest Route</h4>
                </div>
                <div className="flex-100 layout-row">
                    <Price value={cheapestFare} scale="0.75" />
                </div>
            </div>
        );
    }
    sortBestOption(schedules, fees, depDate, style) {
        const fareArray = schedules.sort((a, b) => {
            const aKey = a.hub_route_key;
            const bKey = b.hub_route_key;
            return fees[aKey] - fees[bKey];
        });
        const timeArray = schedules.sort((a, b) => {
            return moment(a.eta).diff(b.etd);
        });
        const depArray = schedules.sort((a, b) => {
            return moment(depDate).diff(a.etd) - moment(depDate).diff(b.etd);
        });
        let lowScore = 100;
        let bestFare;
        // let bestOption;
        schedules.forEach(sched => {
            if (sched.mode_of_transport === this.props.moT) {
                const timeScore = timeArray.indexOf(sched);
                const fareScore = fareArray.indexOf(sched);
                const depScore = depArray.indexOf(sched);
                const schedKey = sched.hub_route_key;
                const fare = fees[schedKey] ? fees[schedKey].total : 0;
                const totalScore = timeScore + fareScore + depScore;
                if (totalScore < lowScore) {
                    lowScore = totalScore;
                    // bestOption = sched;
                    bestFare = fare;
                }
            }
        });
        return (
            <div
                className={`flex-none layout-row layout-wrap ${
                    styles.best_card
                }`}
                style={style}
            >
                <div className="flex-100 layout-row">
                    <h4 className="flex-none">Best Deal</h4>
                </div>
                <div className="flex-100 layout-row">
                    <Price value={bestFare} scale="0.75"/>
                </div>
            </div>
        );
    }

    render() {
        const { theme, shipmentData } = this.props;
        const schedules = shipmentData.schedules;
        const fees = shipmentData.shipment
            ? shipmentData.shipment.generated_fees
            : {};
        const depDate = shipmentData.shipment
            ? shipmentData.shipment.planned_pickup_date
            : '';
        const activeBtnStyle = {
            background:
                theme && theme.colors
                    ? `-webkit-linear-gradient(left, ${
                        theme.colors.brightPrimary
                    }, ${theme.colors.brightSecondary})`
                    : 'floralwhite',
            color: theme && theme.colors ? 'white' : 'black'
        };
        return (
            <div className="flex-100 layout-row layout-align-space-between-center">
                {shipmentData.shipment
                    ? this.sortBestOption(
                        schedules,
                        fees,
                        depDate,
                        activeBtnStyle
                    )
                    : ''}
                {shipmentData.shipment
                    ? this.calcCheapest(schedules, fees)
                    : ''}
                {shipmentData.shipment ? this.calcFastest(schedules, fees) : ''}
                {/* <div className="flex-30 layout-row layout-wrap" style={activeBtnStyle}>
            <div className="flex-100 layout-row">
              <h4 className="flex-none">Best Deal</h4>
            </div>
            <div className="flex-100 layout-row">
              <p className="flex-none">{}</p>
            </div>
          </div>
          <div className="flex-30 layout-row layout-wrap">
            <div className="flex-100 layout-row">
              <h4 className="flex-none">Cheapest Route</h4>
            </div>
            <div className="flex-100 layout-row">
              <p className="flex-none">500 EUR</p>
            </div>
          </div>
          <div className="flex-30 layout-row layout-wrap">
            <div className="flex-100 layout-row">
              <h4 className="flex-none">Fastest route</h4>
            </div>
            <div className="flex-100 layout-row">
              <p className="flex-none">500 EUR</p>
            </div>
          </div>*/}
            </div>
        );
    }
}
BestRoutesBox.propTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    moT: PropTypes.string
};

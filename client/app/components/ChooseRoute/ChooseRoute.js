import React, {Component} from 'react';
import PropTypes from 'prop-types';
import { RouteFilterBox } from '../RouteFilterBox/RouteFilterBox';
import { BestRoutesBox } from '../BestRoutesBox/BestRoutesBox';
import { RouteResult } from '../RouteResult/RouteResult';
export class ChooseRoute extends Component {
    constructor(props) {
        super(props);
        this.chooseResult = this.chooseResult.bind(this);
    }

    chooseResult(obj) {
        this.props.chooseRoute(obj);
    }
    render() {
        const routes = [];
        if (this.props.shipmentData) {
            const { shipment, originHubs, destinationHubs, schedules } = this.props.shipmentData;
            if (schedules) {
                schedules.forEach(sched => {
                    routes.push(<RouteResult key={sched.id} selectResult={this.chooseResult} theme={this.props.theme} originHubs={originHubs} destinationHubs={destinationHubs} fees={shipment.generated_fees} schedule={sched} pickupDate={shipment.planned_pickup_date}/>);
                });
            }
        }
        return (
        <div className="flex-100 layout-row layout-align-center-start">
          <div className="flex-75 layout-row layout-wrap">
           <div className="flex-20 layout-row layout-wrap">
              <RouteFilterBox theme={this.props.theme}/>
            </div>
            <div className="flex-80 layout-row layout-wrap">
              <div className="flex-100 layout-row">
                <BestRoutesBox theme={this.props.theme} shipmentData={this.props.shipmentData}/>
              </div>
              <div className="flex-100 layout-row layout-wrap">
                {routes}
              </div>
            </div>
          </div>
        </div>
        );
    }
}
ChooseRoute.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    chooseRoute: PropTypes.func
    // shipment: PropTypes.object,
    // schedules: PropTypes.array
};


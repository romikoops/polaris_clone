import React, {Component} from 'react';
import PropTypes from 'prop-types';
import { RouteFilterBox } from '../RouteFilterBox/RouteFilterBox';
import { BestRoutesBox } from '../BestRoutesBox/BestRoutesBox';
import { RouteResult } from '../RouteResult/RouteResult';
export class ChooseRoute extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        const routes = [];
        const { shipment, originHubs, destinationHubs } = this.props.shipmentData;
        if (this.props.shipmentData.schedules) {
           this.props.shipmentData.schedules.forEach(sched => {
              routes.push(<RouteResult theme={this.props.theme} originHubs={originHubs} destinationHubs={destinationHubs} fees={shipment.generated_fees} schedule={sched} pickupDate={shipment.planned_pickup_date}/>);
          });
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
    shipmentData: PropTypes.object
    // shipment: PropTypes.object,
    // schedules: PropTypes.array
};


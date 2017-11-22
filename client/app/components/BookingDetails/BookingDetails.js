import React, {Component} from 'react';
import PropTypes from 'prop-types';
import { moment } from '../../constants';
import './BookingDetails.scss';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
export class BookingDetails extends Component {
    constructor(props) {
        super(props);
    }
    render() {
      const { shipment, hubs } = this.props.shipmentData;
      return (
        <div className="flex-100 layout-row layout-wrap layout-align-center-start">
          <RouteHubBox hubs={hubs} route={shipment.schedule_set[0]} theme={theme}}/>
        </div>
      )
    }
}
BookingDetails.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object
};
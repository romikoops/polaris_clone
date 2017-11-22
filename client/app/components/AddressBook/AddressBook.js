import React, {Component} from 'react';
import PropTypes from 'prop-types';
import { moment } from '../../constants';
import './AddressBook.scss';
export class AddressBook extends Component {
    constructor(props) {
        super(props);
       
    }
    render() {
      const { shipment, hubs } = this.props.shipmentData;
      const { consignee, shipper, notifyees } = this.state;
      return (
        <div className="flex-100 layout-row layout-wrap layout-align-center-start">
          <div className="flex-75 layout-row layout-wrap">
          </div>
        </div>
      )
    }
}
AddressBook.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    user: PropTypes.object
};
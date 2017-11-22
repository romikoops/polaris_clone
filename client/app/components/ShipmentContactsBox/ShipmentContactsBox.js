import React, {Component} from 'react';
import PropTypes from 'prop-types';
import { moment } from '../../constants';
import './ShipmentContactsBox.scss';
export class ShipmentContactsBox extends Component {
    constructor(props) {
        super(props);
        this.state = {
          consignee: {
            firstName: '',
            lastName: '',
            email: '',
            phone: '',
            street: '',
            number: '',
            zipCode: '',
            city: '',
            country: ''
          },
          shipper: {
            firstName: '',
            lastName: '',
            email: '',
            phone: '',
            street: '',
            number: '',
            zipCode: '',
            city: '',
            country: ''
          },
          notifyees: [
            {
              firstName: '',
              lastName: '',
              email: '',
              phone: '',
              street: '',
              number: '',
              zipCode: '',
              city: '',
              country: ''
            }
          ]
        }
    }
    render() {
      const { shipment, hubs } = this.props.shipmentData;
      const { consignee, shipper, notifyees } = this.state;
      return (
        <div className="flex-100 layout-row layout-wrap layout-align-center-start">
          <div className="flex-75 layout-row layout-wrap">
            <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-center-start">
              <div className="flex-100 layout-row layout-align-start-center">
                <i className="fa fa-person flex-none"></i>
                <h6 className="flex-none">Shipper</h6>
              </div>
              <input type="text" value={shipper.firstName} name="shipper-firstName" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={shipper.lastName} name="shipper-lastName" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={shipper.email} name="shipper-email" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={shipper.phone} name="shipper-phone" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={shipper.street} name="shipper-street" onChange={this.handleFormChange} className="contact_field flex-80"/>
              <input type="text" value={shipper.number} name="shipper-number" onChange={this.handleFormChange} className="contact_field flex-20"/>
              <input type="text" value={shipper.zipCode} name="shipper-zipCode" onChange={this.handleFormChange} className="contact_field flex-33"/>
              <input type="text" value={shipper.city} name="shipper-city" onChange={this.handleFormChange} className="contact_field flex-33"/>
              <input type="text" value={shipper.country} name="shipper-country" onChange={this.handleFormChange} className="contact_field flex-33"/>
            </div>

            <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-center-start">
              <div className="flex-100 layout-row layout-align-start-center">
                <i className="fa fa-person flex-none"></i>
                <h6 className="flex-none"> Consignee</h6>
              </div>
              <input type="text" value={shipper.firstName} name="shipper-firstName" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={shipper.lastName} name="shipper-lastName" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={shipper.email} name="shipper-email" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={shipper.phone} name="shipper-phone" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={shipper.street} name="shipper-street" onChange={this.handleFormChange} className="contact_field flex-80"/>
              <input type="text" value={shipper.number} name="shipper-number" onChange={this.handleFormChange} className="contact_field flex-20"/>
              <input type="text" value={shipper.zipCode} name="shipper-zipCode" onChange={this.handleFormChange} className="contact_field flex-33"/>
              <input type="text" value={shipper.city} name="shipper-city" onChange={this.handleFormChange} className="contact_field flex-33"/>
              <input type="text" value={shipper.country} name="shipper-country" onChange={this.handleFormChange} className="contact_field flex-33"/>
            </div>

          </div>
        </div>
      )
    }
}
ShipmentContactsBox.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    user: PropTypes.object
};
import React, {Component} from 'react';
import PropTypes from 'prop-types';
import './ShipmentContactsBox.scss';
export class ShipmentContactsBox extends Component {
    constructor(props) {
        super(props);
        this.handleFormChange = this.handleFormChange.bind(this);
        this.handleNotifyeeChange = this.handleNotifyeeChange.bind(this);
    }
    handleFormChange(event) {
        this.props.handleChange(event);
    }
    handleNotifyeeChange(event) {
        this.props.handleNotifyeeChange(event);
    }
    addNotifyee() {
        this.props.addNotifyee();
    }
    render() {
      // const { shipment } = this.props.shipmentData;
        const { consignee, shipper, notifyees } = this.props;
        const notifyeesArray = [];
        if (notifyees) {
            notifyees.forEach((n, i) => {
                (<div key={n.firstName} className="flex-100 flex-gt-sm-33 layout-row layout-wrap layout-align-center-start">
                        <input type="text" value={n.firstName} name={'notifyee-' + i + '-firstName'} placeholder="First Name" onChange={this.handleNotifyeeChange} className="contact_field flex-50"/>
                        <input type="text" value={n.lastName} name={'notifyee-' + i + '-lastName'} placeholder="Last Name" onChange={this.handleNotifyeeChange} className="contact_field flex-50"/>
                        <input type="text" value={n.email} name={'notifyee-' + i + '-email'} placeholder="Email" onChange={this.handleNotifyeeChange} className="contact_field flex-50"/>
                        <input type="text" value={n.phone} name={'notifyee-' + i + '-phone'} placeholder="Phone" onChange={this.handleNotifyeeChange} className="contact_field flex-50"/>
                        <input type="text" value={n.street} name={'notifyee-' + i + '-street'} placeholder="Street" onChange={this.handleNotifyeeChange} className="contact_field flex-80"/>
                        <input type="text" value={n.number} name={'notifyee-' + i + '-number'} placeholder="Number" onChange={this.handleNotifyeeChange} className="contact_field flex-20"/>
                        <input type="text" value={n.zipCode} name={'notifyee-' + i + '-zipCode'} placeholder="Postal Code" onChange={this.handleNotifyeeChange} className="contact_field flex-33"/>
                        <input type="text" value={n.city} name={'notifyee-' + i + '-city'} placeholder="City" onChange={this.handleNotifyeeChange} className="contact_field flex-33"/>
                        <input type="text" value={n.country} name={'notifyee-' + i + '-country'} placeholder="Country" onChange={this.handleNotifyeeChange} className="contact_field flex-33"/>
                      </div>);
            });
        }
        return (
        <div className="flex-100 layout-row layout-wrap layout-align-center-start">
          <div className="flex-75 layout-row layout-wrap">
            <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-center-start">
              <div className="flex-80 layout-row layout-align-start-center">
                <i className="fa fa-person flex-none"></i>
                <h6 className="flex-none">Shipper</h6>
              </div>
              <input type="text" value={shipper.firstName} name="shipper-firstName" placeholder="First Name" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={shipper.lastName} name="shipper-lastName" placeholder="Last Name" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={shipper.email} name="shipper-email" placeholder="Email" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={shipper.phone} name="shipper-phone" placeholder="Phone" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={shipper.street} name="shipper-street" placeholder="Street" onChange={this.handleFormChange} className="contact_field flex-80"/>
              <input type="text" value={shipper.number} name="shipper-number" placeholder="Number" onChange={this.handleFormChange} className="contact_field flex-20"/>
              <input type="text" value={shipper.zipCode} name="shipper-zipCode" placeholder="Postal Code" onChange={this.handleFormChange} className="contact_field flex-33"/>
              <input type="text" value={shipper.city} name="shipper-city" placeholder="City" onChange={this.handleFormChange} className="contact_field flex-33"/>
              <input type="text" value={shipper.country} name="shipper-country" placeholder="Country" onChange={this.handleFormChange} className="contact_field flex-33"/>
            </div>

            <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-center-start">
              <div className="flex-80 layout-row layout-align-start-center">
                <i className="fa fa-person flex-none"></i>
                <h6 className="flex-none"> Consignee</h6>
              </div>
              <input type="text" value={consignee.firstName} name="consignee-firstName" placeholder="First Name" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={consignee.lastName} name="consignee-lastName" placeholder="Last Name" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={consignee.email} name="consignee-email" placeholder="Email" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={consignee.phone} name="consignee-phone" placeholder="Phone" onChange={this.handleFormChange} className="contact_field flex-50"/>
              <input type="text" value={consignee.street} name="consignee-street" placeholder="Street" onChange={this.handleFormChange} className="contact_field flex-80"/>
              <input type="text" value={consignee.number} name="consignee-number" placeholder="Number" onChange={this.handleFormChange} className="contact_field flex-20"/>
              <input type="text" value={consignee.zipCode} name="consignee-zipCode" placeholder="Postal Code" onChange={this.handleFormChange} className="contact_field flex-33"/>
              <input type="text" value={consignee.city} name="consignee-city" placeholder="City" onChange={this.handleFormChange} className="contact_field flex-33"/>
              <input type="text" value={consignee.country} name="consignee-country" placeholder="Country" onChange={this.handleFormChange} className="contact_field flex-33"/>
            </div>
            <div className="flex-100 layout-row layout-wrap">
                <div className="flex-100 layout-row layout-align-start-center">
                          <i className="fa fa-person flex-none"></i>
                          <h6 className="flex-none"> Notifyees</h6>
                </div>
              {notifyeesArray}
            </div>
          </div>
        </div>
      );
    }
}
ShipmentContactsBox.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    user: PropTypes.object,
    handleChange: PropTypes.func,
    handleNotifyeeChange: PropTypes.func,
    addNotifyee: PropTypes.func
};

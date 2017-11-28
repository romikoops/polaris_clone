import React, {Component} from 'react';
import PropTypes from 'prop-types';
import styles from './ShipmentContactsBox.scss';
import {v4} from 'node-uuid';

export class ShipmentContactsBox extends Component {
    constructor(props) {
        super(props);
        this.handleFormChange = this.handleFormChange.bind(this);
        this.handleNotifyeeChange = this.handleNotifyeeChange.bind(this);
        this.addNotifyee = this.addNotifyee.bind(this);
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
                notifyeesArray.push(<div key={v4()} className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-center-start">
                        <input className={styles.input_100} type="text" value={n.companyName} name={'notifyees-' + i + '-companyName'} placeholder="Company Name" onChange={this.handleNotifyeeChange} />
                        <input className={styles.input_50} type="text" value={n.firstName} name={'notifyees-' + i + '-firstName'} placeholder="First Name" onChange={this.handleNotifyeeChange} />
                        <input className={styles.input_50} type="text" value={n.lastName} name={'notifyees-' + i + '-lastName'} placeholder="Last Name" onChange={this.handleNotifyeeChange} />
                        <input className={styles.input_50} type="text" value={n.email} name={'notifyees-' + i + '-email'} placeholder="Email" onChange={this.handleNotifyeeChange} />
                        <input className={styles.input_50} type="text" value={n.phone} name={'notifyees-' + i + '-phone'} placeholder="Phone" onChange={this.handleNotifyeeChange} />
                        <input className={styles.input_street} type="text" value={n.street} name={'notifyees-' + i + '-street'} placeholder="Street" onChange={this.handleNotifyeeChange} />
                        <input className={styles.input_no} type="text" value={n.number} name={'notifyees-' + i + '-number'} placeholder="Number" onChange={this.handleNotifyeeChange} />
                        <input className={styles.input_zip} type="text" value={n.zipCode} name={'notifyees-' + i + '-zipCode'} placeholder="Postal Code" onChange={this.handleNotifyeeChange} />
                        <input className={styles.input_cc} type="text" value={n.city} name={'notifyees-' + i + '-city'} placeholder="City" onChange={this.handleNotifyeeChange} />
                        <input className={styles.input_cc} type="text" value={n.country} name={'notifyees-' + i + '-country'} placeholder="Country" onChange={this.handleNotifyeeChange} />
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
              <input className={styles.input_100} type="text" value={shipper.companyName} name={'shipper-companyName'} placeholder="Company Name" onChange={this.handleFormChange} />
              <input className={styles.input_50} type="text" value={shipper.firstName} name="shipper-firstName" placeholder="First Name" onChange={this.handleFormChange} />
              <input className={styles.input_50} type="text" value={shipper.lastName} name="shipper-lastName" placeholder="Last Name" onChange={this.handleFormChange} />
              <input className={styles.input_50} type="text" value={shipper.email} name="shipper-email" placeholder="Email" onChange={this.handleFormChange} />
              <input className={styles.input_50} type="text" value={shipper.phone} name="shipper-phone" placeholder="Phone" onChange={this.handleFormChange} />
              <input className={styles.input_street} type="text" value={shipper.street} name="shipper-street" placeholder="Street" onChange={this.handleFormChange} />
              <input className={styles.input_no} type="text" value={shipper.number} name="shipper-number" placeholder="Number" onChange={this.handleFormChange} />
              <input className={styles.input_zip} type="text" value={shipper.zipCode} name="shipper-zipCode" placeholder="Postal Code" onChange={this.handleFormChange} />
              <input className={styles.input_cc} type="text" value={shipper.city} name="shipper-city" placeholder="City" onChange={this.handleFormChange} />
              <input className={styles.input_cc} type="text" value={shipper.country} name="shipper-country" placeholder="Country" onChange={this.handleFormChange} />
            </div>

            <div className="flex-100 flex-gt-sm-50 layout-row layout-wrap layout-align-center-start">
              <div className="flex-80 layout-row layout-align-start-center">
                <i className="fa fa-person flex-none"></i>
                <h6 className="flex-none"> Consignee</h6>
              </div>
              <input className={styles.input_100} type="text" value={consignee.companyName} name={'consignee-companyName'} placeholder="Company Name" onChange={this.handleFormChange} />
              <input className={styles.input_50} type="text" value={consignee.firstName} name="consignee-firstName" placeholder="First Name" onChange={this.handleFormChange} />
              <input className={styles.input_50} type="text" value={consignee.lastName} name="consignee-lastName" placeholder="Last Name" onChange={this.handleFormChange} />
              <input className={styles.input_50} type="text" value={consignee.email} name="consignee-email" placeholder="Email" onChange={this.handleFormChange} />
              <input className={styles.input_50} type="text" value={consignee.phone} name="consignee-phone" placeholder="Phone" onChange={this.handleFormChange} />
              <input className={styles.input_street} type="text" value={consignee.street} name="consignee-street" placeholder="Street" onChange={this.handleFormChange} />
              <input className={styles.input_no} type="text" value={consignee.number} name="consignee-number" placeholder="Number" onChange={this.handleFormChange} />
              <input className={styles.input_zip} type="text" value={consignee.zipCode} name="consignee-zipCode" placeholder="Postal Code" onChange={this.handleFormChange} />
              <input className={styles.input_cc} type="text" value={consignee.city} name="consignee-city" placeholder="City" onChange={this.handleFormChange} />
              <input className={styles.input_cc} type="text" value={consignee.country} name="consignee-country" placeholder="Country" onChange={this.handleFormChange} />
            </div>
            <div className="flex-100 layout-row layout-wrap">
                <div className="flex-100 layout-row layout-align-start-center">
                  <div className="flex-50 layout-row layout-align-start-center">
                      <i className="fa fa-person flex-none"></i>
                      <h6 className="flex-none"> Notifyees</h6>
                  </div>
                  <div className="flex-50 layout-row layout-align-start-center">
                    <div className="flex-50 layout-row layout-align-start-center" onClick={this.addNotifyee}>
                      <i className="fa fa-plus flex-none"></i>
                      <p className="flex-none">Add Notifyees</p>
                    </div>
                  </div>
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

import React, {Component} from 'react';
import PropTypes from 'prop-types';
import styles from './CargoDetails.scss';
import { Checkbox } from '../Checkbox/Checkbox';
import FileUploader from '../FileUploader/FileUploader';
export class CargoDetails extends Component {
    constructor(props) {
        super(props);
        this.state = {
            insuranceView: true,
            customsView: true,
            hsCode: '',
            cargoNotes: '',
            totalGoodsValue: 0
        };
        this.toggleInsurance = this.toggleInsurance.bind(this);
        this.toggleCustoms = this.toggleCustoms.bind(this);
        this.handleChange = this.handleChange.bind(this);
    }
    toggleInsurance() {
        this.setState({insuranceView: !this.state.insuranceView});
    }
    toggleCustoms() {
        this.setState({customsView: !this.state.customsView});
    }
    handleChange(event) {
      const { name, value } = event.target;
      this.setState({[name]: value});
      this.props.handleChange(event);
    }
    render() {
        let packUrl;
        let insuranceVal;
        if (this.props.shipmentData) {
          packUrl = '/shipments/' + this.props.shipmentData.shipment.id + '/upload/packing_sheet';
          insuranceVal = (this.props.shipmentData.shipment.total_price + this.state.totalGoodsValue) * 1.1 * 0.17;
        } else {
          packUrl = '';
          insuranceVal = 0;
        }
        const insuranceBox = (
          <div className="flex-100 layout-row padd_top">
            <div className="flex-80 layout-row layout-wrap">
                <p className="flex-90">
                  <strong> Sign an insurance for the replacement of the goods shipped in case of total or partial loss or damage. The price of the insurance will be determined by the goods value and the transport charges.
                  </strong>
                </p>
                <p className="flex-90">
                  Note that if you choose not to pay to insure your shipment, the goods shipped are automatically covered under legal liability standard to the transportation industry.
                </p>
            </div>
            <div className="flex-20 layout-row layout-wrap">
              <h5 className="flex-100"> Price </h5>
              <h6 className="flex-100"> {insuranceVal.toFixed(2)} €</h6>
            </div>
          </div>
        );
        const customsBox = (
          <div className="flex-100 layout-row padd_top">
            <div className="flex-80 layout-row layout-wrap">
                <p className="flex-90">
                  <strong> Customs Clearance is the documented permission to pass that a national customs authority grants to imported goods so that they can enter the country o to exported goods so that they can leave the country.
                  </strong>
                </p>
                <p className="flex-90">
                  The customs clearance is typically given to a shipping agent to prove that all applicable customs duties have been paid and the shipment has been appoved.
                </p>
            </div>
            <div className="flex-20 layout-row layout-wrap">
              <h5 className="flex-100"> Price </h5>
              <h6 className="flex-100"> 18.50 €</h6>
            </div>
          </div>
        );
        return(
        <div className="flex-100 layout-row layout-wrap padd_top">
          <div className="flex-100 layout-row layout-align-center">
            <div className="flex-75 layout-row layout-wrap">
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.f_header}`}> Cargo Details</p>
              </div>
              <div className="flex-100 layout-row layout-wrap">
                <div className="flex-25 layout-row layout-wrap">
                  <div className="flex-100">
                    <p className="flex-none"> HS Code</p>
                  </div>
                  <div className="flex-100">
                    <input className={styles.cargo_input} type="text" name="hsCode" value={this.state.hsCode} onChange={this.handleChange}/>
                  </div>
                </div>
                <div className="flex-25 layout-row layout-wrap">
                  <div className="flex-100">
                    <p className={`flex-none ${styles.f_header}`}> Total Value of Goods</p>
                  </div>
                  <div className="flex-100">
                    <input className={styles.cargo_input} type="number" name="totalGoodsValue" value={this.state.totalGoodsValue} onChange={this.handleChange}/>
                  </div>
                </div>

                <div className="flex-25 layout-row layout-wrap">
                  <div className="flex-100">
                    <p className={`flex-none ${styles.f_header}`}> Packing Sheet</p>
                  </div>
                  <div className="flex-100">
                    {packUrl ? <FileUploader url={packUrl} type="packing_sheet" text="Packing Sheet"/> : ''}
                  </div>
                </div>

                <div className="flex-50 layout-row layout-wrap">
                  <div className="flex-100">
                    <p className={`flex-none ${styles.f_header}`}> Number and kind of packages, description of goods</p>
                  </div>
                  <div className="flex-100">
                    <textarea className={styles.cargo_text_area} rows="6" name="cargoNotes" value={this.state.cargoNotes} onChange={this.handleChange}/>
                  </div>
                </div>

              </div>
            </div>
          </div>
           <div className="flex-100 layout-row layout-align-center padd_top">
            <div className="flex-75 layout-row layout-wrap">
              <div className="flex-100 layout-row layout-align-start-center">
                <h4 className="flex-none">Insurance</h4>
                <Checkbox onChange={this.toggleInsurance} checked={this.state.insuranceView} />
              </div>
              {this.state.insuranceView ? insuranceBox : ''}
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-center padd_top">
            <div className="flex-75 layout-row layout-wrap">
              <div className="flex-100 layout-row layout-align-start-center">
                <h4 className="flex-none">Customs</h4>
                <Checkbox onChange={this.toggleCustoms} checked={this.state.customsView} />
              </div>
              {this.state.customsView ? customsBox : ''}
            </div>
          </div>
        </div>
        );
    }
}
CargoDetails.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    handleChange: PropTypes.func
};

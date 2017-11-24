import React, {Component} from 'react';
import PropTypes from 'prop-types';
import './CargoDetails.scss';
import { Checkbox } from '../Checkbox/Checkbox';
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
        debugger;
        this.setState({insuranceView: !this.state.insuranceView});
    }
    toggleCustoms() {
        debugger;
        this.setState({customsView: !this.state.customsView});
    }
    handleChange(event) {
      const { name, value } = event.target;
      this.setState({[name]: value});
      this.props.handleChange(event);
    }
    render() {
        const insuranceBox = (
          <div className="flex-100 layout-row">
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
              <h6 className="flex-100"> 18.50 €</h6>
            </div>
          </div>
        );
        const customsBox = (
          <div className="flex-100 layout-row">
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
        <div className="flex-100 layout-row layout-wrap">
          <div className="flex-100 layout-row layout-align-center">
            <div className="flex-75 layout-row layout-wrap">
              <div className="flex-100 layout-row">
                <h6 className="flex-none"> Cargo Details</h6>
              </div>
              <div className="flex-100 layout-row layout-wrap">
                <div className="flex-25 layout-row layout-wrap">
                  <div className="flex-100">
                    <h6 className="flex-none"> HS Code</h6>
                  </div>
                  <div className="flex-100">
                    <input type="text" name="hsCode" value={this.state.hsCode} onChange={this.handleChange}/>
                  </div>
                </div>
                <div className="flex-25 layout-row layout-wrap">
                  <div className="flex-100">
                    <h6 className="flex-none"> Total Value of Goods</h6>
                  </div>
                  <div className="flex-100">
                    <input type="number" name="totalGoodsValue" value={this.state.totalGoodsValue} onChange={this.handleChange}/>
                  </div>
                </div>

                <div className="flex-25 layout-row layout-wrap">
                  <div className="flex-100">
                    <h6 className="flex-none"> Packing Sheet</h6>
                  </div>
                  <div className="flex-100">
                    <input type="number" name="totalValue" value={this.state.totalValue} onChange={this.handleChange}/>
                  </div>
                </div>

                <div className="flex-50 layout-row layout-wrap">
                  <div className="flex-100">
                    <h6 className="flex-none"> Number and kind of packages, description of goods</h6>
                  </div>
                  <div className="flex-100">
                    <textarea rows="6" name="cargoNotes" value={this.state.cargoNotes} onChange={this.handleChange}/>
                  </div>
                </div>

              </div>
            </div>
          </div>
           <div className="flex-100 layout-row layout-align-center">
            <div className="flex-75 layout-row layout-wrap">
              <div className="flex-100 layout-row">
                <h4 className="flex-none">Insurance</h4>
                <Checkbox onChange={this.toggleInsurance} checked={this.state.insuranceView}/>
              </div>
              {this.state.insuranceView ? insuranceBox : ''}
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-center">
            <div className="flex-75 layout-row layout-wrap">
              <div className="flex-100 layout-row">
                <h4 className="flex-none">Customs</h4>
                <Checkbox onChange={this.toggleCustoms} checked={this.state.customsView}/>
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

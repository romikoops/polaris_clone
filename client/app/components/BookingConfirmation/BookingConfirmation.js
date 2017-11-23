import React, {Component} from 'react';
import PropTypes from 'prop-types';
import { moment } from '../../constants';
// import './BookingConfirmation.scss';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
import { CargoItemDetails } from '../CargoItemDetails/CargoItemDetails';
import { ContainerDetails } from '../ContainerDetails/ContainerDetails';
import { RoundButton } from '../RoundButton/RoundButton';
export class BookingConfirmation extends Component {
    constructor(props) {
        super(props);
    }
    render() {
        const { theme, shipmentData } = this.props;
        const { shipment, schedules, hubs, shipper, consignee, notifyees, cargoItems, containers } = shipmentData;
        const createdDate = shipment ? moment(shipment.updated_at).format('DD-MM-YYYY | HH:mm A') :  moment().format('DD-MM-YYYY | HH:mm A');
        const cargo = [];
        if (shipment && shipment.load_type.includes('lcl') && cargoItems) {
            cargoItems.forEach((ci, i) => {
                cargo.push(<div className="flex-33 layout-row layout-align-center-center">
                    <CargoItemDetails item={ci} index={i} />
                </div> );
            });
        }
        if (shipment && shipment.load_type.includes('fcl') && containers) {
            containers.forEach((ci, i) => {
                cargo.push(<div className="flex-33 layout-row layout-align-center-center">
                    <ContainerDetails item={ci} index={i} />
                </div> );
            });
        }
        const nArray = [];
        if (notifyees) {
            notifyees.forEach(n => {
                nArray.push(
                <div className="flex-33 layout-row">
                    <div className="flex-15 layout-column layout-align-start-center">
                      <img src="" alt="" className="flex-none"/>
                    </div>
                    <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                      <p className="flex-100">Notifyee</p>
                      <p className="flex-100">
                        {n.firstName} {n.lastName} <br/>
                        {n.street} {n.street_number} <br/>
                        {n.zipCode} {n.city} <br/>
                        {n.country}
                      </p>
                    </div>
                  </div>
            );
            });
        }
        return (
          shipment ? <div className="flex-100 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-wrap layout-align-center">
              <div className="flex-none content-width layout-row layout-wrap">
                <div className="flex-100 layout-row layout-wrap layout-align-start">
                  <h2 className="flex-100">Thank you for booking with Greencarrier.</h2>
                  <h2 className="flex-100">Hope to see you again soon!</h2>
                </div>
                <div className="flex-100 layout-row layout-align-start">
                  <h4 className="flex-none">Booking Reference: {shipment.imc_reference}</h4>
                </div>
                { shipment ? <RouteHubBox hubs={hubs} route={schedules} theme={theme}/> : ''}
                <div className="flex-100 layout-row">
                  <div className="flex-33 layout-row">
                    <div className="flex-15 layout-column layout-align-start-center">
                      <img src="" alt="" className="flex-none"/>
                    </div>
                    <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                      <p className="flex-100">Shipper</p>
                      <p className="flex-100">
                        {shipper.data.first_name} {shipper.data.last_name} <br/>
                        {shipper.location.street} {shipper.location.street_number} <br/>
                        {shipper.location.zip_code} {shipper.location.city} <br/>
                        {shipper.location.country}
                      </p>
                    </div>
                  </div>
                  <div className="flex-33 layout-row">
                    <div className="flex-15 layout-column layout-align-start-center">
                      <img src="" alt="" className="flex-none"/>
                    </div>
                    <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                      <p className="flex-100">Consignee</p>
                      <p className="flex-100">
                        {consignee.data.first_name} {consignee.data.last_name} <br/>
                        {consignee.location.street} {consignee.location.street_number} <br/>
                        {consignee.location.zip_code} {consignee.location.city} <br/>
                        {consignee.location.country}
                      </p>
                    </div>
                  </div>
                   <div className="flex-33 layout-row layout-align-end">
                    <p className="flex-100">{createdDate}</p>
                    </div>
                </div>
                <div className="flex-100 layout-row">
                  {nArray}
                </div>
                <div className="flex-100 layout-row layout-wrap">
                  {cargo}
                </div>
              </div>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center">
              <div className="flex-none content-width layout-row layout-align-start-center">
                <RoundButton theme={theme} text="Save as pdf" iconClass="fa-download" />
                <RoundButton theme={theme} text="Send data to" iconClass="fa-paper-plane-o" />
              </div>
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-center">
              <div className="flex-none content-width layout-row layout-align-start-center">
                <RoundButton theme={theme} text="Save as pdf" back iconClass="fa-angle-left" />
              </div>
            </div>
          </div>
          : <h1> Loading</h1>
          );
    }
}
BookingConfirmation.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    setData: PropTypes.func
};

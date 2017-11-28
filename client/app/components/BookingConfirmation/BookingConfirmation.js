import React, {Component} from 'react';
import PropTypes from 'prop-types';
import { moment } from '../../constants';
import { v4 } from 'node-uuid';
import styles from './BookingConfirmation.scss';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
import { CargoItemDetails } from '../CargoItemDetails/CargoItemDetails';
import { ContainerDetails } from '../ContainerDetails/ContainerDetails';
import { RoundButton } from '../RoundButton/RoundButton';
export class BookingConfirmation extends Component {
    constructor(props) {
        super(props);
    }
    componentDidMount() {
        const {setStage} = this.props;
        setStage(1);
    }
    render() {
        const { theme, shipmentData } = this.props;
        if (shipmentData) {
            const { shipment, schedules, hubs, shipper, consignee, notifyees, cargoItems, containers } = shipmentData;
            const createdDate = shipment ? moment(shipment.updated_at).format('DD-MM-YYYY | HH:mm A') :  moment().format('DD-MM-YYYY | HH:mm A');
            const cargo = [];
            const textStyle = {
                background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
            };
            if (shipment && shipment.load_type.includes('lcl') && cargoItems) {
                cargoItems.forEach((ci, i) => {
                    cargo.push(<div key={v4()} className="flex-33 layout-row layout-align-center-center">
                      <CargoItemDetails item={ci} index={i} />
                  </div> );
                });
            }
            if (shipment && shipment.load_type.includes('fcl') && containers) {
                containers.forEach((ci, i) => {
                    cargo.push(<div key={v4()} className="flex-33 layout-row layout-align-center-center">
                      <ContainerDetails item={ci} index={i} />
                  </div> );
                });
            }
            const nArray = [];
            if (notifyees) {
                notifyees.forEach(n => {
                    nArray.push(
                  <div key={v4()} className="flex-33 layout-row">
                      <div className="flex-15 layout-column layout-align-start-center">
                        <i className={` ${styles.icon} fa fa-user-circle-o flex-none`} style={textStyle}></i>
                      </div>
                      <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                        <p className="flex-100">Notifyee</p>
                        <p className={` ${styles.address} flex-100`}>
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
          shipmentData && shipment ? <div className="flex-100 layout-row layout-wrap">
            <div className="flex-100 layout-row layout-wrap layout-align-center">
              <div className="flex-none content-width layout-row layout-wrap layout-align-start">
                <div className={` ${styles.thank_box} flex-100 layout-row layout-wrap`}>
                  <div className={` ${styles.thank_you} flex-100 layout-row layout-wrap layout-align-start`}>
                    Thank you for booking with Greencarrier.<br/>
                    Hope to see you again soon!
                  </div>
                  <div className={`flex-100 layout-row layout-align-start ${styles.b_summ}`}>
                    Booking Reference: {shipment.imc_reference}
                  </div>
                </div>
                { shipment ? <RouteHubBox hubs={hubs} route={schedules} theme={theme}/> : ''}
                <div className="flex-100 layout-row">
                  <div className="flex-33 layout-row">
                    <div className="flex-15 layout-column layout-align-start-center">
                      <i className={` ${styles.icon} fa fa-user-circle-o flex-none`} style={textStyle}></i>
                    </div>
                    <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                      <p className="flex-100">Shipper</p>
                      <p className={` ${styles.address} flex-100`}>
                        {shipper.data.first_name} {shipper.data.last_name} <br/>
                        {shipper.location.street} {shipper.location.street_number} <br/>
                        {shipper.location.zip_code} {shipper.location.city} <br/>
                        {shipper.location.country}
                      </p>
                    </div>
                  </div>
                  <div className="flex-33 layout-row">
                    <div className="flex-15 layout-column layout-align-start-center">
                      <i className={` ${styles.icon} fa fa-envelope-open-o flex-none`} style={textStyle}></i>
                    </div>
                    <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                      <p className="flex-100">Consignee</p>
                      <p className={` ${styles.address} flex-100`}>
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
            <div className={` ${styles.btn_sec} flex-100 layout-row layout-wrap layout-align-center`}>
              <div className="flex-none content-width layout-row layout-align-start-center">
                <RoundButton theme={theme} text="Save as pdf" iconClass="fa-download" />
                <RoundButton theme={theme} text="Send data to" iconClass="fa-paper-plane-o" />
              </div>
            </div>
            <div className={` ${styles.btn_sec} flex-100 layout-row layout-wrap layout-align-center`}>
              <div className="flex-none content-width layout-row layout-align-start-center">
                <RoundButton theme={theme} text="Save as pdf" back iconClass="fa-angle-left" />
              </div>
            </div>
          </div>
          : <h1> Loading</h1>
          );
        }
        return(
          <h1> Loading</h1>
        );
    }
}
BookingConfirmation.PropTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    setData: PropTypes.func
};

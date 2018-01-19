import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { moment } from '../../constants';
import { v4 } from 'node-uuid';
import styles from './BookingConfirmation.scss';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
import { CargoItemDetails } from '../CargoItemDetails/CargoItemDetails';
import { ContainerDetails } from '../ContainerDetails/ContainerDetails';
import { RoundButton } from '../RoundButton/RoundButton';
import defaults from '../../styles/default_classes.scss';
import { Price } from '../Price/Price';

export class BookingConfirmation extends Component {
    constructor(props) {
        super(props);
    }
    componentDidMount() {
        const { setStage } = this.props;
        setStage(5);
        window.scrollTo(0, 0);
    }
    render() {
        const { theme, shipmentData, tenant, user, shipmentDispatch } = this.props;
        if (!shipmentData) return <h1>Loading</h1>;

        const {
            shipment,
            schedules,
            hubs,
            shipper,
            consignee,
            notifyees,
            cargoItems,
            containers
        } = shipmentData;
        if (!shipment) return <h1> Loading</h1>;


      const createdDate = shipment ? moment(shipment.updated_at).format('DD-MM-YYYY | HH:mm A') :  moment().format('DD-MM-YYYY | HH:mm A');
      const cargo = [];
      const textStyle = {
          background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
      };
      const tenantName = tenant ? tenant.name : '';

      const pushToCargo = (array, Comp) => {
        array.forEach((ci, i) => {
          const offset = i % 3 !== 0 ? 'offset-5' : '';
          cargo.push(
            <div key={v4()} className={`flex-30 ${offset} layout-row layout-align-center-center`}>
              <Comp item={ci} index={i} theme={theme} viewHSCodes={false}/>
            </div>
          );
        });
      };
      if (shipment.load_type === 'cargo_item' && cargoItems) pushToCargo(cargoItems, CargoItemDetails);
      if (shipment.load_type === 'container' && containers) pushToCargo(containers, ContainerDetails);
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
                    {n.first_name} {n.last_name} <br/>
                  </p>
                </div>
              </div>
            );
         });
      }

        return (
            <div className="flex-100 layout-row layout-wrap">
                <div className="flex-100 layout-row layout-wrap layout-align-center">
                    <div className={defaults.content_width + ' flex-none  layout-row layout-wrap layout-align-start'}>
                        <div className={` ${styles.thank_box} flex-100 layout-row layout-wrap`}>
                            <div className={` ${styles.thank_you} flex-100 layout-row layout-wrap layout-align-start`}>
                    Thank you for booking with {tenantName}.<br/>
                    Hope to see you again soon!
                            </div>
                            <div className={`flex-100 layout-row layout-align-start ${styles.b_ref}`}>
                    Booking Reference: {shipment.imc_reference}
                            </div>
                        </div>
                        <RouteHubBox hubs={hubs} route={schedules} theme={theme}/>
                        <div className={`${styles.b_summ} flex-100`}>
                            <div className={`${styles.b_summ_top} flex-100 layout-row`}>
                                <div className="flex-33 layout-row">
                                    <div className="flex-15 layout-column layout-align-start-center">
                                        <i className={`${styles.icon} fa fa-user-circle-o flex-none`} style={textStyle}></i>
                                    </div>
                                    <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                                        <p className="flex-100">Shipper</p>
                                        <p className={`${styles.address} flex-100`}>
                                            {shipper.data.first_name} {shipper.data.last_name} <br/>
                                            {shipper.location.street} {shipper.location.street_number} <br/>
                                            {shipper.location.zip_code} {shipper.location.city} <br/>
                                            {shipper.location.country}
                                        </p>
                                    </div>


                                </div>
                                <div className="flex-33 layout-row">
                                    <div className="flex-15 layout-column layout-align-start-center">
                                        <i
                                            className={` ${
                                                styles.icon
                                            } fa fa-envelope-open-o flex-none`}
                                            style={textStyle}
                                        />
                                    </div>
                                    <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                                        <p className="flex-100">Consignee</p>
                                        <p
                                            className={` ${
                                                styles.address
                                            } flex-100`}
                                        >
                                            {consignee.data.first_name}{' '}
                                            {consignee.data.last_name} <br />
                                            {consignee.location.street}{' '}
                                            {consignee.location.street_number}{' '}
                                            <br />
                                            {consignee.location.zip_code}{' '}
                                            {consignee.location.city} <br />
                                            {consignee.location.country}
                                        </p>
                                    </div>
                                </div>
                                <div className="flex-33 layout-row layout-align-end">
                                    <p>{createdDate}</p>
                                </div>
                            </div>
                            <div className="flex-100 layout-row">{nArray}</div>
                            <div
                                className={`${
                                    styles.b_summ_bottom
                                } flex-100 layout-row layout-wrap`}
                            >
                                <div
                                    className={`${
                                        styles.wrapper_cargo
                                    } flex-100 layout-row layout-wrap`}
                                >
                                    {cargo}
                                </div>
                                <div className="flex-100 layout-row layout-align-end-end">
                                    <div
                                        className={`${
                                            styles.tot_price
                                        } flex-none layout-row layout-align-space-between`}
                                    >
                                        <p>Total Price:</p>{' '}
                                        <Price value={shipment.total_price} user={user}/>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
                {/* <div className={`${styles.btn_sec} flex-100 layout-row layout-wrap layout-align-center`}>
                    <div className={defaults.content_width + ' flex-none  layout-row layout-wrap layout-align-start-center'}>
                        <div className="flex-none layout-row">

                            <RoundButton
                                theme={theme}
                                text="Save as pdf"
                                iconClass="fa-download"
                            />
                        </div>
                        <div className="flex-none offset-5 layout-row">
                            <RoundButton
                                theme={theme}
                                text="Send data to"
                                iconClass="fa-paper-plane-o"
                            />
                        </div>
                    </div>
                </div>*/}
                <hr className={`${styles.sec_break} flex-100`}/>
                <div className={`${styles.back_to_dash_sec} flex-100 layout-row layout-wrap layout-align-center`}>
                  <div className={`${defaults.content_width} flex-none content-width layout-row layout-align-start-center`}>
                    <RoundButton theme={theme} text="Back to dashboard" back iconClass="fa-angle0-left" handleNext={() => shipmentDispatch.goTo('/account')}/>
                  </div>
                </div>
            </div>
        );
    }
}
BookingConfirmation.propTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    setData: PropTypes.func
};

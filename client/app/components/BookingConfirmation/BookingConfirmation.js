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
import { TextHeading } from '../TextHeading/TextHeading';
import { gradientTextGenerator, /* gradientGenerator **/ } from '../../helpers';

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
        const textStyle = theme ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : {color: 'black'};
        //      const gradientStyle = theme && theme.colors
        //                    ? gradientGenerator(
        //                        theme.colors.primary,
        //                        theme.colors.secondary
        //                    )
        //                    : {background: 'black'};
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
                            <p className="flex-100">
                                <TextHeading theme={theme} size={4}  text="Notifyee" />
                            </p>
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
                                <p className="flex-100">
                                    Thank you for booking with {tenantName}.
                                </p>
                            </div>
                            <div className={`flex-100 layout-row layout-align-start ${styles.b_ref}`}>
                                <p className="flex-100">Booking Reference: {shipment.imc_reference}</p>
                            </div>
                            <div className={`flex-100 layout-row layout-align-start layout-wrap ${styles.thank_details}`}>
                                <p className="flex-100"> We have just sent your order confirmation with all the booking details to your account e-mail address. Now, our team will review your order and contact you with any further instructions or simply confirm the request via e-mail.</p>
                                <p className="flex-100">Do not hesitate to contact us either through the message center or your account manager </p>
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
                                        <p className="flex-100">
                                            <TextHeading theme={theme} size={4}  text="Shipper" />
                                        </p>
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
                                        <p className="flex-100">
                                            <TextHeading theme={theme} size={4}  text="Notifyee" />
                                        </p>
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
                                <div className="flex-33 layout-row layout-align-end layout-wrap">
                                    <p className="flex-100">Booking placed at: {createdDate}</p>
                                    <p className="flex-100">Booking placed by: {user.first_name} {user.last_name} </p>
                                </div>
                            </div>
                            <div className={`${styles.b_summ_top} flex-100 layout-row layout-wrap`}>{nArray}</div>
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
                                    <div className="flex-100 layout-row layout-align-start-center">
                                        <p className="flex-none clip">
                                            <TextHeading theme={theme} size={3}  text="Cargo Details" />
                                        </p>
                                    </div>
                                    {cargo}
                                </div>
                                <div className="flex-100 layout-row layout-align-end-end">
                                    <div className={`${styles.tot_price} flex-none layout-row layout-align-space-between`} >
                                        <p className="flex-none clip">
                                            <TextHeading theme={theme} size={3}  text="Total Price:" />
                                        </p>
                                        {' '}
                                        <Price value={shipment.total_price} user={user}/>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
                <hr className={`${styles.sec_break} flex-100`}/>
                <div className={`${styles.back_to_dash_sec} flex-100 layout-row layout-wrap layout-align-center`}>
                    <div className={`${defaults.content_width} flex-none content-width layout-row layout-align-start-center`}>
                        <RoundButton theme={theme} text="Back to dashboard" back iconClass="fa-angle0-left" handleNext={() => shipmentDispatch.toDashboard()}/>
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

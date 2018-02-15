import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { moment } from '../../constants';
import { v4 } from 'node-uuid';
import styles from './ShipmentThankYou.scss';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
import { CargoItemDetails } from '../CargoItemDetails/CargoItemDetails';
import { ContainerDetails } from '../ContainerDetails/ContainerDetails';
import { RoundButton } from '../RoundButton/RoundButton';
import defaults from '../../styles/default_classes.scss';
import { Price } from '../Price/Price';
import { TextHeading } from '../TextHeading/TextHeading';
import { gradientTextGenerator, /* gradientGenerator **/ } from '../../helpers';
import { Tooltip } from '../Tooltip/Tooltip';

export class ShipmentThankYou extends Component {
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
        const textStyle = theme ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : {color: 'black'};
        const brightGradientStyle = theme ? gradientTextGenerator(theme.colors.brightPrimary, theme.colors.brightSecondary) : {color: 'black'};
        const tenantName = tenant ? tenant.name : '';
       

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
                        
                <hr className={`${styles.sec_break} flex-100`}/>
                <div className={`${styles.back_to_dash_sec} flex-100 layout-row layout-wrap layout-align-center`}>
                    <div className={`${defaults.content_width} flex-none content-width layout-row layout-align-start-center`}>
                        <RoundButton theme={theme}
                            text="Back to dashboard"
                            back iconClass="fa-angle0-left"
                            handleNext={() => shipmentDispatch.toDashboard()}/>
                    </div>
                </div>
            </div>
          </div>
        </div>
        );
    }
}
ShipmentThankYou.propTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    setData: PropTypes.func
};

import React, { Component } from 'react';
import PropTypes from 'prop-types';
import GmapsLoader from '../../hocs/GmapsLoader';
import styles from './ShipmentDetails.scss';
import errorStyles from '../../styles/errors.scss';
import defaults from '../../styles/default_classes.scss';
import { moment, incoterms } from '../../constants';
import DayPickerInput from 'react-day-picker/DayPickerInput';
import '../../styles/day-picker-custom.css';
import { RoundButton } from '../RoundButton/RoundButton';
import { Tooltip } from '../Tooltip/Tooltip';
import { ShipmentLocationBox } from '../ShipmentLocationBox/ShipmentLocationBox';
import { ShipmentContainers } from '../ShipmentContainers/ShipmentContainers';
import { ShipmentCargoItems } from '../ShipmentCargoItems/ShipmentCargoItems';
// import { RouteSelector } from '../RouteSelector/RouteSelector';
import { FlashMessages } from '../FlashMessages/FlashMessages';
import { isEmpty } from '../../helpers/isEmpty.js';
import * as Scroll from 'react-scroll';
import Select from 'react-select';
import '../../styles/select-css-custom.css';
import styled from 'styled-components';

export class ShipmentDetails extends Component {
    constructor(props) {
        super(props);
        this.state = {
            origin: {},
            destination: {},
            containers: [
                {
                    payload_in_kg: 0,
                    sizeClass: '',
                    tareWeight: 0,
                    quantity: 1,
                    dangerousGoods: false
                }
            ],
            cargoItems: [
                {
                    payload_in_kg: 0,
                    dimension_x: 0,
                    dimension_y: 0,
                    dimension_z: 0,
                    quantity: 1,
                    colliType: '',
                    dangerousGoods: false
                }
            ],
            routes: {},
            containersErrors: [
                {
                    payload_in_kg: true
                }
            ],
            cargoItemsErrors: [
                {
                    payload_in_kg: true,
                    dimension_x: true,
                    dimension_y: true,
                    dimension_z: true
                }
            ],
            nextStageAttempt: false,
            has_on_carriage: false,
            has_pre_carriage: false,
            shipment: this.props.shipmentData.shipment,
            allNexuses: this.props.shipmentData.all_nexuses,
            routeSet: false,
        };

        if (this.props.shipmentData.shipment) {
            this.state.selectedDay = this.props.shipmentData.shipment.planned_pickup_date;
            this.state.has_on_carriage = this.props.shipmentData.shipment.has_on_carriage;
            this.state.has_pre_carriage = this.props.shipmentData.shipment.has_pre_carriage;
        }

        this.handleAddressChange = this.handleAddressChange.bind(this);
        this.handleDayChange = this.handleDayChange.bind(this);
        this.handleNextStage = this.handleNextStage.bind(this);
        this.addNewCargoItem = this.addNewCargoItem.bind(this);
        this.addNewContainer = this.addNewContainer.bind(this);
        this.setTargetAddress = this.setTargetAddress.bind(this);
        this.toggleCarriage = this.toggleCarriage.bind(this);
        this.handleCargoItemChange = this.handleCargoItemChange.bind(this);
        this.handleContainerChange = this.handleContainerChange.bind(this);
        this.deleteCargo = this.deleteCargo.bind(this);
        this.scrollTo = this.scrollTo.bind(this);
        this.setIncoTerm = this.setIncoTerm.bind(this);
        this.handleSelectLocation = this.handleSelectLocation.bind(this);
    }
    componentDidMount() {
        const { prevRequest, setStage } = this.props;
        if (prevRequest && prevRequest.shipment) {
            this.loadPrevReq(prevRequest.shipment);
        }
        window.scrollTo(0, 0);
        setStage(2);
        console.log('######### MOUNTED ###########');
    }
    componentDidUpdate() {
        console.log('######### UPDATED ###########');
    }

    scrollTo(target) {
        Scroll.scroller.scrollTo(target, {
            duration: 800,
            smooth: true,
            offset: -50
        });
    }

    loadPrevReq(obj) {
        this.setState({
            cargoItems: obj.cargo_items_attributes,
            containers: obj.containers_attributes,
            selectedDay: obj.planned_pickup_date,
            origin: {
                fullAddress: obj.origin_user_input ? obj.origin_user_input : '',
                hub_id: obj.origin_id
            },
            destination: {
                fullAddress: obj.destination_user_input
                    ? obj.destination_user_input
                    : '',
                hub_id: obj.destination_id
            },
            has_on_carriage: obj.has_on_carriage,
            has_pre_carriage: obj.has_pre_carriage,
            routeSet: true
        });
    }

    newContainerGrossWeight() {
        const container = this.state.containers.new;
        container.type ? container.tare_weight + container.weight : 0;
    }

    handleDayChange(selectedDay) {
        this.setState({ selectedDay });
    }
    deleteCargo(target, index) {
        const cargoArr = this.state[target];
        const errorsArr = this.state[target + 'Errors'];
        cargoArr.splice(index, 1);
        errorsArr.splice(index, 1);
        this.setState({[target]: cargoArr});
        this.setState({[target + 'Errors']: errorsArr});
    }
    handleSelectLocation(bool) {
        this.setState({
            AddressFormsHaveErrors: bool
        });
    }
    handleAddressChange(event) {
        const eventKeys = event.target.name.split('-');
        const key1 = eventKeys[0];
        const key2 = eventKeys[1];
        const val = event.target.value;
        const addObj = this.state[key1];
        addObj[key2] = val;
        let fullAddress = this.state[key1].fullAddress;
        // ;
        if (fullAddress) {
            fullAddress = addObj.number + ' ' + addObj.street + ' ' + addObj.city + ' ' + addObj.zipCode + ' ' + addObj.country;
        }
        this.setState({
            [key1]: {...this.state[key1], [key2]: val, fullAddress }
        });
    }

    handleCargoItemChange(event, hasError) {
        const { name, value } = event.target;
        const [ index, suffixName ] = name.split('-');
        const { cargoItems, cargoItemsErrors } = this.state;
        cargoItems[index][suffixName] = value;
        if (hasError !== undefined) cargoItemsErrors[index][suffixName] = hasError;
        this.setState({ cargoItems, cargoItemsErrors });
    }

    handleContainerChange(event, hasError) {
        const { name, value } = event.target;
        const [ index, suffixName ] = name.split('-');
        const { containers, containersErrors } = this.state;
        containers[index][suffixName] = value;
        if (hasError !== undefined) containersErrors[index][suffixName] = hasError;

        this.setState({ containers, containersErrors });
    }

    addNewCargoItem() {
        const newCargoItem = {
            payload_in_kg: 0,
            dimension_x: 0,
            dimension_y: 0,
            dimension_z: 0,
            quantity: 1,
            dangerousGoods: false
        };
        const newErrors = {
            payload_in_kg: true,
            dimension_x: true,
            dimension_y: true,
            dimension_z: true
        };
        const { cargoItems, cargoItemsErrors } = this.state;
        cargoItems.push(newCargoItem);
        cargoItemsErrors.push(newErrors);
        this.setState({ cargoItems, cargoItemsErrors });
    }

    addNewContainer() {
        const newContainer = {
            payload_in_kg: 0,
            sizeClass: '',
            tareWeight: 0,
            quantity: 1,
            dangerousGoods: false
        };

        const newErrors = {
            payload_in_kg: true,
        };

        const { containers, containersErrors } = this.state;
        containers.push(newContainer);
        containersErrors.push(newErrors);
        this.setState({ containers, containersErrors });
    }

    setTargetAddress(target, address) {
        this.setState({ [target]: address });
    }
    errorsExist(errorsObjects) {
        let returnBool = false;
        errorsObjects.forEach(errorsObj => {
            if (Object.values(errorsObj).indexOf(true) > -1) returnBool = true;
        });
        return returnBool;
    }

    handleNextStage() {
        if (!this.state.selectedDay) {
            this.setState({ nextStageAttempt: true });
            this.scrollTo('dayPicker');
            return;
        }

        if (!this.state.incoterm) {
            this.setState({ nextStageAttempt: true });
            this.scrollTo('incoterms');
            return;
        }
        if (
            isEmpty(this.state.origin) ||
            isEmpty(this.state.destination) ||
            this.state.AddressFormsHaveErrors
        ) {
            this.setState({ nextStageAttempt: true });
            this.scrollTo('map');
            return;
        }
        // This was implemented under the assuption that in the initial state the following return values apply:
        //      (1) this.errorsExist(this.state.cargoItemsErrors) #=> true
        //      (2) this.errorsExist(this.state.containersErrors) #=> true
        // So it will break out of the function and set nextStage attempt to true,
        // in case one of them returns false
        if (
            this.errorsExist(this.state.cargoItemsErrors) &&
            this.errorsExist(this.state.containersErrors)
        ) {
            this.setState({ nextStageAttempt: true });
            return;
        }


        console.log('NEXT STAGE PLZ');

        const data = {
            shipment: this.state.shipment
                ? this.state.shipment
                : this.props.shipmentData.shipment
        };
        data.shipment.origin_user_input = this.state.origin.fullAddress
            ? this.state.origin.fullAddress
            : '';
        data.shipment.destination_user_input = this.state.destination
            .fullAddress
            ? this.state.destination.fullAddress
            : '';
        data.shipment.origin_id = this.state.origin.hub_id;
        data.shipment.destination_id = this.state.destination.hub_id;
        data.shipment.cargo_items_attributes = this.state.cargoItems;
        data.shipment.containers_attributes = this.state.containers;
        data.shipment.has_on_carriage = this.state.has_on_carriage;
        data.shipment.has_pre_carriage = this.state.has_pre_carriage;
        data.shipment.planned_pickup_date = this.state.selectedDay;
        data.shipment.incoterm = this.state.incoterm;
        this.props.setShipmentDetails(data);
    }

    returnToDashboard() {
        this.props.shipmentDispatch.goTo('/dashboard');
    }

    toggleCarriage(target, value) {
        this.setState({ [target]: value });
    }
    setIncoTerm(opt) {
        this.setState({incoterm: opt.value});
    }

    render() {
        const { theme, scope, messages, shipmentData, shipmentDispatch } = this.props;
        let cargoDetails;
        if (shipmentData.shipment) {
            if (shipmentData.shipment.load_type === 'container') {
                cargoDetails = (
                    <ShipmentContainers
                        containers={this.state.containers}
                        addContainer={this.addNewContainer}
                        handleDelta={this.handleContainerChange}
                        deleteItem={this.deleteCargo}
                        nextStageAttempt={this.state.nextStageAttempt}
                        theme={theme}
                        scope={scope}
                    />
                );
            }
            if (shipmentData.shipment.load_type === 'cargo_item') {
                cargoDetails = (
                    <ShipmentCargoItems
                        cargoItems={this.state.cargoItems}
                        addCargoItem={this.addNewCargoItem}
                        handleDelta={this.handleCargoItemChange}
                        deleteItem={this.deleteCargo}
                        nextStageAttempt={this.state.nextStageAttempt}
                        theme={theme}
                        scope={scope}
                        availableCargoItemTypes={shipmentData.cargoItemTypes}
                    />
                );
            }
        }

        const routeIds = shipmentData.routes ? shipmentData.routes.map(route => route.id) : [];

        const mapBox = (
            <GmapsLoader
                theme={theme}
                setTargetAddress={this.setTargetAddress}
                allNexuses={shipmentData.all_nexuses}
                component={ShipmentLocationBox}
                toggleCarriage={this.toggleCarriage}
                origin={this.state.origin}
                destination={this.state.destination}
                nextStageAttempt={this.state.nextStageAttempt}
                handleAddressChange={this.handleAddressChange}
                shipment={shipmentData}
                routeIds={routeIds}
                nexusDispatch={this.props.nexusDispatch}
                availableDestinations={this.props.availableDestinations}
                handleSelectLocation={this.handleSelectLocation}
            />
        );
        const formattedSelectedDay = this.state.selectedDay
            ? moment(this.state.selectedDay).format('DD/MM/YYYY')
            : '';
        const flash = messages && messages.length > 0 ? <FlashMessages messages={messages} /> : '';
        const future = {
            after: new Date(),
        };

        const showDayPickerError = this.state.nextStageAttempt && !this.state.selectedDay;
        const showIncotermError = this.state.nextStageAttempt && !this.state.incoterm;

        const backgroundColor = value => !value && this.state.nextStageAttempt ? '#FAD1CA' : '#F9F9F9';
        const placeholderColorOverwrite = value => (
            !value && this.state.nextStageAttempt ?
                'color: rgb(211, 104, 80);' :
                ''
        );
        const StyledSelect = styled(Select)`
            .Select-control {
                background-color: ${props => backgroundColor(props.value)};
                box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
                border: 1px solid #F2F2F2 !important;
            }
            .Select-menu-outer {
                box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
                border: 1px solid #F2F2F2;
            }
            .Select-value {
                background-color: ${props => backgroundColor(props.value)};
                border: 1px solid #F2F2F2;
            }
            .Select-placeholder {
                background-color: ${props => backgroundColor(props.value)};
                ${props => placeholderColorOverwrite(props.value)}
            }
            .Select-option {
                background-color: #F9F9F9;
            }
        `;
        const dayPickerSection = (
            <div className={`
                ${styles.date_sec} ${defaults.content_width}
                layout-row flex-none layout-align-start-center
            `}>
                <div className="layout-row flex-50 layout-align-start-center layout-wrap">
                    <div className="flex-100 layout-row layout-align-start-center">
                        {' '}
                        <p className="flex-none letter_2">{this.state.has_pre_carriage ? 'Approximate Pickup Date:' : 'Approximate Departure Date:'}</p>
                        <Tooltip theme={theme} text="planned_pickup_date" icon="fa-info-circle" />
                        {' '}
                    </div>
                    <div className={'flex-none layout-row ' + styles.dpb}>
                        <div className={'flex-none layout-row layout-align-center-center ' + styles.dpb_icon}>
                            <i className="flex-none fa fa-calendar"></i>
                        </div>
                        <DayPickerInput
                            name="dayPicker"
                            placeholder="DD/MM/YYYY"
                            format="DD/MM/YYYY"
                            value={formattedSelectedDay}
                            className={`${styles.dpb_picker} ${showDayPickerError ? styles.with_errors : ''}`}
                            onDayChange={this.handleDayChange}
                            modifiers={future}
                        />
                        <span className={errorStyles.error_message}>
                            {showDayPickerError ? 'Must not be blank' : ''}
                        </span>
                    </div>

                </div>

                <div className="flex-50 layout-row layout-wrap layout-align-end-center">
                    <div className="flex-100 layout-row layout-align-end-center">
                        <p className="flex-none letter_2">
                            {' '}
                            {'Select Incoterm:'}
                            {' '}
                        </p>
                    </div>
                    <div className="flex-80" name="incoterms" style={{position: 'relative'}}>
                        <StyledSelect
                            name="incoterms"
                            className={styles.select}
                            value={this.state.incoterm}
                            options={incoterms}
                            onChange={this.setIncoTerm}
                        />
                        <span className={errorStyles.error_message}>
                            {showIncotermError ? 'Must not be blank' : ''}
                        </span>
                    </div>
                </div>
            </div>
        );

        return (
            <div className="layout-row flex-100 layout-wrap">
                {flash}
                <div className="layout-row flex-100 layout-wrap layout-align-center-center">
                    { dayPickerSection }
                </div>
                <div className="layout-row flex-100 layout-wrap">
                    {mapBox}
                </div>
                <div className={`layout-row flex-100 layout-wrap ${styles.cargo_sec}`}>
                    {cargoDetails}
                </div>
                <div className={'layout-row flex-100 layout-wrap layout-align-center-center ' + defaults.border_divider}>
                    <div className={`
                        ${styles.btn_sec} ${defaults.content_width}
                        layout-row flex-none layout-wrap layout-align-start-start
                    `}>
                        <RoundButton
                            text="Get Offers"
                            handleNext={this.handleNextStage}
                            theme={theme}
                            active
                        />
                    </div>
                </div>
                <div className={'layout-row flex-100 layout-wrap layout-align-center-center ' + defaults.border_divider}>
                    <div className={`
                        ${styles.btn_sec} ${defaults.content_width} 
                        layout-row flex-none layout-wrap layout-align-start-start
                    `}>
                        <RoundButton
                            text="Back to Dashboard"
                            handleNext={this.returnToDashboard}
                            iconClass="fa-angle-left"
                            theme={theme}
                            back
                            handleNext={() => shipmentDispatch.goTo('/account')}
                        />
                    </div>
                </div>
            </div>
        );
    }
}

ShipmentDetails.propTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    history: PropTypes.object,
    match: PropTypes.object,
    setShipmentDetails: PropTypes.func,
    messages: PropTypes.array
};

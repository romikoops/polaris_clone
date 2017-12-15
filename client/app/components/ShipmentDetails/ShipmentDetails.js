import React, { Component } from 'react';
import PropTypes from 'prop-types';
import GmapsLoader from '../../hocs/GmapsLoader';
import styles from './ShipmentDetails.scss';
import { moment } from '../../constants';
import DayPickerInput from 'react-day-picker/DayPickerInput';
import 'react-day-picker/lib/style.css';
import { RoundButton } from '../RoundButton/RoundButton';
import { ShipmentLocationBox } from '../ShipmentLocationBox/ShipmentLocationBox';
import { ShipmentContainers } from '../ShipmentContainers/ShipmentContainers';
import { ShipmentCargoItems } from '../ShipmentCargoItems/ShipmentCargoItems';
import { RouteSelector } from '../RouteSelector/RouteSelector';
import { FlashMessages } from '../FlashMessages/FlashMessages';
import defaults from '../../styles/default_classes.scss';
export class ShipmentDetails extends Component {
    constructor(props) {
        super(props);
        this.state = {
            origin: {
                number: '',
                street: '',
                zipCode: '',
                city: '',
                fullAddress: ''
            },
            destination: {
                number: '',
                street: '',
                zipCode: '',
                city: '',
                fullAddress: ''
            },
            containers: [
                {
                    payload_in_kg: 0,
                    sizeClass: '',
                    tareWeight: 0,
                    dangerousGoods: false
                }
            ],
            cargoItems: [
                {
                    payload_in_kg: 0,
                    dimension_x: 0,
                    dimension_y: 0,
                    dimension_z: 0,
                    dangerousGoods: false
                }
            ],
            routes: {},
            has_on_carriage: false,
            has_pre_carriage: false,
            shipment: this.props.shipmentData.shipment,
            allNexuses: this.props.shipmentData.all_nexuses,
            routeSet: false
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
        this.setTargetLocation = this.setTargetLocation.bind(this);
        this.selectRoute = this.selectRoute.bind(this);
        this.toggleCarriage = this.toggleCarriage.bind(this);
        this.handleCargoItemChange = this.handleCargoItemChange.bind(this);
        this.handleContainerChange = this.handleContainerChange.bind(this);
        this.deleteCargo = this.deleteCargo.bind(this);
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
        const arr = this.state[target];
        arr.splice(index, 1);
        this.setState({[target]: arr});
    }

    handleAddressChange(event) {
        const eventKeys = event.target.name.split('-');
        const key1 = eventKeys[0];
        const key2 = eventKeys[1];
        const val = event.target.value;
        const addObj = this.state[key1];
        addObj[key2] = val;
        let fullAddress = this.state[key1].fullAddress;
        // debugger;
        if (fullAddress) {
            fullAddress = addObj.number + ' ' + addObj.street + ' ' + addObj.city + ' ' + addObj.zipCode + ' ' + addObj.country;
        }
        this.setState({
            [key1]: {...this.state[key1], [key2]: val, fullAddress }
        });
        console.log({...this.state[key1], [key2]: val, fullAddress });
    }

    handleCargoItemChange(event) {
        const { name, value } = event.target;
        const itemArr = this.state.cargoItems;
        itemArr[0][name] = value;
        console.log(itemArr);
        this.setState({ cargoItems: itemArr });
    }

    handleContainerChange(event) {
        const { name, value } = event.target;
        const itemArr = this.state.containers;
        itemArr[0][name] = value;

        this.setState({ containers: itemArr });
    }

    addNewCargoItem() {
        const newCI = {
            payload_in_kg: 0,
            dimension_x: 0,
            dimension_y: 0,
            dimension_z: 0,
            dangerousGoods: false
        };
        const currArray = this.state.cargoItems;
        currArray.unshift(newCI);
        this.setState({ cargoItems: currArray });
    }

    addNewContainer() {
        const newCont = {
            payload_in_kg: 0,
            sizeClass: '',
            tareWeight: 0,
            dangerousGoods: false
        };
        const currArray = this.state.containers;
        currArray.unshift(newCont);
        this.setState({ containers: currArray });
    }

    setTargetLocation(target, address) {
        this.setState({ [target]: address });
    }

    handleNextStage() {
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
        this.props.setShipmentDetails(data);
    }

    returnToDashboard() {
        this.props.history.push('/dashboard');
    }

    selectRoute(route) {
        this.setState({ selectedRoute: route, routeSet: true });
    }

    toggleCarriage(target, value) {
        this.setState({ [target]: value });
    }

    render() {
        const { theme, messages, shipmentData } = this.props;
        let cargoDetails;
        if (shipmentData.shipment) {
            if (shipmentData.shipment.load_type.includes('fcl')) {
                cargoDetails = (
                    <ShipmentContainers
                        containers={this.state.containers}
                        addContainer={this.addNewContainer}
                        handleDelta={this.handleContainerChange}
                        deleteItem={this.deleteCargo}
                    />
                );
            }
            if (shipmentData.shipment.load_type.includes('lcl')) {
                cargoDetails = (
                    <ShipmentCargoItems
                        cargoItems={this.state.cargoItems}
                        addCargoItem={this.addNewCargoItem}
                        handleDelta={this.handleCargoItemChange}
                        deleteItem={this.deleteCargo}
                    />
                );
            }

            // cargoDetails = this.state.shipment && this.state.shipment.load_type.includes('fcl') ? <ShipmentContainers containers={this.state.containers} addContainer={this.addNewContainer}/> : <ShipmentCargoItems cargoItems={this.state.cargoItems} addCargoItem={this.addNewCargoItem}/>;
        }

        const rSelect = (
            <RouteSelector
                theme={theme}
                setRoute={this.selectRoute}
                routes={shipmentData.routes}
            />
        );
        const mapBox = (
            <GmapsLoader
                theme={theme}
                selectLocation={this.setTargetLocation}
                allNexuses={shipmentData.all_nexuses}
                component={ShipmentLocationBox}
                selectedRoute={this.state.selectedRoute}
                toggleCarriage={this.toggleCarriage}
                origin={this.state.origin}
                destination={this.state.destination}
                handleAddressChange={this.handleAddressChange}
            />
        );
        const value = this.state.selectedDay
            ? moment(this.state.selectedDay).format('DD/MM/YYYY')
            : '';
        const flash = messages && messages.length > 0 ? <FlashMessages messages={messages} /> : '';
        const future = {
            after: new Date(),
        };
        const dayPickerSection = (
            <div
                className={`${
                    styles.date_sec
                } layout-row flex-none ${defaults.content_width} layout-align-start-center`}
            >
                <div className="layout-row flex-none layout-wrap">
                    <p className="flex-100">
                        {' '}
                        {'Approximate Pickup Date:'}
                        {' '}
                    </p>
                    <div className={'flex-none layout-row ' + styles.dpb}>
                        <div className={'flex-none layout-row layout-align-center-center ' + styles.dpb_icon}>
                            <i className="flex-none fa fa-calendar"></i>
                        </div>
                        <DayPickerInput
                            name="birthday"
                            placeholder="DD/MM/YYYY"
                            format="DD/MM/YYYY"
                            value={value}
                            className={styles.dpb_picker}
                            onDayChange={this.handleDayChange}
                            modifiers={future}
                        />
                    </div>

                </div>
            </div>
        );
        return (
            <div className="layout-row flex-100 layout-wrap">
                {flash}
                <div className="layout-row flex-100 layout-wrap layout-align-center-center">
                    {this.state.routeSet ? dayPickerSection : '' }
                </div>
                <div className="layout-row flex-100 layout-wrap">
                    {this.state.routeSet ? mapBox : rSelect}
                </div>
                <div
                    className={`layout-row flex-100 layout-wrap ${
                        styles.cargo_sec
                    }`}
                >
                    {this.state.routeSet ? cargoDetails : ''}
                </div>
                <div className={'layout-row flex-100 layout-wrap layout-align-center-center ' + defaults.border_divider}>
                    <div
                        className={`${
                            styles.btn_sec
                        } layout-row ${defaults.content_width}  flex-none layout-wrap layout-align-start-start`}
                    >
                        <RoundButton
                            text="Choose from haulage options"
                            handleNext={this.handleNextStage}
                            theme={theme}
                            active
                        />
                    </div>
                </div>
                <div className={'layout-row flex-100 layout-wrap layout-align-center-center ' + defaults.border_divider}>
                    <div
                        className={`${
                            styles.btn_sec
                        } layout-row ${defaults.content_width}  flex-none layout-wrap layout-align-start-start`}
                    >
                        <RoundButton
                            text="Back to Dashboard"
                            handleNext={this.returnToDashboard}
                            iconClass="fa-angle-left"
                            theme={theme}
                            back
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

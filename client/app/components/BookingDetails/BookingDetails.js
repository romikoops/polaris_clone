import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './BookingDetails.scss';
import defaults from '../../styles/default_classes.scss';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
import { ContactSetter } from '../ContactSetter/ContactSetter';
// import { ShipmentSummaryBox } from '../ShipmentSummaryBox/ShipmentSummaryBox';
import { CargoDetails } from '../CargoDetails/CargoDetails';
import { RoundButton } from '../RoundButton/RoundButton';
import { history } from '../../helpers';
import { isEmpty } from '../../helpers/objectTools';
import * as Scroll from 'react-scroll';
import Formsy from 'formsy-react';
// import { TextHeading }  from '../TextHeading/TextHeading';
// import { gradientTextGenerator } from '../../helpers';
export class BookingDetails extends Component {
    constructor(props) {
        super(props);
        this.newContactData = {
            contact: {
                companyName: '',
                firstName: '',
                lastName: '',
                email: '',
                phone: ''
            },
            location: {
                street: '',
                streetNumber: '',
                zipCode: '',
                city: '',
                country: ''
            }
        };

        this.state = {
            addressBook: false,
            acceptTerms: false,
            consignee: {},
            shipper: {},
            notifyees: [],
            insurance: {
                bool: false,
                val: 0
            },
            customs: {
                bool: false,
                val: 0
            },
            hsCodes: {},
            totalGoodsValue: 0,
            cargoNotes: '',
            finishBookingAttempted: false
        };
        this.removeNotifyee = this.removeNotifyee.bind(this);
        this.toNextStage = this.toNextStage.bind(this);
        this.handleInvalidSubmit = this.handleInvalidSubmit.bind(this);
        this.handleCargoInput = this.handleCargoInput.bind(this);
        this.handleInsurance = this.handleInsurance.bind(this);
        this.calcInsurance = this.calcInsurance.bind(this);
        this.setHsCode = this.setHsCode.bind(this);
        this.deleteCode = this.deleteCode.bind(this);
        this.toggleAcceptTerms = this.toggleAcceptTerms.bind(this);
        this.setCustomsFee = this.setCustomsFee.bind(this);
        this.setContact = this.setContact.bind(this);
    }
    componentDidMount() {
        const {prevRequest, setStage, hideRegistration} = this.props;
        if (prevRequest && prevRequest.shipment) {
            this.loadPrevReq(prevRequest.shipment);
        }
        hideRegistration();
        setStage(4);
        window.scrollTo(0, 0);
    }
    scrollTo(target, offset) {
        Scroll.scroller.scrollTo(target, {
            duration: 2000,
            smooth: true,
            offset: offset || 0
        });
    }
    loadPrevReq(obj) {
        this.setState({
            consignee: obj.consignee,
            shipper: obj.shipper,
            notifyees: obj.notifyees,
            hsCode: obj.hsCode,
            totalGoodsValue: obj.totalGoodsValue,
            cargoNotes: obj.cargoNotes
        });
    }
    toggleAcceptTerms() {
        this.setState({ acceptTerms: !this.state.acceptTerms });
        // this.props.handleInsurance();
    }
    setHsCode(id, codes) {
        let exCodes;
        if (this.state.hsCodes[id]) {
            exCodes = [...this.state.hsCodes[id], ...codes];
        } else {
            exCodes = codes;
        }
        this.setState({
            hsCodes: {
                ...this.state.hsCodes,
                [id]: exCodes
            }
        });
    }
    deleteCode(cargoId, code) {
        const codes = this.state.hsCodes[cargoId];
        const newCodes = codes.filter(x => x !== code );
        this.setState({
            hsCodes: {
                ...this.state.hsCodes,
                [cargoId]: newCodes
            }
        });
    }
    handleInsurance() {
        const {insurance} = this.state;

        if (insurance.bool) {
            this.setState({insurance: {bool: false, val: 0}});
        } else {
            this.calcInsurance();
        }
    }
    calcInsurance(val) {
        const gVal = val ? val : parseInt(this.state.totalGoodsValue, 10);

        const {shipmentData} = this.props;
        const iVal = ((gVal * 1.1) + parseFloat(shipmentData.shipment.total_price, 10)) * 0.0017;
        this.setState({insurance: {bool: true, val: iVal}});
    }
    removeNotifyee(i) {
        const { notifyees } = this.state;
        notifyees.splice(i, 1);
        this.setState({ notifyees });
    }
    handleCargoInput(event) {
        const { name, value } = event.target;
        if (name === 'totalGoodsValue') {
            const gVal = parseInt(value, 10);
            this.setState({ [name]: gVal });
            this.calcInsurance(gVal);
        } else {
            this.setState({ [name]: value });
        }
    }
    orderTotal() {
        const { shipmentData } = this.props;
        const { customs, insurance } = this.state;
        return (parseFloat(shipmentData.shipment.total_price, 10) + customs.val + insurance.val);
    }
    setCustomsFee(fee) {
        this.setState({customs: fee});
    }
    pushUpData() {}

    saveDraft() {}

    toDashboard() {
        history.push('/dashboard');
    }
    toNextStage() {
        const {
            consignee,
            shipper,
            notifyees,
            hsCodes,
            totalGoodsValue,
            cargoNotes,
            insurance,
            customs
        } = this.state;

        if ([shipper, consignee].some(isEmpty)) {
            this.scrollTo('contact_setter');
            this.setState({ finishBookingAttempted: true });
            return;
        }
        const data = {
            shipment: {
                id: this.props.shipmentData.shipment.id,
                consignee,
                shipper,
                notifyees,
                hsCodes,
                totalGoodsValue,
                cargoNotes,
                insurance,
                customs
            }
        };
        this.props.nextStage(data);
    }
    handleInvalidSubmit() {
        this.setState({ finishBookingAttempted: true });

        const { shipper, consignee } = this.state;
        if ([shipper, consignee].some(isEmpty)) {
            this.scrollTo('contact_setter');
            return;
        }
        this.scrollTo('totalGoodsValue', -50);
    }
    setContact(contactData, type, index) {
        if (type === 'notifyee') {
            const notifyees = this.state.notifyees;
            notifyees[index] = contactData;
            this.setState({ notifyees });
        } else {
            this.setState({ [type]: contactData });
        }
    }

    backToDashboard(e) {
        e.preventDefault();
        this.props.shipmentDispatch.toDashboard();
    }
    render() {
        const { theme, shipmentData, shipmentDispatch, currencies, user } = this.props;
        const {
            shipment,
            hubs,
            contacts,
            userLocations,
            schedules,
            // containers,
            // cargoItems,
            // locations
        } = shipmentData;
        const { consignee, shipper, notifyees, customs } = this.state;

        return (

            <div className="flex-100 layout-row layout-wrap layout-align-center-start">
                {shipment && theme && hubs ? (
                    <RouteHubBox hubs={hubs} route={schedules} theme={theme} />
                ) : (
                    ''
                )}
                <div className={`${styles.wrapper_contact_setter} flex-100 layout-row`}>
                    <ContactSetter
                        contacts={contacts}
                        userLocations={userLocations}
                        shipper={shipper}
                        consignee={consignee}
                        notifyees={notifyees}
                        setContact={this.setContact}
                        theme={theme}
                        removeNotifyee={this.removeNotifyee}
                        finishBookingAttempted={this.state.finishBookingAttempted}
                    />
                </div>
                <Formsy
                    onValidSubmit={this.toNextStage}
                    onInvalidSubmit={this.handleInvalidSubmit}
                >
                    <CargoDetails
                        theme={theme}
                        handleChange={this.handleCargoInput}
                        shipmentData={shipmentData}
                        hsCodes={this.state.hsCodes}
                        setHsCode={this.setHsCode}
                        deleteCode={this.deleteCode}
                        cargoNotes={this.state.cargoNotes}
                        totalGoodsValue={this.state.totalGoodsValue}
                        handleInsurance={this.handleInsurance}
                        insurance={this.state.insurance}
                        shipmentDispatch={shipmentDispatch}
                        currencies={currencies}
                        customsData={customs}
                        setCustomsFee={this.setCustomsFee}
                        user={user}
                        finishBookingAttempted={this.state.finishBookingAttempted}
                    />
                    <div className={`${styles.btn_sec} flex-100 layout-row layout-wrap layout-align-center`}>
                        <div className={defaults.content_width + ' flex-none  layout-row layout-wrap layout-align-start-center'}>
                            <div className="flex-50 layout-row layout-align-start-center">
                            </div>
                            <div className="flex-50 layout-row layout-align-end-center">
                                <div className="flex-none layout-row">
                                    <RoundButton
                                        theme={theme}
                                        text="Review Booking"
                                        active
                                    />
                                </div>
                            </div>
                        </div>
                    </div>
                    <hr className={`${styles.sec_break} flex-100`}/>
                    <div className={`${styles.back_to_dash_sec} flex-100 layout-row layout-wrap layout-align-center`}>
                        <div className={`${defaults.content_width} flex-none content-width layout-row layout-align-start-center`}>
                            <RoundButton theme={theme} text="Back to dashboard" back iconClass="fa-angle-left" handleNext={this.backToDashboard}/>
                        </div>
                    </div>
                </Formsy>
            </div>
        );
    }
}

BookingDetails.propTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    nextStage: PropTypes.func
};

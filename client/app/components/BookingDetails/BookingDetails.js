import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './BookingDetails.scss';
import defaults from '../../styles/default_classes.scss';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
import { ContactSetter } from '../ContactSetter/ContactSetter';
import { ShipmentSummaryBox } from '../ShipmentSummaryBox/ShipmentSummaryBox';
import { CargoDetails } from '../CargoDetails/CargoDetails';
import { RoundButton } from '../RoundButton/RoundButton';
import { history } from '../../helpers';
import { Checkbox } from '../Checkbox/Checkbox';
import { isEmpty } from '../../helpers/objectTools';
import * as Scroll from 'react-scroll';

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
        this.toggleAddressBook = this.toggleAddressBook.bind(this);
        this.toNextStage = this.toNextStage.bind(this);
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
    scrollTo(target) {
        Scroll.scroller.scrollTo(target, {
            duration: 2000,
            smooth: true
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
        if (this.state.insurance) {
            const iVal = ((gVal * 1.1) + parseFloat(shipmentData.shipment.total_price, 10)) * 0.0017;
            // const finalVal = iVal > 22.13 ? iVal : 22.13;
            console.log(iVal);
            this.setState({insurance: {bool: true, val: iVal}});
        }
    }

    toggleAddressBook() {
        const addressBool = this.state.addressBook;
        this.setState({ addressBook: !addressBool });
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
    setContact(contactData, type, index) {
        if (type === 'notifyee') {
            const notifyees = this.state.notifyees;
            notifyees[index] = contactData;
            this.setState({ notifyees });
        } else {
            this.setState({ [type]: contactData });
        }
    }

    closeBook() {
        this.setState({ addressBook: false });
    }

    render() {
        const { theme, shipmentData, shipmentDispatch, currencies, user } = this.props;
        const {
            shipment,
            hubs,
            contacts,
            userLocations,
            schedules,
            containers,
            cargoItems,
            locations
        } = shipmentData;
        console.log('contacts');
        console.log(contacts);
        const { consignee, shipper, notifyees, acceptTerms, customs } = this.state;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const acceptedBtn = (
            <div className="flex-none layout-row">
                <RoundButton
                    handleNext={this.toNextStage}
                    theme={theme}
                    text="Finish Booking"
                    active
                />
            </div>
        );
        const nonAcceptedBtn = (
            <div className="flex-none layout-row">
                <RoundButton
                    theme={theme}
                    text="Finish Booking"
                />
            </div>
        );
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
                />
                <div className={`${styles.btn_sec} flex-100 layout-row layout-wrap layout-align-center`}>
                    <div className={`content_width flex-none  layout-row layout-wrap layout-align-center-center ${styles.summary_container}`}>
                        <div className="flex-100 layout-row layout-align-start-center">
                            <h3 className="flex-none clip" style={textStyle}>Summary: </h3>
                        </div>
                        <div className="flex-90 layout-row layout-align-start-center">
                            {shipment && theme && hubs ? (
                                <ShipmentSummaryBox total={this.orderTotal()} user={user} hubs={hubs} route={schedules} theme={theme} shipment={shipment} locations={locations} cargoItems={cargoItems} containers={containers} />
                            ) : (
                                ''
                            )}
                        </div>
                    </div>
                </div>
                <div className={`${styles.btn_sec} flex-100 layout-row layout-wrap layout-align-center`}>
                    <div className={defaults.content_width + ' flex-none  layout-row layout-wrap layout-align-start-center'}>
                        <div className="flex-50 layout-row layout-align-start-center">
                            <div className="flex-15 layout-row layout-align-center-center">
                                <Checkbox onChange={this.toggleAcceptTerms} checked={this.state.insuranceView} theme={theme} />
                            </div>
                            <div className="flex layout-row layout-align-start-center">
                                <div className="flex-5"></div>
                                <p className="flex-95">By checking this box you agree to the Terms and Conditions of {this.props.tenant.data.name}</p>
                            </div>
                        </div>
                        <div className="flex-50 layout-row layout-align-end-center">
                            { acceptTerms ? acceptedBtn : nonAcceptedBtn}
                        </div>
                    </div>
                </div>
                <hr className={`${styles.sec_break} flex-100`}/>
                <div className={`${styles.back_to_dash_sec} flex-100 layout-row layout-wrap layout-align-center`}>
                    <div className={`${defaults.content_width} flex-none content-width layout-row layout-align-start-center`}>
                        <RoundButton theme={theme} text="Back to dashboard" back iconClass="fa-angle-left" handleNext={() => shipmentDispatch.toDashboard()}/>
                    </div>
                </div>
            </div>
        );
    }
}

BookingDetails.propTypes = {
    theme: PropTypes.object,
    shipmentData: PropTypes.object,
    nextStage: PropTypes.func
};

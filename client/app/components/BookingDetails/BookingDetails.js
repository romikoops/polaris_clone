import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './BookingDetails.scss';
import defaults from '../../styles/default_classes.scss';
import { RouteHubBox } from '../RouteHubBox/RouteHubBox';
import { AddressBook } from '../AddressBook/AddressBook';
import { ShipmentSummaryBox } from '../ShipmentSummaryBox/ShipmentSummaryBox';
import { ShipmentContactsBox } from '../ShipmentContactsBox/ShipmentContactsBox';
import { CargoDetails } from '../CargoDetails/CargoDetails';
import { RoundButton } from '../RoundButton/RoundButton';
import { history } from '../../helpers';
import { Checkbox } from '../Checkbox/Checkbox';

export class BookingDetails extends Component {
    constructor(props) {
        super(props);
        this.state = {
            addressBook: false,
            acceptTerms: false,
            consignee: {
                firstName: '',
                lastName: '',
                email: '',
                phone: '',
                street: '',
                number: '',
                zipCode: '',
                city: '',
                country: ''
            },
            shipper: {
                firstName: '',
                lastName: '',
                email: '',
                phone: '',
                street: '',
                number: '',
                zipCode: '',
                city: '',
                country: ''
            },
            notifyees: [],
            default: {
                contact: {
                    firstName: '',
                    lastName: '',
                    email: '',
                    phone: '',
                    street: '',
                    number: '',
                    zipCode: '',
                    city: '',
                    country: ''
                },
                notifyee: {
                    firstName: '',
                    lastName: '',
                    email: '',
                    phone: ''
                }
            },
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
            cargoNotes: ''
        };
        this.addNotifyee = this.addNotifyee.bind(this);
        this.removeNotifyee = this.removeNotifyee.bind(this);
        this.setFromBook = this.setFromBook.bind(this);
        this.handleInput = this.handleInput.bind(this);
        this.handleNotifyeeInput = this.handleNotifyeeInput.bind(this);
        this.toggleAddressBook = this.toggleAddressBook.bind(this);
        this.toNextStage = this.toNextStage.bind(this);
        this.handleCargoInput = this.handleCargoInput.bind(this);
        this.handleInsurance = this.handleInsurance.bind(this);
        this.calcInsurance = this.calcInsurance.bind(this);
        this.setHsCode = this.setHsCode.bind(this);
        this.deleteCode = this.deleteCode.bind(this);
        this.toggleAcceptTerms = this.toggleAcceptTerms.bind(this);
        this.setCustomsFee = this.setCustomsFee.bind(this);
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
    setFromBook(target, value) {
        if (target === 'notifyee') {
            this.setNotifyeesFromBook(target, value);
        } else {
            this.setState({
                [target]: {
                    firstName: value.contact.first_name,
                    companyName: value.contact.company_name,
                    lastName: value.contact.last_name,
                    email: value.contact.email,
                    phone: value.contact.phone,
                    street: value.location.street,
                    number: value.location.street_number,
                    zipCode: value.location.zip_code,
                    city: value.location.city,
                    country: value.location.country
                }
            });
        }
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

    setNotifyeesFromBook(target, value) {
        const tmpAdd = {
            firstName: value.contact.first_name,
            lastName: value.contact.last_name,
            email: value.contact.email,
            phone: value.contact.phone
        };
        const notifyees = this.state.notifyees;
        if (notifyees.indexOf(tmpAdd) > -1) {
            notifyees.slice(notifyees.indexOf(tmpAdd), 1);
            this.setState({notifyees});
        } else {
            notifyees.push(tmpAdd);
            this.setState({notifyees});
        }
    }

    toggleAddressBook() {
        const addressBool = this.state.addressBook;
        this.setState({ addressBook: !addressBool });
    }

    addNotifyee() {
        const prevArr = Object.assign([], this.state.notifyees);
        prevArr.push(Object.assign({}, this.state.default.notifyee));
        this.setState({ notifyees: prevArr });
    }

    removeNotifyee(not) {
        const prevArr = this.state.notifyees;
        const newArr = prevArr.filter(n => n !== not);
        console.log(newArr);
        this.setState({ notifyees: newArr });
    }

    handleInput(event) {
        const { name, value } = event.target;
        const targetKeys = name.split('-');
        this.setState({
            [targetKeys[0]]: {
                ...this.state[targetKeys[0]],
                [targetKeys[1]]: value
            }
        });
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

    handleNotifyeeInput(event) {
        const { name, value } = event.target;
        console.log(name, value);
        const targetKeys = name.split('-');
        const ind = parseInt(targetKeys[1], 10);
        console.log(ind);
        const notifyees = this.state.notifyees;
        console.log(notifyees);
        notifyees[ind][targetKeys[2]] = value;
        console.log(notifyees);
        this.setState({
            notifyees: notifyees
        });
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
        const { consignee, shipper, notifyees, acceptTerms, customs } = this.state;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const aBook = (
            <AddressBook
                contacts={contacts}
                userLocations={userLocations}
                theme={theme}
                setDetails={this.setFromBook}
                closeAddressBook={this.toggleAddressBook}
            />
        );
        const cForm = (
            <ShipmentContactsBox
                consignee={consignee}
                shipper={shipper}
                addNotifyee={this.addNotifyee}
                notifyees={notifyees}
                theme={theme}
                toggleAddressBook={this.toggleAddressBook}
                handleChange={this.handleInput}
                removeNotifyee={this.removeNotifyee}
                handleNotifyeeChange={this.handleNotifyeeInput}
            />
        );
        const acceptedBtn = (<div className="flex-none layout-row">
            <RoundButton
                active
                handleNext={this.toNextStage}
                theme={theme}
                text="Finish Booking"
            />
        </div>);
        const nonAcceptedBtn = (<div className="flex-none layout-row">
            <RoundButton
                theme={theme}
                text="Finish Booking"
            />
        </div>);
        const addrView = this.state.addressBook ? aBook : cForm;
        return (
            <div className="flex-100 layout-row layout-wrap layout-align-center-start">

                {shipment && theme && hubs ? (
                    <RouteHubBox hubs={hubs} route={schedules} theme={theme} />
                ) : (
                    ''
                )}
                <div className={` ${styles.contacts_border} flex-100 layout-row`}>
                    {addrView}
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

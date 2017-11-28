import React, {Component} from 'react';
import PropTypes from 'prop-types';
import styles from './AddressBook.scss';
import { v4 } from 'node-uuid';
import { Checkbox } from '../Checkbox/Checkbox';
import { RoundButton } from '../RoundButton/RoundButton';
export class AddressBook extends Component {
    constructor(props) {
        super(props);
        // const ntfy = {};
        // if (this.props.contacts) {
        //     this.props.contacts.forEach(c=>{
        //         ntfy[c.contact.id] = false;
        //     });
        // }
        this.state = {
            setShipper: true,
            setConsignee: false,
            setNotifyees: false,
            selectedNotifyees: {}
        };
        this.setContact = this.setContact.bind(this);
    }
    toggleNotifyees(id) {
        this.setState({ selectedNotifyees: { ...this.state.selectedNotifyees, [id]: !this.state.selectedNotifyees[id] } });
    }
    setContact(type, val) {
        this.props.setDetails(type, val);
        switch(type) {
            case 'shipper':
                this.setState({
                    setShipper: false,
                    setConsignee: true
                });
                break;
            case 'consignee':
                this.setState({
                    setShipper: false,
                    setConsignee: false,
                    setNotifyees: true
                });
                break;
            default:
                break;
        }
    }

    render() {
        const { contacts, userLocations, theme } = this.props;
        const shipperOptions = [...userLocations, ...contacts];
        const contactsArray = [];
        const shipperArray = [];
        const notifyeeArray = [];
        if (contacts) {
            contacts.forEach(c => {
                contactsArray.push(
                    <div key={v4()} className={`flex-100 layout-row ${styles.contact_card}`} onClick={() => this.setContact('consignee', c)} >
                        <div className="flex-20 layout-row layout-align-center-start">
                            <i className="fa fa-user-circle-o flex-none"></i>
                        </div>
                        <div className="flex-80 layout-row layout-wrap">
                            <div className="flex-100 layout-row layout-align-start-center">
                                <p className={`flex-none ${styles.contact_header}`}> {c.contact.first_name} {c.contact.last_name} </p>
                            </div>
                            <div className={`flex-100 layout-row layout-align-start-center ${styles.contact_details}`}>
                                <div className="flex-50 layout-row layout-align-start-center">
                                    <i className="fa fa-email flex-none"></i>
                                    <p className="flex-none"> {c.contact.email} </p>
                                </div>
                                 <div className="flex-50 layout-row layout-align-start-center">
                                    <i className="fa fa-phone flex-none"></i>
                                    <p className="flex-none"> {c.contact.phone} </p>
                                </div>
                            </div>
                            <div className="flex-100 layout-row layout-align-start-center">
                                <p className="flex-100"> {c.location.geocoded_address}</p>
                            </div>
                        </div>
                    </div>
                );
                notifyeeArray.push(
                    <div key={v4()} className={`flex-100 layout-row ${styles.contact_card}`}>
                        <div className="flex-15 layout-row layout-align-center-start">
                            <i className="fa fa-user-circle-o flex-none"></i>
                        </div>
                        <div className="flex-75 layout-row layout-wrap">
                            <div className="flex-100 layout-row layout-align-start-center">
                                <p className={`flex-none ${styles.contact_header}`}> {c.contact.first_name} {c.contact.last_name} </p>
                            </div>
                            <div className={`flex-100 layout-row layout-align-start-center ${styles.contact_details}`}>
                                <div className="flex-50 layout-row layout-align-start-center">
                                    <i className="fa fa-email flex-none"></i>
                                    <p className="flex-none"> {c.contact.email} </p>
                                </div>
                                 <div className="flex-50 layout-row layout-align-start-center">
                                    <i className="fa fa-phone flex-none"></i>
                                    <p className="flex-none"> {c.contact.phone} </p>
                                </div>
                            </div>
                            <div className="flex-100 layout-row layout-align-start-center">
                                <p className="flex-100"> {c.location.geocoded_address}</p>
                            </div>
                            <div className="flex-15 layout-row layout-align-center-center">
                               <Checkbox onChange={this.toggleNotifyees} checked={this.state.selectedNotifyees[c.contact.id]}/>
                            </div>
                        </div>
                    </div>
                );
            });
        }

        if (shipperOptions) {
            shipperOptions.forEach(c => {
                shipperArray.push(
                    <div key={v4()} className={`flex-100 layout-row ${styles.contact_card}`} onClick={() => this.setContact('shipper', c)}>
                        <div className="flex-20 layout-row layout-align-center-start">
                            <i className="fa fa-user-circle-o flex-none"></i>
                        </div>
                        <div className="flex-80 layout-row layout-wrap">
                            <div className="flex-100 layout-row layout-align-start-center">
                                <p className={`flex-none ${styles.contact_header}`}> {c.contact.first_name} {c.contact.last_name} </p>
                            </div>
                            <div className={`flex-100 layout-row layout-align-start-center ${styles.contact_details}`}>
                                <div className="flex-50 layout-row layout-align-start-center">
                                    <i className="fa fa-email flex-none"></i>
                                    <p className="flex-none"> {c.contact.email} </p>
                                </div>
                                 <div className="flex-50 layout-row layout-align-start-center">
                                    <i className="fa fa-phone flex-none"></i>
                                    <p className="flex-none"> {c.contact.phone} </p>
                                </div>
                            </div>
                            <div className="flex-100 layout-row layout-align-start-center">
                                <p className="flex-100"> {c.location.geocoded_address}</p>
                            </div>
                        </div>
                    </div>
                );
            });
        }
        return (
        <div className="flex-100 layout-row layout-wrap layout-align-center-start">
          <div className="flex-75 layout-row layout-wrap">
            <div className="flex-50 layout-row layout-wrap">
                {this.state.setShipper ? <h1> Set Shipper Details</h1> : ''}
                {this.state.setConsignee ? <h1> Set Consignee Details</h1> : ''}
                {this.state.setNotifyees ? <h1> Set Notifyees Details</h1> : ''}
            </div>
            <div className={`${styles.contact_scroll} flex-50 layout-row layout-wrap`}>
                {this.state.setShipper ? shipperArray : ''}
                {this.state.setConsignee ? contactsArray : ''}
                {this.state.setNotifyees ? notifyeeArray : ''}
            </div>
            <div className="flex-100 layout-row layout-align-center-center">
                <div className="content-width layout-row layout-align-end-center button_padding">
                    <RoundButton active handleNext={this.closeAddressBook} theme={theme} text="Done" />
                </div>
          </div>
          </div>
        </div>
      );
    }
}
AddressBook.PropTypes = {
    contacts: PropTypes.array,
    userLocations: PropTypes.array,
    theme: PropTypes.object,
    setDetails: PropTypes.func,
    closeAddressBook: PropTypes.func
};


// function mapStateToProps(state) {
//     const { tenant, shipment } = state;
//     const {contacts, user_locations, shipment} = shipment;
//     return {
//         contacts,
//         user_locations,
//         tenant,
//         shipment
//     };
// }

// export default withRouter(connect(mapStateToProps)(AddressBook));

import React, {Component} from 'react';
import PropTypes from 'prop-types';
import './AddressBook.scss';
import { Checkbox } from '../Checkbox/Checkbox';
export class AddressBook extends Component {
    constructor(props) {
        super(props);
        const ntfy = {};
        if (this.props.contacts) {
            this.props.contacts.forEach(c=>{
                ntfy[c.contact.id] = false;
            });
        }
        debugger;
        this.state = {
            setShipper: true,
            setConsignee: false,
            setNotifyees: false,
            selectedNotifyees: ntfy
        };
    }
    toggleNotifyees(id) {
        this.setState({ selectedNotifyees: { ...this.state.selectedNotifyees, [id]: !this.state.selectedNotifyees[id] } });
    }

    render() {
        const { contacts, userLocations, setDetails } = this.props;
        const shipperOptions = [...userLocations, ...contacts];
        const contactsArray = [];
        const shipperArray = [];
        const notifyeeArray = [];
        if (contacts) {
            contacts.forEach(c => {
                contactsArray.push(
                    <div className="flex-100 layout-row" onClick={setDetails('consignee', c)} >
                        <div className="flex-20 layout-row layout-align-center-center">
                            <i className="fa fa-user-circle-o flex-none"></i>
                        </div>
                        <div className="flex-80 layout-row layout-wrap">
                            <div className="flex-100 layout-row layout-align-start-center">
                                <h4 className="flex-none"> {c.contact.first_name} {c.contact.last_name} </h4>
                            </div>
                            <div className="flex-100 layout-row layout-align-start-center">
                                <div className="flex-50 layout-row layout-align-start-center">
                                    <i className="fa fa-email flex-none"></i>
                                    <h6 className="flex-none"> {c.contact.email} </h6>
                                </div>
                                 <div className="flex-50 layout-row layout-align-start-center">
                                    <i className="fa fa-phone flex-none"></i>
                                    <h6 className="flex-none"> {c.contact.phone} </h6>
                                </div>
                            </div>
                            <div className="flex-100 layout-row layout-align-start-center">
                                <p className="flex-100"> {c.location.geocoded_address}</p>
                            </div>
                        </div>
                    </div>
                );
                notifyeeArray.push(
                    <div className="flex-100 layout-row">
                        <div className="flex-15 layout-row layout-align-center-center">
                            <i className="fa fa-user-circle-o flex-none"></i>
                        </div>
                        <div className="flex-75 layout-row layout-wrap">
                            <div className="flex-100 layout-row layout-align-start-center">
                                <h4 className="flex-none"> {c.contact.first_name} {c.contact.last_name} </h4>
                            </div>
                            <div className="flex-100 layout-row layout-align-start-center">
                                <div className="flex-50 layout-row layout-align-start-center">
                                    <i className="fa fa-email flex-none"></i>
                                    <h6 className="flex-none"> {c.contact.email} </h6>
                                </div>
                                 <div className="flex-50 layout-row layout-align-start-center">
                                    <i className="fa fa-phone flex-none"></i>
                                    <h6 className="flex-none"> {c.contact.phone} </h6>
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
                    <div className="flex-100 layout-row" onClick={setDetails('shipper', c)}>
                        <div className="flex-20 layout-row layout-align-center-center">
                            <i className="fa fa-user-circle-o flex-none"></i>
                        </div>
                        <div className="flex-80 layout-row layout-wrap">
                            <div className="flex-100 layout-row layout-align-start-center">
                                <h4 className="flex-none"> {c.contact.first_name} {c.contact.last_name} </h4>
                            </div>
                            <div className="flex-100 layout-row layout-align-start-center">
                                <div className="flex-50 layout-row layout-align-start-center">
                                    <i className="fa fa-email flex-none"></i>
                                    <h6 className="flex-none"> {c.contact.email} </h6>
                                </div>
                                 <div className="flex-50 layout-row layout-align-start-center">
                                    <i className="fa fa-phone flex-none"></i>
                                    <h6 className="flex-none"> {c.contact.phone} </h6>
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
            <div className="flex-50 layout-row layout-wrap">
                {this.state.setShipper ? {shipperArray} : ''}
                {this.state.setConsignee ? {contactsArray} : ''}
                {this.state.setNotifyees ? {notifyeeArray} : ''}
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

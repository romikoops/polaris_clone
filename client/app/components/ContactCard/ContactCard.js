import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './ContactCard.scss';
import { v4 } from 'node-uuid';
import { Checkbox } from '../Checkbox/Checkbox';
import Truncate from 'react-truncate';

export class ContactCard extends Component {
    constructor(props) {
        super(props);
        this.state = {
            selected: false
        };
        this.toggleSelected = this.toggleSelected.bind(this);
        this.selectContact = this.selectContact.bind(this);
    }
    toggleSelected() {
        const { contactData, toggleSelect } = this.props;
        this.setState({ selected: !this.state.selected });
        toggleSelect(contactData);
    }
    selectContact() {
        const { contactData, select, target, list } = this.props;
        list ? '' : select(target, contactData);
    }
    render() {
        const { contactData, list, theme } = this.props;
        const { contact, location } = contactData;
        const iconStyle = {
            background:
                theme && theme.colors
                    ? '-webkit-linear-gradient(left, ' +
                      theme.colors.primary +
                      ',' +
                      theme.colors.secondary +
                      ')'
                    : 'black',
            paddingRight: '5px'
        };
        return (
            <div
                key={v4()}
                className={`flex-100 layout-row ${styles.contact_card}`}
                onClick={this.selectContact}
            >
                <div className="flex layout-row layout-wrap">
                    <div className="flex-100 layout-row layout-align-space-between-center">
                        <div className="flex-60 layout-row layout-align-start-start layout-wrap">
                            <div className="flex-100 layout-row alyout-align-start-center">
                                <i
                                    className="fa fa-user-circle-o flex-none"
                                    style={iconStyle}
                                />
                                <p className={`flex ${styles.contact_header}`}>
                                    {' '}
                                    {contact.first_name} {contact.last_name}{' '}
                                </p>
                            </div>
                        </div>
                        <div
                            className={`flex-40 layout-row layout-wrap layout-align-start-center ${
                                styles.contact_details
                            }`}
                        >
                            <div className="flex-100 layout-row layout-align-start-center">
                                <i
                                    className="fa fa-envelope flex-none"
                                    style={iconStyle}
                                />
                                <p className="flex-none"> {contact.email} </p>
                            </div>
                        </div>
                    </div>
                    <div className="flex-100 layout-row layout-align-space-between-center">
                        <div className="flex-60 layout-row layout-align-start-start layout-wrap">
                            <div className="flex-100 layout-row alyout-align-start-center">
                                <i
                                    className="fa fa-building-o flex-none"
                                    style={iconStyle}
                                />
                                <p className={`flex ${styles.contact_header}`}>
                                    {' '}
                                    <Truncate lines={1} >{contact.company_name} </Truncate>{}{' '}
                                </p>
                            </div>
                        </div>
                        <div
                            className={`flex-40 layout-row layout-wrap layout-align-start-center ${
                                styles.contact_details
                            }`}
                        >
                             <div className="flex-100 layout-row layout-align-start-center">
                                <i
                                    className="fa fa-phone flex-none"
                                    style={iconStyle}
                                />
                                <p className="flex-none"> {contact.phone} </p>
                            </div>
                        </div>
                    </div>
                    { location && location.geocoded_address ?
                        <div className="flex-100 layout-row layout-align-start-center">
                            <i
                                className="fa fa-globe flex-none"
                                style={iconStyle}
                            />
                            <p className="flex-100"> {location.geocoded_address}</p>
                        </div> :
                        <div className="flex-100" style={{height: '15px'}}></div>
                    }
                </div>
                {list ? (
                    <div className="flex-15 layout-row layout-align-center-center">
                        <Checkbox
                            onChange={this.toggleSelected}
                            checked={this.state.selected}
                        />
                    </div>
                ) : (
                    ''
                )}
            </div>
        );
    }
}

ContactCard.propTypes = {
    contactData: PropTypes.array,
    theme: PropTypes.object,
    select: PropTypes.func,
    list: PropTypes.bool,
    toggleSelect: PropTypes.func,
    target: PropTypes.string
};

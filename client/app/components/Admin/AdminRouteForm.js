import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Admin.scss';
import {NamedSelect} from '../NamedSelect/NamedSelect';
import '../../styles/select-css-custom.css';
import { RoundButton } from '../RoundButton/RoundButton';
import styled from 'styled-components';
export class AdminRouteForm extends Component {
    constructor(props) {
        super(props);
        this.state = {
            location: {},
            route: {
                name: '',
                startHub: '',
                endHub: ''
            },
            selectValues: {
                startHub: '',
                endHub: ''
            }
        };
        this.handleNameChange = this.handleNameChange.bind(this);
        this.handleHubChange = this.handleHubChange.bind(this);
        this.saveNewRoute = this.saveNewRoute.bind(this);
        this.excludeHubs = this.excludeHubs.bind(this);
    }

    handleNameChange(event) {
        const { value } = event;
        this.setState({
            ...this.state,
            route: {
                ...this.state.route,
                name: value
            }
        });
    }
    handleHubChange(event) {
        const { value, name, label } = event;
        const nameKey = name + 'Name';
        let inputName;
        if (name === 'endHub') {
            inputName = this.state.startHubName + ' - ' + label;
        }
        this.setState({
            ...this.state,
            route: {
                ...this.state.route,
                [name]: value,
                name: inputName
            },
            [nameKey]: label,
            selectValues: {
                ...this.state.selectValues,
                [name]: event
            }
        });
    }

    saveNewRoute() {
        const { route } = this.state;
        this.props.saveRoute(route);
        this.props.close();
    }
    excludeHubs(hubs, target) {
        const { route } = this.state;
        const check = route[target];
        const filteredHubs = hubs.filter(x => x.data.id !== check);
        return filteredHubs.map((h) => {
            return {label: h.data.name, value: h.data.id};
        });
    }

    render() {
        const  { theme, close, hubs } = this.props;
        const { route, selectValues } = this.state;
        const originHubs = hubs ? this.excludeHubs(hubs, 'startHub') : [];
        const destinationHubs = hubs ? this.excludeHubs(hubs, 'endHub') : [];
        const StyledSelect = styled(NamedSelect)`
            width: 100%;
            .Select-control {
                background-color: #F9F9F9;
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2 !important;
            }
            .Select-menu-outer {
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2;
            }
            .Select-value {
                background-color: #F9F9F9;
                border: 1px solid #F2F2F2;
            }
            .Select-option {
                background-color: #F9F9F9;
            }
        `;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        // debugger;
        return (
            <div className={`flex-none layout-align-center-center layout-row ${styles.editor_backdrop}`}>
                <div className={`flex-none ${styles.editor_fade}`} onClick={() => close()}></div>
                <div
                    className={`${
                        styles.route_form
                    } layout-row flex-none layout-wrap layout-align-center`}
                >

                    <div className={`flex-100 layout-row layout-wrap layout-align-start-start ${styles.form_padding}`}>
                        <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                            <h2 className="flex-none clip letter_3" style={textStyle}>Add a New Route</h2>
                        </div>
                        <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.form_row}`}>
                            <div className="flex-100 flex-gt-sm-50 layout-align-start-center">
                                <p className="flex-none">Origin</p>
                            </div>
                            <div className="flex-100 flex-gt-sm-50 layout-align-end-center">
                                <StyledSelect
                                    placeholder="Origin"
                                    className={styles.select}
                                    name="startHub"
                                    value={selectValues.startHub}
                                    options={originHubs}
                                    onChange={this.handleHubChange}
                                />
                            </div>
                        </div>
                        <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.form_row}`}>
                            <div className="flex-100 flex-gt-sm-50 layout-align-start-center">
                                <p className="flex-none">Destination</p>
                            </div>
                            <div className="flex-100 flex-gt-sm-50 layout-align-end-center">
                                <StyledSelect
                                    placeholder="Destination"
                                    className={styles.select}
                                    name="endHub"
                                    value={selectValues.endHub}
                                    options={destinationHubs}
                                    onChange={this.handleHubChange}
                                />
                            </div>
                        </div>
                        <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.form_row}`}>
                            <div className="flex-100 flex-gt-sm-50 layout-align-start-center">
                                <p className="flex-none">Name</p>
                            </div>
                            <div className="flex-100 flex-gt-sm-50 layout-align-end-center input_box_full">
                                <input type="text" value={route.name} onChange={this.handleNameChange} name="name"/>
                            </div>
                        </div>
                    </div>
                    <div className="flex-100 layout-row layout-wrap layout-align-end-center">
                        <div className="flex-none layout-row">
                            <RoundButton
                                theme={theme}
                                size="small"
                                text="Save Hub"
                                active
                                handleNext={this.saveNewRoute}
                                iconClass="fa-floppy"
                            />
                        </div>
                        <div className="flex-5"></div>
                    </div>
                </div>
            </div>
        );
    }
}

AdminRouteForm.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    shipment: PropTypes.object,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};


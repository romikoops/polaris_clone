import React, { Component } from 'react';
import styles from './UserAccount.scss';
// import defaults from '../../styles/default_classes.scss';
import { RoundButton } from '../RoundButton/RoundButton';

export class EditLocation extends Component {
    constructor(props) {
        super(props);

        this.state = { geocodedAddress: this.props.geocodedAddress };

        this.handleInputChange = this.handleInputChange.bind(this);
    }

    handleInputChange(event) {
        const val = event.target.value;

        this.setState({
            geocodedAddress: val
        });
    }

    render() {
        return (
            <div className="layout-row flex-100 layout-wrap">
                <h1
                    className="layout-row flex-100"
                    onClick={() => this.props.toggleActiveView('allLocations')}
                >
                    test
                </h1>

                <input
                    name="abc"
                    onChange={this.handleInputChange}
                    className={`${styles.input}`}
                    type="string"
                    placeholder="Geocoded address"
                />

                <RoundButton
                    active
                    text="Save"
                    theme={this.props.theme}
                    size="small"
                    iconClass="fa-check"
                />
            </div>
        );
    }
}

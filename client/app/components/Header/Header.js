import React, { Component } from 'react';
import Dropdown from 'react-dropdown';

import styles from './Header.scss';
import logo from '../../assets/images/logos/logo_black.png';

const options = ['one', 'two', 'three'];
const defaultOption = options[0];

export class Header extends Component {
    render() {
        return (
            <div
                className={`${
                    styles.header
                } layout-row flex-100 layout-wrap layout-align-center`}
            >
                <div className="content-width layout-row flex-none">
                    <div className="layout-row flex-50 layout-align-start-center">
                        <img src={logo} alt="" />
                    </div>
                    <div className="layout-row flex-50 layout-align-end-center">
                        <Dropdown
                            options={options}
                            onChange={this._onSelect}
                            value={defaultOption}
                            placeholder="Select an option"
                        />
                    </div>
                </div>
            </div>
        );
    }
}

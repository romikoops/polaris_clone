import React, { Component } from 'react';
import styles from './Header.scss';

export class Header extends Component {
    render() {
        return (
            <div className={`${styles.header} layout-row flex-100 layout-wrap`}>
                <div className="flex-100 button_row layout-row layout-align-end-center">
                    <div className="flex-50 buttons layout-row layout-align-end-center">
                        <div className="flex-25 layout-row layout-align-center-center">
                            <h4 className="flex-none">About Us</h4>
                        </div>
                    </div>
                    <div className="flex-20" />
                </div>
            </div>
        );
    }
}

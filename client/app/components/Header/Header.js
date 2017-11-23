import React, { Component } from 'react';
import styles from './Header.scss';


export class Header extends Component {
    render() {
        return (
            <div className={`${styles.header} layout-row flex-100 layout-wrap layout-align-center`}>
                <div className="content-width layout-row flex-none">
                    <div className="layout-row flex-50 layout-align-start-center">
                        <img src="" alt="" />
                    </div>
                    <div className="layout-row flex-50 layout-align-end-center">
                        <span>hey</span>
                    </div>
                </div>
            </div>
        );
    }
}

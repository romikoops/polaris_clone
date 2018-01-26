import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './AlertModalBody.scss';

export class AlertModalBody extends Component {
    constructor(props) {
        super(props);
        this.state = {};
    }

    render() {
        return (
            <div className="flex-100 layout row layout-align-center">
                <i
                    className={`${styles.exit_icon} fa fa-times`}
                    onClick={() => this.props.toggleAlertModal()}
                ></i>
                <div
                    className="flex-100"
                    style={{textAlign: 'justify', padding: '30px'}}
                >
                    <div className="flex-100">
                        {this.props.message}
                    </div>
                    <hr/>
                    <div className="flex-100">
                        Please Contact: &nbsp;&nbsp;
                        <a href={`mailto:${this.props.email}?subject=Dangerous Goods Request`}>
                            {this.props.email}
                        </a>
                    </div>
                </div>
            </div>
        );
    }
}

AlertModalBody.propTypes = {
    message: PropTypes.string
};

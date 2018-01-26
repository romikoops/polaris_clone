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
                    style={{padding: '20px'}}
                >
                    <div>
                        <img
                            src={this.props.logo}
                            style={{height: '50px'}}
                        />
                    </div>

                    {this.props.message}

                    <div className="flex-100 layout-row layout-align-end">
                        <div>
                            <span style={{fontSize: '10px', marginRight: '2px'}}>
                                Powered by
                            </span>
                            <img
                                src="https://assets.itsmycargo.com/assets/logos/logo_box.png"
                                style={{height: '20px', marginBottom: '-2px'}}
                            />
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}

AlertModalBody.propTypes = {
    message: PropTypes.string
};

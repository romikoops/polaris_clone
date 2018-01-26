import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import styles from './AlertModal.scss';

export class AlertModal extends Component {
    constructor(props) {
        super(props);
        this.state = {};
    }

    render() {
        return (
            <div className="flex-90" style={{textAlign: 'justify'}}>
                {this.props.message}
            </div>
        );
    }
}

AlertModal.propTypes = {
    message: PropTypes.string
};

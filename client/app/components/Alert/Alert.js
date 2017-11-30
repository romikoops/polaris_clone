import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Alert.scss';
export class Alert extends Component {

    componentDidMount() {
        this.timer = setTimeout(
      this.props.onClose,
      this.props.timeout
    );
    }

    componentWillUnmount() {
        clearTimeout(this.timer);
    }

    alertClass(type) {
        const classes = {
            error: styles.danger,
            alert: styles.warning,
            notice: styles.info,
            success: styles.success
        };
        return classes[type] || classes.success;
    }

    render() {
        const message = this.props.message;
        const alertClassName = `alert ${ this.alertClass(message.type) } fade in`;

        return(
      <div className={ alertClassName }>
        <button className="close"
          onClick={ this.props.onClose }>
          &times;
        </button>
        { message.text }
      </div>
    );
    }
}

Alert.PropTypes = {
    onClose: PropTypes.func,
    timeout: PropTypes.number,
    message: PropTypes.object.isRequired
};

Alert.defaultProps = {
    timeout: 3000
};

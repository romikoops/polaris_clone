import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Alert.scss';
import { StickyContainer, Sticky } from 'react-sticky';

export class Alert extends Component {
    constructor(props) {
        super(props);
        this.close = this.close.bind(this);
    }
    componentDidMount() {
        this.timer = setTimeout(
            this.close,
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
    close() {
        const { onClose, message } = this.props;
        onClose(message);
    }

    render() {
        const message = this.props.message;
        const alertClassName = `alert ${ this.alertClass(message.type) } fade in`;
        return(
            <StickyContainer>
                <Sticky>
                    {
                        ({
                            style,
                        }) => {
                            return (
                                <div className={ alertClassName } style={style}>
                                    <div className={styles.alert_inner_wrapper}></div>
                                    { typeof message.text === 'object' ? 'An error occurred' : message.text }
                                    <i className="fa fa-times close" onClick={ this.close }></i>
                                </div>
                            );
                        }
                    }
                </Sticky>
            </StickyContainer>
        );
    }
}

Alert.propTypes = {
    onClose: PropTypes.func,
    timeout: PropTypes.number,
    message: PropTypes.object.isRequired
};

Alert.defaultProps = {
    timeout: 5000
};

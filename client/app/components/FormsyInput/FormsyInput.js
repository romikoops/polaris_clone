import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withFormsy } from 'formsy-react';
import styles from './FormsyInput.scss';
import errorStyles from '../../styles/errors.scss';

class FormsyInput extends Component {
    constructor(props) {
        super(props);
        this.changeValue = this.changeValue.bind(this);
    }

    changeValue(event) {
        if (typeof this.props.onChange === 'function') {
            this.props.onChange(event);
        }
        // setValue() will set the value of the component, which in
        // turn will validate it and the rest of the form
        // Important: Don't skip this step. This pattern is required
        // for Formsy to work.
        this.props.setValue(event.currentTarget.value);
    }
    render() {
        // An error message is returned only if the component is invalid
        const errorMessage = this.props.getErrorMessage();
        const inputStyles = {};
        const errorHidden = !this.props.submitAttempted;
        if (!errorHidden && !this.props.isValid()) {
            inputStyles.background = 'rgba(232, 114, 88, 0.3)';
            inputStyles.borderColor = 'rgba(232, 114, 88, 0.01)';
            inputStyles.color = 'rgba(211, 104, 80, 1)';
        }
        const rawValue = this.props.getValue();
        const value = [undefined, null].includes(rawValue) ? '' : this.props.getValue().toString();
        return (
            <div className={`${styles.wrapper_input} ${this.props.wrapperClassName}`}>
                <input
                	style={inputStyles}
                    onChange={this.changeValue}
                    type={this.props.type}
                    value={value}
                    name={this.props.name}
                    disabled={this.props.disabled}
                    className={this.props.className}
                    onFocus={this.props.onFocus}
                    onBlur={this.props.onBlur}
                    placeholder={this.props.placeholder}
                />
                <span
                    className={errorStyles.error_message}
                    style={this.props.errorMessageStyles}
                >
                    {errorHidden ? '' : errorMessage}
                </span>
            </div>
        );
    }
}

export default withFormsy(FormsyInput);


FormsyInput.propTypes = {
    errorMessageStyles: PropTypes.objectOf(PropTypes.string)
};

FormsyInput.defaultProps = {
    errorMessageStyles: {}
};

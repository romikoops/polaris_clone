import React, { Component } from 'react';
import { withFormsy } from 'formsy-react';
import styles from './FormsyInput.scss';
import errorStyles from '../../styles/errors.scss';

class FormsyInput extends Component {
    constructor(props) {
        super(props);
        this.changeValue = this.changeValue.bind(this);
    }

    changeValue(event) {
        // setValue() will set the value of the component, which in
        // turn will validate it and the rest of the form
        // Important: Don't skip this step. This pattern is required
        // for Formsy to work.
        this.props.setValue(event.currentTarget.value);
    }
    render() {
        // An error message is returned only if the component is invalid
        const errorMessage = this.props.getErrorMessage();
        const inputStyles = {
            width: '100%',
            height: '100%',
            boxSizing: 'border-box'
        };
        const errorHidden = !this.props.submitAttempted;
        if (!errorHidden && !this.props.isValid()) {
            inputStyles.background = 'rgba(232, 114, 88, 0.3)';
            inputStyles.borderColor = 'rgba(232, 114, 88, 0.01)';
            inputStyles.color = 'rgba(211, 104, 80, 1)';
        }
        console.log(this.props.getValue());
        const value = this.props.getValue() !== undefined ? this.props.getValue().toString() : '';
        console.log(this.props.value);
        return (
            <div className={styles.wrapper_input}>
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
                />
                <span className={errorStyles.error_message}>{errorHidden ? '' : errorMessage}</span>
		            <style>
		                {`
		                    .has-error .help-block {
		                        display: none;
		                    }
		                `}
		            </style>
            </div>
        );
    }
}

export default withFormsy(FormsyInput);

import React, { Component } from 'react';
import { withFormsy } from 'formsy-react';
import styles from './ValidatedInputFormsy.scss';
import errorStyles from '../../styles/errors.scss';

class ValidatedInputFormsy extends Component {
    constructor(props) {
        super(props);
        this.changeValue = this.changeValue.bind(this);
        this.state = {firstRender: true};
        this.errorsHaveUpdated = false;
    }

    componentWillReceiveProps(nextProps) {
        if (nextProps.firstRenderInputs) {
            this.setState({firstRender: true});
        }
    }

    componentDidUpdate() {
        if (this.errorsHaveUpdated) return; // Break the loop if erros have updated

        const event = {target: {name: this.props.name, value: this.props.getValue()}};
        const validationPassed = this.props.isValidValue(event.target.value);

        // break out of function if validation did not pass. This assumes default state in
        // shipmentDetails has errors set to true
        if (!validationPassed) return;

        // Trigger onChange event, and flag errorsHaveUpdated as true, in order to avoid an infinite loop.
        this.props.onChange(event, !validationPassed);
        this.errorsHaveUpdated = true;
    }

    changeValue(event) {
        this.props.onChange(event, !this.props.isValidValue(event.target.value));
        this.props.setFirstRenderInputs(false);
        this.setState({firstRender: false});
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
        const ErrorVisible = this.state.firstRender && !this.props.nextStageAttempt;
        if (!ErrorVisible && !this.props.isValid()) {
            inputStyles.background = 'rgba(232, 114, 88, 0.3)';
            inputStyles.borderColor = 'rgba(232, 114, 88, 0.01)';
            inputStyles.color = 'rgba(211, 104, 80, 1)';
        }
        return (
            <div className={styles.wrapper_input}>
                <input
                	style={inputStyles}
                    onChange={this.changeValue}
                    type={this.props.type}
                    value={(this.props.getValue() || this.props.getValue().toString()) || ''}
                    name={this.props.name}
                />
                <span className={errorStyles.error_message}>{ErrorVisible ? '' : errorMessage}</span>
            </div>
        );
    }
}

export default withFormsy(ValidatedInputFormsy);

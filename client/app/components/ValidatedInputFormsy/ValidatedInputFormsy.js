import React, { Component } from 'react';
import { withFormsy } from 'formsy-react';
import styles from './ValidatedInputFormsy.scss';

class ValidatedInputFormsy extends Component {
    constructor(props) {
        super(props);
        this.changeValue = this.changeValue.bind(this);
        this.state = {firstRender: true};
    }

    // componentWillMount() {
    //     const event = {target: {name: this.props.name, value: this.props.getValue()}};
    //     this.props.onChange(event, !this.props.isValidValue(event.target.value));
    //     console.log('Will Mount');
    //     console.log(event);
    // }

    componentWillReceiveProps(nextProps) {
        if (nextProps.firstRenderInputs) {
            this.setState({firstRender: true});
            console.log('PROPS');
        }
    }

    changeValue(event) {
        console.log('CHANGED');
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
        // console.log('this.state.firstRender');
        // console.log(this.state.firstRender);
        // console.log('this.props.firstRenderInputs');
        // console.log(this.props.firstRenderInputs);
        // console.log('this.props.nextStageAttempt');
        // console.log(this.props.nextStageAttempt);
        // console.log('this.props.isValid()');
        // console.log(this.props.isValid());
        console.log('this.props.getValue()');
        console.log(this.props.getValue());
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
                    value={(this.props.getValue().toString()) || ''}
                    name={this.props.name}
                />
                <span className={styles.error_message}>{ErrorVisible ? '' : errorMessage}</span>
            </div>
        );
    }
}

export default withFormsy(ValidatedInputFormsy);

import React, { Component } from 'react';
import { withFormsy } from 'formsy-react';
import styles from './ValidatedInputFormsy.scss';

class ValidatedInputFormsy extends Component {
    constructor(props) {
        super(props);
        this.changeValue = this.changeValue.bind(this);
        this.state = {firstRender: true};
    }

    componentWillReceiveProps() {
        console.log('this.props.firstRenderInputs');
        console.log(this.props.firstRenderInputs);
        if (this.props.firstRenderInputs) this.setState({firstRender: true});
    }

    changeValue(event) {
        this.props.onChange(event);
        this.setState({firstRender: false});
        this.props.setFirstRender(false);
        // setValue() will set the value of the component, which in
        // turn will validate it and the rest of the form
        // Important: Don't skip this step. This pattern is required
        // for Formsy to work.
        this.props.setValue(event.currentTarget.value);
    }
    render() {
        console.log('this.state.firstRender');
        console.log(this.state.firstRender);
    // An error message is returned only if the component is invalid
        // console.log(this.state);
        // console.log(this.props.getValue().toString());
        // console.log(typeof this.props.getValue());
        const errorMessage = this.props.getErrorMessage();
    	// console.log(errorMessage);
        const inputStyles = {
            width: '100%',
            height: '100%',
            boxSizing: 'border-box'
        };
        if (!this.state.firstRender && errorMessage) {
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
                <span className={styles.error_message}>{this.state.firstRender ? '' : errorMessage}</span>
            </div>
        );
    }
}

export default withFormsy(ValidatedInputFormsy);

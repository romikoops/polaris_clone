import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import styles from './LoginRegistrationWrapper.scss';
import { LoginPage } from '../../containers/LoginPage/LoginPage';
import { RegistrationPage } from '../../containers/RegistrationPage/RegistrationPage';

export class LoginRegistrationWrapper extends Component {
    constructor(props) {
        super(props);
        this.state = {
            Comp: LoginPage
        };
        this.components = { LoginPage, RegistrationPage };
    }

    render() {
        const toggleComp = () => {
            const Comp = this.state.Comp === LoginPage ? RegistrationPage : LoginPage;
            this.setState({
                Comp: Comp
            });
        };
        const { initialCompName } = this.props;
    	const Comp = initialCompName ? this.components[initialCompName] : this.state.Comp;
        const compProps = this.props[Comp.WrappedComponent.name + 'Props'];
        return (
            <div>
                <div onClick={toggleComp}>Toggle</div>
                <div>
                    <Comp {...compProps} />
                </div>
            </div>
	    );
    }
}

LoginRegistrationWrapper.propTypes = {
    component: PropTypes.func
};

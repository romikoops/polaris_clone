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
    }

    render() {
        const toggleComp = () => {
            const Comp = this.state.Comp === LoginPage ? RegistrationPage : LoginPage;
            this.setState({
                Comp: Comp
            });
        };
    	const { Comp } = this.state;
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

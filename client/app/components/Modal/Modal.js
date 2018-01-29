import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Modal.scss';
import { dimentionToPx } from '../../helpers/dimentionToPx';

export class Modal extends Component {
    constructor(props) {
        super(props);
        this.state = {
            height: '0',
            windowHeight: '0',
            width: '0',
            windowWidth: '0',
            hidden: false
        };
        this.hide = this.hide.bind(this);
        this.updateDimentions = this.updateDimentions.bind(this);
        this.updatedDimentions = false;
    }

    componentDidMount() {
        this.updateDimentions();
        window.addEventListener('resize', this.updateDimentions);
    }

    componentDidUpdate() {
        if (!this.updatedDimentions) {
            this.updateDimentions();
            this.updatedDimentions = true;
        }
    }

    componentWillUnmount() {
        window.removeEventListener('resize', this.updateDimentions);
    }

    updateDimentions() {
        this.setState({
            height: this.modal.clientHeight,
            windowHeight: window.innerHeight,
            width: this.modal.clientWidth,
            windowWidth: window.innerWidth
        });
    }

    hide() {
        this.setState({
            hidden: true
        });
        this.props.parentToggle();
    }

    render() {
        if (this.state.hidden) return '';
        const width = this.props.width ? this.props.width : '40vw';
        const propsMinHeight = dimentionToPx({
            value: this.props.minHeight,
            windowHeight: this.state.windowHeight }
        );
        const minHeight = propsMinHeight || this.state.windowHeight * 0.5;
        const minTop = Math.max(this.state.windowHeight / 2 - minHeight, 100);
        const modalStyles = {
            top: Math.min(this.state.windowHeight * 0.5 - this.state.height / 2, minTop) + 'px',
            minHeight: minHeight,
            maxHeight: this.state.windowHeight * 0.9,
            width: width,
            left: `calc(50vw - ${width}/2)`,
            padding: `${this.props.horizontalPadding} ${this.props.verticalPadding}`,
            overflowY: 'auto'
        };

        return (
            <div>
		    	<div className={`${styles.modal_background} ${styles.full_size}`} onClick={this.hide}></div>

	    		<div ref={ div => { this.modal = div; } } style={modalStyles} className={`${styles.modal} layout-row layout-align-center-center`}>
	    			{this.props.component}
	    		</div>
            </div>
	    );
    }
}

Modal.propTypes = {
    component: PropTypes.object,
    parentToggle: PropTypes.func
};

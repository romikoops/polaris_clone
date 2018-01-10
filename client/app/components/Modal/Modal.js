import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './Modal.scss';

export class Modal extends Component {
    constructor(props) {
        super(props);
        this.state = {
            height: '0',
            windowHeight: '0',
            hidden: false
        };
        this.hide = this.hide.bind(this);
        this.updateHeights = this.updateHeights.bind(this);
        this.updatedHeights = false;
    }

    componentDidMount() {
        this.updateHeights();
        window.addEventListener('resize', this.updateHeights);
    }

    componentDidUpdate() {
        if (!this.updatedHeights) {
            this.updateHeights();
            this.updatedHeights = true;
        }
    }

    componentWillUnmount() {
        window.removeEventListener('resize', this.updateHeights);
    }

    updateHeights() {
        this.setState({
            height: this.modal.clientHeight,
            windowHeight: window.innerHeight
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
        const modalStyles = {
            top: Math.min(this.state.windowHeight * 0.5 - this.state.height / 2, 100) + 'px',
            minHeight: this.state.windowHeight * 0.5,
            maxHeight: this.state.windowHeight * 0.9,
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

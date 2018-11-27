import React, { PureComponent } from 'react';
import styles from './index.scss'

class ButtonSelect extends PureComponent {
  constructor(props) {
    super(props);
    this.state = { 
      showOptions: false
    }
    this.toggleOptions = this.toggleOptions.bind(this)
  }
  toggleOptions() {
    this.setState(prevState => {
      return { showOptions: !prevState.showOptions };
    });
  }
  handleClick (status) {
    if (this.state.showOptions) {
      this.toggleOptions()
    }
    this.props.onClick(status)
  }
  render() { 
    const { text, onClick, defaultValue, options, theme, wrapperStyles } = this.props
    const { showOptions } = this.state
    const  optionCards = options
      .filter(option => option.label !== text)
      .map(option => (
      <div
        className={`flex-100 layout-row layout-align-start-center pointy ${styles.option_card}`}
        onClick={() => this.handleClick(option.value)}
      >
        {option.icon ? (<div className="flex-20 layout-row layout-align-center-center">
          <i className={`fa ${option.icon} flex-none`} style={{color: option.iconColour}}/>
         </div>)
          : ''}
          <div className="flex-80 layout-row layout-align-center-center">
            <p className="flex-none">{option.label}</p>
          </div>
      </div>
    ))
    const optionsClasses = showOptions ? `${styles.options_container} ${styles.show}` : styles.options_container
    const wrapperExpanded = showOptions ? `${styles.wrapper_show} ` : ''
    const defaultOption = options.filter(option => option.label === text)[0]
    return ( 
      <div className={`flex-100 layout-row layout-row layout-wrap relative`}>
        <div className={`flex-100 layout-row layout-row layout-wrap ${wrapperStyles} ${wrapperExpanded}`}>
          <div className="flex-100 layout-row layout-align-end">
            <div
              className={`flex layout-row layout-align-center-center pointy ${styles.main_button}`}
              onClick={() => this.handleClick(defaultValue)}
            >
                {defaultOption.icon ? (<div className="flex-20 layout-row layout-align-center-center">
              <i className={`fa ${defaultOption.icon} flex-none`} style={{color: defaultOption.iconColour}}/>
            </div>)
              : ''}
              <div className="flex-80 layout-row layout-align-center-center">
            <p className="flex-none">{text.toUpperCase()}</p>
          </div>
              
            </div>
            <div
              className={`flex-none layout-row layout-align-center-center ${styles.drop_down_button}`}
              onClick={this.toggleOptions}>
              <i className="fa fa-caret-down flex-none" />
            </div>
          </div>
          <div
            className={`flex-100 layout-row layout-wrap ${optionsClasses}`}
          >
            {optionCards}
          </div>
        </div>
      </div>
     );
  }
}
 
export default ButtonSelect;
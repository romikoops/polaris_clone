import React, { PureComponent } from 'react';
import styles from './index.scss'
import LoadingSpinner from '../LoadingSpinner/LoadingSpinner';
import GradientBorder from '../GradientBorder'
import { gradientBorderGenerator } from '../../helpers';

class ButtonSelect extends PureComponent {
  constructor(props) {
    super(props);
    this.state = { 
      showOptions: false,
      requestMade: false
    }
    this.toggleOptions = this.toggleOptions.bind(this)
  }
  toggleOptions() {
    this.setState(prevState => {
      return { showOptions: !prevState.showOptions };
    });
  }
  handleClick (status) {
    this.setState({ requestMade: true  }, () => {
      if (this.state.showOptions) {
        this.toggleOptions()
      }
      this.props.onClick(status)
    })
  }
  render() { 
    const { text, defaultValue, options, wrapperStyles, gradient, theme } = this.props
    const { showOptions, requestMade } = this.state
    const gradientBorderStyle =
    theme && theme.colors
      ? gradientBorderGenerator(theme.colors.primary, theme.colors.secondary)
      : { background: 'black' }
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
    const content = [<div className="flex-100 layout-row layout-align-end">
    <div
      className={`flex layout-row layout-align-center-center pointy ${styles.main_button}`}
      onClick={() => this.handleClick(defaultValue)}
    >
        {defaultOption.icon ? (<div className="flex-20 layout-row layout-align-center-center">
        <i className={`fa ${defaultOption.icon} flex-none pointy`} style={{color: defaultOption.iconColour}}/>
      </div>)
      : ''}
      <div className="flex-80 layout-row layout-align-center-center">
        <p className="flex-none">{text.toUpperCase()}</p>
        { requestMade ? <LoadingSpinner size="extra_small" /> : '' }
      </div>
    </div>
    <div
      className={`flex-none layout-row layout-align-center-center ${styles.drop_down_button}`}
      onClick={this.toggleOptions}>
      <i className="fa fa-caret-down flex-none pointy" />
    </div>
  </div>,
  <div
    className={`flex-100 layout-row layout-wrap ${optionsClasses}`}
  >
    {optionCards}
  </div>]
    return ( 
      <div className={`flex-100 layout-row layout-row layout-wrap relative`}>
        {showOptions ? <div className={`flex-none ${styles.backdrop}`} onClick={this.toggleOptions}/> : ''}
       {gradient ?
       (<GradientBorder
        wrapperClassName={`flex-100 layout-row layout-row layout-wrap ${wrapperStyles} ${wrapperExpanded}`}
        gradient={gradientBorderStyle}
        className="layout-row flex-100 layout-align-center-center layout-wrap relative"
        content={content}
        />) : 
       (<div className={`flex-100 layout-row layout-row layout-wrap ${wrapperStyles} ${wrapperExpanded}`}>
          {content}
       </div>)
      } 
      </div>
     );
  }
}
 
export default ButtonSelect;


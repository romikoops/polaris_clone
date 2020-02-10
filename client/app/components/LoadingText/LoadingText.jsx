import React, { PureComponent } from 'react'
import './LoadingText.scss'

class LoadingText extends PureComponent {
  constructor (props) {
    super(props)

    this.state = {
      hidden: 'hidden',
      flicker: ''
    }
  }

  componentWillMount () {
    setTimeout(() => {
      this.show()
    }, 500)
  }

  show () {
    this.setState({
      hidden: '',
      flicker: 'animate-flicker'
    })
  }

  render () {
    const { text } = this.props
    const { flicker, hidden } = this.state

    return (
      <div className={`${flicker} ${hidden}`}>
        {' '}
        {text}
      </div>
    )
  }
}

export default LoadingText

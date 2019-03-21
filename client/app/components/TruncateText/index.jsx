import React, { PureComponent } from 'react'
import ReactTooltip from 'react-tooltip'
import Truncate from 'react-truncate'

class TruncateText extends PureComponent {
  constructor (props) {
    super(props)
    this.state = { isTruncated: false }
    this.onTruncate = this.onTruncate.bind(this)
  }

  onTruncate (bool) {
    this.setState({ isTruncated: bool })
  }

  render () {
    const { children, lines } = this.props
    const { isTruncated } = this.state

    return (
      <React.Fragment>
        <Truncate
          lines={lines}
          data-tip={children}
          onTruncate={this.onTruncate}
        >
          {children}
        </Truncate>

        { isTruncated ? <ReactTooltip /> : '' }
      </React.Fragment>
    )
  }
}

TruncateText.defaultProps = {
  lines: 1,
  children: ''
}

export default TruncateText

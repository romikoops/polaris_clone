import React, { Component } from 'react'
import { connect } from 'react-redux'
import 'intersection-observer'

class ScrollTracking extends Component {
  constructor (props) {
    super(props)

    this.elementRef = React.createRef()
    this.observer = new IntersectionObserver(
      this.onIntersectionObserver,
      { threshold: [0] }
    )
  }

  componentDidMount () {
    this.observer.observe(this.elementRef.current)
  }

  componentWillUnmount () {
    this.observer.unobserve(this.elementRef.current)
  }

  onIntersectionObserver = (entries) => {
    if (entries[0].isIntersecting === false) {
      return
    }

    this.observer.unobserve(this.elementRef.current)
    this.props.onChange(this.props.type)
  }

  render () {
    return <div ref={this.elementRef}></div>
  }
}

const mapDispatchToProps = dispatch => ({
  onChange: type => dispatch({ type })
})

export default connect(null, mapDispatchToProps)(ScrollTracking)

import React from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { has } from 'lodash'
import { contentActions } from '../actions'

function withContent (WrappedComponent, componentName) {
  class Klass extends React.Component {
    componentDidMount () {
      const { content, contentDispatch } = this.props

      if (!has(content, [componentName])) {
        contentDispatch.getContentForComponent(componentName)
      }
    }

    render () {
      return <WrappedComponent {...this.props} />
    }
  }
  function mapStateToProps (state) {
    const {
      content
    } = state
    const contentToRender = has(content, ['components', componentName]) ? content.components[componentName] : {}

    return {
      content: contentToRender
    }
  }
  function mapDispatchToProps (dispatch) {
    return {
      contentDispatch: bindActionCreators(contentActions, dispatch)
    }
  }

  return connect(mapStateToProps, mapDispatchToProps)(Klass)
}

export default withContent

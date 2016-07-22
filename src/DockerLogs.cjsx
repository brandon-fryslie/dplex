React = require 'react'
Stylesheet = require './Stylesheet'
_ = require 'lodash'
{ _log } = require './util'

class DockerLogs extends React.Component
  componentDidUpdate: ->
    @scrollToBottom()

  scrollToBottom: _.debounce ->
    @refs.output.setScrollPerc 100
  , 100

  render: ->
    <box
      class={ Stylesheet.focusable }
      label={ @props.label }
      ref="output"
      width="50%"
      border="line"
      mouse="true"
      keys="true"
      scrollable="true"
      content={ @props.content }
      parent={ @props.screen } />

module.exports = DockerLogs

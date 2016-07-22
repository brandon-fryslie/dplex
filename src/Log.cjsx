React = require 'react'
ContainerList = require './ContainerList'
Stylesheet = require './Stylesheet'
util = require './util'

module.exports =
  class Log extends React.Component
    componentDidMount: ->
      # register globally for convenience
      util.register_log_el @refs.log

    render: ->
      <text
        label="log"
        class={ Stylesheet.focusable }
        scrollable="true"
        mouse="true"
        keys="true"
        ref="log"
        left="80%"
        width="20%"
        border="line"
        parent={ @props.screen } />

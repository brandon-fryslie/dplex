React = require 'react'
Stylesheet = require './Stylesheet'
child_process = require 'child_process'
_ = require 'lodash'
{ _log } = require './util'

class ContainerList extends React.Component
  constructor: (props) ->
    @state =
      items: ['Loading', 'Containers']
      filterStr: ''

  componentDidMount: ->
    @refs.hostInput.setValue @props.dockerHost
    @refs.hostInput.on 'blur', =>
      if @refs.hostInput.content isnt @props.dockerHost
        @refs.hostInput.submit()
      else
        @refs.hostInput.cancel()

    @updateContainerList @props.dockerHost

  componentWillReceiveProps: (newProps) ->
    if newProps.dockerHost isnt @props.dockerHost
      @updateContainerList newProps.dockerHost

  filterItems: (items) ->
    if @state.filterStr.match /^\s*$/
      items
    else
      filterRegex = new RegExp @state.filterStr.replace(/^\s+|\s$/, '').split('').join '.{0,3}'
      items.filter (item) -> item.match filterRegex

  updateContainerList: (dockerHost) ->
    env = Object.assign {}, process.env,
      DOCKER_HOST: dockerHost
      DOCKER_API_VERSION: 1.23

    _log "Fetching containers for #{dockerHost.magenta}..."
    child_process.exec "docker ps -a --format \"{{.Names}}\"", env: env, (err, stdin, stderr) =>
      if stderr
        _log(stderr.red)
        return

      if err
        _log err.message?.red ? 'unspecified error when fetching docker containers!'
        return

      containers = stdin.split('\n').filter((s) -> !s.match /^\s*$/).map (s) -> s.replace /,.*?$/, ''
      _log "Found #{containers.length} containers on #{dockerHost.magenta}"

      @setState items: containers

  onHostFilter: (ch, key) ->
    return unless ch?

    filterStr = if key.name is 'backspace'
      @refs.hostFilter.content.substring(0, @refs.hostFilter.content.length - 1)
    else
      "#{@refs.hostFilter.content}#{ch}"

    @setState filterStr: filterStr

  render: ->
    <element
      left="50%"
      width="30%"
      height="100%">
      <textbox
        label="docker host"
        ref="hostInput"
        inputOnFocus="true"
        onSubmit={ @props.onDockerHostChange.bind(@) }
        mouse="true"
        keys="true"
        vi="true"
        height="15%"
        border="line" />
      <textbox
        label="filter hosts"
        ref="hostFilter"  gs
        inputOnFocus="true"
        onKeypress={ @onHostFilter.bind(@) }
        mouse="true"
        keys="true"
        vi="true"
        height="15%"
        top="15%"
        border="line" />
      <list
        label="docker hosts"
        class={ [Stylesheet.focusable, Stylesheet.selectable] }
        top="30%"
        height="70%"
        scrollable="true"
        ref="hostlist"
        items={ @filterItems(@state.items) }
        mouse="true"
        keys="true"
        vi="true"
        onSelect={ @props.onContainerSelect }
        border="line"
        parent={ @props.screen } />
    </element>

module.exports = ContainerList

#!/usr/bin/env coffee

_log = null

process.on 'uncaughtException', (err) ->
  _log 'got an uncaughtException'
  _log err.stack

require 'colors'
React = require 'react'
blessed = require('blessed')
{ render } = require 'react-blessed'
ContainerList = require './ContainerList'
Stylesheet = require './Stylesheet'

mexpect = require './mexpect'
_ = require 'lodash'
util = require 'util'
child_process = require 'child_process'

class App extends React.Component
  constructor: ->
    _log = @_log

    @state =
      dockerHost: 'bld-swarm-01'

  componentDidMount: ->
    for k, ref of @refs
      # ref.enableInput()
      ref.on 'click', (e) =>
        ref.focus()

  fetchDockerLogs: (list) ->
    containerName = list.content
    @_log "Fetching logs for container #{containerName.cyan}..."

    env = _.assign {}, process.env,
      DOCKER_HOST: @state.dockerHost
      DOCKER_API_VERSION: 1.23

    child_process.exec "docker logs #{containerName}", env: env, (err, stdin, stderr) =>
      @_log "Got logs for container #{containerName.cyan}"

      dockerLogs = if stdin.length is 0
        '<Empty>'
      else
        stdin

      @setState dockerLogs: dockerLogs
      @refs.output.setScrollPerc 100
      @props.screen.render()

    @props.screen.render()

  onDockerHostChange: (host) ->
    @_log "Setting DOCKER_HOST to #{host.magenta}"
    @setState dockerHost: host

  _log: (str...) ->
    if (@refs?.log)
      if @bufferedLogging.length > 0
        @_log @bufferedLogging
        @bufferedLogging = []

      strs = for s in str
        if _.isString(s) then s else util.inspect s

      @refs.log.insertBottom(strs.filter((s) -> !s.match(/^\s*$/)).join(' '))
      @refs.log.insertBottom('---')
      @refs.log.setScrollPerc 100
    else
      @bufferedLogging ?= []
      @bufferedLogging.concat str

  render: ->
    # _log 'rerender docker logs', @state.dockerLogs

    <box
      scrollable="true"
      mouse="true"
      height="100%">
      <box
        class={ Stylesheet.focusable }
        label="docker logs"
        ref="output"
        width="50%"
        border="line"
        mouse="true"
        keys="true"
        scrollable="true"
        content={ @state.dockerLogs }
        parent={ @props.screen } />
      <ContainerList
        _log={ @_log.bind(@) }
        dockerHost={ @state.dockerHost }
        onContainerSelect={ @fetchDockerLogs.bind(@) }
        onDockerHostChange={ @onDockerHostChange.bind(@) } />
      <text
        name="log"
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
    </box>

########################## create app

createApp = ->
  screen = blessed.screen
    autoPadding: true
    smartCSR: true
    title: 'dplex'
    ignoreLocked: 'C-q'

  screen.key ['C-q'], (ch, key) ->
    process.exit(0)

  screen.program.key 'S-tab', ->
    screen.focusNext()
    screen.render()
    false

  component = render(<App screen={ screen } />, screen)

createApp()

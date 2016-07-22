React = require 'react'
ContainerList = require './ContainerList'
Stylesheet = require './Stylesheet'
child_process = require 'child_process'
Log = require './Log'
util = require './util'
{ _log } = util
_ = require 'lodash'

class App extends React.Component
  constructor: ->
    @state =
      dockerHost: 'bld-swarm-01'

  componentDidMount: ->
    for k, ref of @refs
      ref.on 'click', (e) =>
        ref.focus()

  fetchDockerLogs: (list) ->
    containerName = list.content.replace(/\/cluster.*$/, '')
    _log "Fetching logs for container #{containerName.cyan}..."

    env = _.assign {}, process.env,
      DOCKER_HOST: @state.dockerHost
      DOCKER_API_VERSION: 1.23

    child_process.exec "docker logs #{containerName}", env: env, (err, stdin, stderr) =>



      dockerLogs = if stderr.length > 0
        "#{'Error:'.red} #{stderr}"
      else if stdin.length is 0
        '<Empty>'.bold
      else
        _log "Got logs for container #{containerName.cyan}"
        stdin

      @setState dockerLogs: dockerLogs
      @refs.output.setScrollPerc 100
      @props.screen.render()

    @props.screen.render()

  onDockerHostChange: (host) ->
    _log "Setting DOCKER_HOST to #{host.magenta}"
    @setState dockerHost: host

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
        dockerHost={ @state.dockerHost }
        onContainerSelect={ @fetchDockerLogs.bind(@) }
        onDockerHostChange={ @onDockerHostChange.bind(@) } />
      <Log />
    </box>

module.exports = App

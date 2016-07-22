React = require 'react'
ContainerList = require './ContainerList'
Stylesheet = require './Stylesheet'
child_process = require 'child_process'
Log = require './Log'
DockerLogs = require './DockerLogs'
util = require './util'
{ _log } = util
_ = require 'lodash'
getRawBody = require 'raw-body'

class App extends React.Component
  constructor: ->
    @streams = []
    @buffer = []

    @state =
      dockerLogs: ''
      dockerHost: 'bld-testn-01'
      containerName: ''
      isEmpty: true

  componentDidMount: ->
    for k, ref of @refs
      ref.on 'click', (e) =>
        ref.focus()

  componentWillUnmount: ->
    for stream in @streams
      stream.removeAllListeners 'data'

  appendToLog: (str) ->
    @setState
      dockerLogs: @state.dockerLogs += str
      isEmpty: false

  # Fetchs all the available data from a stream, then sets up handlers for
  # any additional data
  # TODO: close streams when component unmounts
  logFromStream: (stream, isErr = false) ->
    # save reference to destroy later
    @streams.push stream

    # have a function that aggregates data
    # have a debounce fn that activates the direct logging fn

    debouncer = _.debounce =>
      stream.pause()
      stream.removeAllListeners 'data'
      stream.on 'data', (data) =>
        @appendToLog data.toString()

      buffer = @buffer.join('')
      if isErr and buffer.length > 0
        _log "#{'Got error logs for container'.red} #{@state.containerName.cyan} of len #{buffer.length}"
      else if buffer.length > 0
        _log "Got logs for container #{@state.containerName.cyan} of len #{buffer.length}"
        
      if buffer.length > 0
        @appendToLog buffer

      # clear aggregated buffer
      @buffer = []

      stream.resume()
    , 200

    stream.on 'data', (data) =>
      @buffer.push data
      debouncer()

  fetchDockerLogs: (list) ->
    containerName = list.content.replace(/\/cluster.*$/, '')
    if containerName isnt @state.containerName
      @setState
        containerName: containerName
        dockerLogs: ''
        isEmpty: true

      _log "Fetching logs for container #{containerName.cyan}..."

      env = _.assign {}, process.env,
        DOCKER_HOST: @state.dockerHost
        DOCKER_API_VERSION: 1.23

      proc = child_process.spawn 'docker', ['logs', '-f', containerName],
        cwd: process.cwd
        env: env

      @logFromStream proc.stdout
      @logFromStream proc.stderr, true

  onDockerHostChange: (host) ->
    _log "Setting DOCKER_HOST to #{host.magenta}"
    @setState
      dockerHost: host
      dockerLogs: ''
      isEmpty: true

  render: ->
    content = if @state.isEmpty then '<Empty>'.bold else @state.dockerLogs
    label = "docker logs#{if @state.containerName.length then ": #{@state.containerName.cyan}" else ''}".yellow.bold

    <box
      height="100%">
      <DockerLogs label={ label } content={ content } />
      <ContainerList
        dockerHost={ @state.dockerHost }
        onContainerSelect={ @fetchDockerLogs.bind(@) }
        onDockerHostChange={ @onDockerHostChange.bind(@) } />
      <Log />
    </box>

module.exports = App

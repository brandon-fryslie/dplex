#!/usr/bin/env coffee

require 'colors'
React = require 'react'
blessed = require('blessed')
{ render } = require 'react-blessed'
Stylesheet = require './Stylesheet'
mexpect = require './mexpect'
_ = require 'lodash'
util = require 'util'
child_process = require 'child_process'
App = require './App'

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

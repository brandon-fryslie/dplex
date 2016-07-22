_ = require 'lodash'
util = require 'util'

LOG_EL = null

module.exports =
  # Do a hack so my logging is global
  register_log_el: (el) ->
    LOG_EL = el

  _log: (str...) ->
    if (LOG_EL)
      # if @bufferedLogging.length > 0
        # @_log @bufferedLogging
        # @bufferedLogging = []

      strs = for s in str
        if _.isString(s) then s else util.inspect s

      LOG_EL.insertBottom(strs.filter((s) -> !s.match(/^\s*$/)).join(' '))
      LOG_EL.insertBottom('---'.blue)
      LOG_EL.setScrollPerc 100
    else
      console.log.apply console, str
    #   @bufferedLogging ?= []
    #   @bufferedLogging.concat str

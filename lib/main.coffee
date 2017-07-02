{CompositeDisposable} = require('atom')

module.exports =
  config:
    toggleCustomPath:
      title: 'use custom path'
      description: 'Tells the package to use a custom path to the luajit executable.'
      type: 'boolean'
      default: false
      order: 1
    customPath:
      title: 'Custom Path'
      description: 'Sets the custom path to the luajit executable'
      type: 'string'
      default : ""
      order: 2


  activate: ->
    require('atom-package-deps').install('starbound-linter-lua');
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'starbound-linter-lua.toggleCustomPath', (toggleCustomPath) =>
      @toggleCustomPath = toggleCustomPath || false
    @subscriptions.add atom.config.observe 'starbound-linter-lua.customPath', (customPath) =>
      @customPath = customPath || ""
  deactivate: ->
    @subscriptions.dispose()
  provideLinter: ->
    helpers = require('atom-linter')
    regex = \
    '^.+?:.+?:' +
      '(?<line>\\d+):\\s+' +
      '(?<message>.+?' +
      '(?:near (?<near>.+)|$))'
    provider =
      grammarScopes: ['source.lua']
      scope: 'file'
      lintOnFly: true
      lint: (textEditor) =>
        parameters = []
        parameters.push('-bl')
        parameters.push('-') # to indicate that the input is in stdin
        execOpts =
          stdin: textEditor.getText()
          stream: 'stderr'
          allowEmptyStderr: true
        #console.log(@toggleCustomPath)
        #console.log(@customPath)
        if @toggleCustomPath
          try
            return helpers.exec( @customPath, parameters, execOpts).then (output) ->
              return helpers.parse(output, regex, filePath: textEditor.getPath()).map (error) ->
                error.type = 'Error'
                return error
          catch e
            return helpers.exec(__dirname + "\\..\\..\\..\\luajit\\luajit.exe", parameters, execOpts).then (output) ->
              return helpers.parse(output, regex, filePath: textEditor.getPath()).map (error) ->
                error.type = 'Error'
                return error
        else
          return helpers.exec(__dirname + "\\..\\..\\..\\luajit\\luajit.exe", parameters, execOpts).then (output) ->
            return helpers.parse(output, regex, filePath: textEditor.getPath()).map (error) ->
              error.type = 'Error'
              return error

{CompositeDisposable} = require('atom')

module.exports =
  activate: ->
    require('atom-package-deps').install('starbound-linter-lua');
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'starbound-linter-lua.executablePath', (executablePath) =>
      @executablePath = executablePath
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

        return helpers.exec(__dirname + "..\\..\\..\\\luajit\\luajit.exe", parameters, execOpts).then (output) ->
          return helpers.parse(output, regex, filePath: textEditor.getPath()).map (error) ->
            error.type = 'Error'
            return error

# Compiles all .coffee files from src into .js file in dest

child_process = require('child_process')

module.exports = (src, dest) ->
  console.log 'compile-coffee: starting: from', src, '->', dest
  # cmd = 'coffee -wco '+dest+' '+src
  # coffee = child_process.spawn 'coffee'+' -wco'+dest+' '+src
  coffee = child_process.spawn 'coffee', ['-w', '-c', '-o', dest, src]
  
  coffee.stdout.on 'data', (data) ->
    console.log 'compile-coffee', 'stdout:', data.toString()
  
  coffee.stderr.on 'data', (data) ->
    console.log 'compile-coffee', 'stderr:', data.toString()
  
  coffee.on 'exit', (code) ->
    console.log 'compile-coffee', 'exited with code', code

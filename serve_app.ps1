$port = $args[0]
if (-not $port) { $port = 8080 }
$dir = "C:\Users\ngounou tomy\Downloads\frontend-tmp\build\web"
Set-Location -LiteralPath $dir
npx serve . -p $port --no-clipboard

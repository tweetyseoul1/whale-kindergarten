$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8321/')
$listener.Start()
Write-Host "Serving $root on http://localhost:8321/"
while ($listener.IsListening) {
    $context = $listener.GetContext()
    $path = [System.Uri]::UnescapeDataString($context.Request.Url.AbsolutePath.TrimStart('/'))
    if ([string]::IsNullOrEmpty($path)) { $path = 'whale-kindergarten.html' }
    $file = Join-Path $root $path
    $response = $context.Response
    if (Test-Path $file -PathType Leaf) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        switch ([System.IO.Path]::GetExtension($file).ToLower()) {
            '.html' { $response.ContentType = 'text/html; charset=utf-8' }
            '.js'   { $response.ContentType = 'application/javascript; charset=utf-8' }
            '.css'  { $response.ContentType = 'text/css; charset=utf-8' }
            '.png'  { $response.ContentType = 'image/png' }
            '.jpg'  { $response.ContentType = 'image/jpeg' }
            '.jpeg' { $response.ContentType = 'image/jpeg' }
            '.webp' { $response.ContentType = 'image/webp' }
            '.svg'  { $response.ContentType = 'image/svg+xml' }
            default { $response.ContentType = 'application/octet-stream' }
        }
        $response.ContentLength64 = $bytes.Length
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $response.StatusCode = 404
    }
    $response.Close()
}

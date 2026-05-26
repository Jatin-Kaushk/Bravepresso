$port = 8093
$root = Get-Location
$mimes = @{
    '.html' = 'text/html'
    '.css'  = 'text/css'
    '.js'   = 'application/javascript'
    '.png'  = 'image/png'
    '.jpg'  = 'image/jpeg'
    '.jpeg' = 'image/jpeg'
    '.svg'  = 'image/svg+xml'
    '.ico'  = 'image/x-icon'
    '.webp' = 'image/webp'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
try {
    $listener.Start()
    Write-Host "Server started at http://localhost:$port/"
    Write-Host "Root directory: $root"
    
    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            $urlPath = $request.Url.LocalPath.TrimStart('/')
            if ([string]::IsNullOrWhiteSpace($urlPath)) {
                $urlPath = 'index.html'
            }
            
            # Sanitize path to prevent directory traversal (basic)
            $urlPath = $urlPath -replace '\.\.', ''
            $filePath = Join-Path $root $urlPath
            
            if (Test-Path $filePath -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                if ($mimes.ContainsKey($ext)) {
                    $response.ContentType = $mimes[$ext]
                } else {
                    $response.ContentType = 'application/octet-stream'
                }
                
                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                $response.ContentLength64 = $bytes.Length
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
                Write-Host "$(Get-Date -Format 'HH:mm:ss') 200: $($request.Url.LocalPath)"
            } else {
                $response.StatusCode = 404
                Write-Host "$(Get-Date -Format 'HH:mm:ss') 404: $($request.Url.LocalPath)"
            }
        } catch {
            Write-Warning "Request error: $_"
        } finally {
            if ($null -ne $response) {
                $response.Close()
            }
        }
    }
} catch {
    Write-Error "Failed to start server: $_"
} finally {
    $listener.Stop()
}

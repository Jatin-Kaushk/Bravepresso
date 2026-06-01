$templates = Get-ChildItem -Path "src/templates" -Filter "*.html"
$header = Get-Content "src/components/header.html" -Raw -Encoding UTF8
$footer = Get-Content "src/components/footer.html" -Raw -Encoding UTF8
$cart = Get-Content "src/components/cart.html" -Raw -Encoding UTF8

foreach ($file in $templates) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    $content = $content.Replace("<!-- INCLUDE: header -->", $header)
    $content = $content.Replace("<!-- INCLUDE: footer -->", $footer)
    $content = $content.Replace("<!-- INCLUDE: cart -->", $cart)
    
    # Save to root folder
    $outPath = Join-Path (Get-Location) $file.Name
    Set-Content $outPath $content -Encoding UTF8
    Write-Host "Built $($file.Name)"
}
Write-Host "Build complete!"

$templates = Get-ChildItem -Path "src/templates" -Filter "*.html"
foreach ($file in $templates) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Replace header
    $content = $content -replace '(?s)<!-- ==================== HEADER ==================== -->.*?</header>', '<!-- INCLUDE: header -->'
    
    # Replace footer
    $content = $content -replace '(?s)<!-- ==================== FOOTER ==================== -->.*?</footer>', '<!-- INCLUDE: footer -->'
    
    # Replace cart
    $content = $content -replace '(?s)<!-- ==================== CART SIDEBAR ==================== -->.*?</aside>', '<!-- INCLUDE: cart -->'
    
    Set-Content $file.FullName $content -Encoding UTF8
}

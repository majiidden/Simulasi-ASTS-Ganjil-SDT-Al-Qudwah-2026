$html = [System.IO.File]::ReadAllText("index.html")

# Find the main <script> tag
$scriptStartTag = "<script>"
$scriptEndTag = "</script>"

$pos = 0
$scriptIndex = 0
while (($start = $html.IndexOf($scriptStartTag, $pos)) -ne -1) {
    $scriptIndex++
    $codeStart = $start + $scriptStartTag.Length
    $end = $html.IndexOf($scriptEndTag, $codeStart)
    if ($end -eq -1) {
        Write-Host "Script $scriptIndex has no closing tag!" -ForegroundColor Red
        break
    }
    $code = $html.Substring($codeStart, $end - $codeStart)
    $lines = $code -split "`r?`n"
    Write-Host "Script $scriptIndex has $($lines.Length) lines." -ForegroundColor Cyan
    
    # Check braces balance
    $openBrace = 0
    $openParen = 0
    $openBracket = 0
    
    $inSingleQuote = $false
    $inDoubleQuote = $false
    $inBacktick = $false
    $inLineComment = $false
    $inBlockComment = $false
    
    for ($i = 0; $i -lt $code.Length; $i++) {
        $c = $code[$i]
        $prev = if ($i -gt 0) { $code[$i-1] } else { '' }
        $next = if ($i + 1 -lt $code.Length) { $code[$i+1] } else { '' }
        
        if ($inLineComment) {
            if ($c -eq "`n") { $inLineComment = $false }
            continue
        }
        if ($inBlockComment) {
            if ($prev -eq '*' -and $c -eq '/') { $inBlockComment = $false }
            continue
        }
        if ($inSingleQuote) {
            if ($c -eq "'" -and $prev -ne "\") { $inSingleQuote = $false }
            continue
        }
        if ($inDoubleQuote) {
            if ($c -eq '"' -and $prev -ne "\") { $inDoubleQuote = $false }
            continue
        }
        if ($inBacktick) {
            if ($c -eq '`' -and $prev -ne "\") { $inBacktick = $false }
            continue
        }
        
        # Check start of comment
        if ($c -eq '/' -and $next -eq '/') { $inLineComment = $true; continue }
        if ($c -eq '/' -and $next -eq '*') { $inBlockComment = $true; continue }
        
        # Check quotes
        if ($c -eq "'") { $inSingleQuote = $true; continue }
        if ($c -eq '"') { $inDoubleQuote = $true; continue }
        if ($c -eq '`') { $inBacktick = $true; continue }
        
        # Check brackets
        if ($c -eq '{') { $openBrace++ }
        elseif ($c -eq '}') { $openBrace-- }
        elseif ($c -eq '(') { $openParen++ }
        elseif ($c -eq ')') { $openParen-- }
        elseif ($c -eq '[') { $openBracket++ }
        elseif ($c -eq ']') { $openBracket-- }
        
        if ($openBrace -lt 0) {
            Write-Host "Extra closing brace '}' found near offset $i!" -ForegroundColor Red
            break
        }
        if ($openParen -lt 0) {
            Write-Host "Extra closing paren ')' found near offset $i!" -ForegroundColor Red
            break
        }
        if ($openBracket -lt 0) {
            Write-Host "Extra closing bracket ']' found near offset $i!" -ForegroundColor Red
            break
        }
    }
    
    Write-Host "Final state for Script $scriptIndex -> Braces: $openBrace, Parens: $openParen, Brackets: $openBracket, Backtick: $inBacktick, Single: $inSingleQuote, Double: $inDoubleQuote" -ForegroundColor Yellow
    $pos = $end + $scriptEndTag.Length
}

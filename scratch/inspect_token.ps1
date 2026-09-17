$matches = Select-String -Path 'index.html' -Pattern 'SessionToken|token'
$matches | Select-Object -First 15 | ForEach-Object { "$($_.LineNumber): $($_.Line.Trim())" }

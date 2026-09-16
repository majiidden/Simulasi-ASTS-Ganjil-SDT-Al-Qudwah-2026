$matches = Select-String -Path 'Kode.gs.txt' -Pattern 'startRemedialFromPortal' -Context 2,15
if ($matches) {
    $matches | Select-Object -First 2 | ForEach-Object {
        "Line $($_.LineNumber): $($_.Line)"
        $_.Context.PostContext | ForEach-Object { "  $_" }
    }
}

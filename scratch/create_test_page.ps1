$html = [System.IO.File]::ReadAllText("index.html")
# Replace GAS template tags with dummy values for testing
$testHtml = [System.Text.RegularExpressions.Regex]::Replace($html, "<\?=[^?]*\?>", "Asia/Jakarta")

# Error catcher and GAS mocks
$mockScript = @"
<script>
window._testErrors = [];
window.addEventListener('error', function(e) {
    window._testErrors.push({msg: e.message, line: e.lineno, col: e.colno, filename: e.filename});
    var d = document.createElement('div');
    d.id = 'CONSOLE_ERROR_REPORT';
    d.style.display = 'none';
    d.textContent = JSON.stringify(window._testErrors);
    document.body ? document.body.appendChild(d) : document.documentElement.appendChild(d);
});

// Setup mock user & masterData
window.addEventListener('DOMContentLoaded', function() {
    window.currentUser = { userID: 'admin01', name: 'Administrator', role: 'Admin', token: 'mock-token' };
    window.masterData = {
        subjects: ['Matematika', 'Bahasa Indonesia', 'IPA', 'IPS', 'Bahasa Inggris'],
        classes: ['Kelas 7A', 'Kelas 7B', 'Kelas 8A', 'Kelas 8B']
    };
});

// Mock google.script.run
if (typeof google === 'undefined') {
    window.google = {};
}
if (!google.script) {
    google.script = {};
}
google.script.run = {
    _successHandler: null,
    _failureHandler: null,
    withSuccessHandler: function(fn) {
        this._successHandler = fn;
        return this;
    },
    withFailureHandler: function(fn) {
        this._failureHandler = fn;
        return this;
    },
    getExamPackageStudents: function(examId, userId, token, targetClassesParam) {
        var self = this;
        setTimeout(function() {
            var classes = (targetClassesParam || 'Kelas 7A,Kelas 7B').split(',').map(function(c) { return c.trim(); });
            var mockStudents = [
                { userID: '1001', name: 'Ahmad Dahlan', nisn: '0011223301', userClass: classes[0] || 'Kelas 7A', package: 'A' },
                { userID: '1002', name: 'Budi Santoso', nisn: '0011223302', userClass: classes[0] || 'Kelas 7A', package: 'B' },
                { userID: '1003', name: 'Citra Kirana', nisn: '0011223303', userClass: classes[0] || 'Kelas 7A', package: 'A' },
                { userID: '1004', name: 'Dewi Sartika', nisn: '0011223304', userClass: classes[1] || classes[0] || 'Kelas 7B', package: 'A' },
                { userID: '1005', name: 'Eko Prasetyo', nisn: '0011223305', userClass: classes[1] || classes[0] || 'Kelas 7B', package: 'B' },
                { userID: '1006', name: 'Fajar Nugraha', nisn: '0011223306', userClass: classes[1] || classes[0] || 'Kelas 7B', package: 'B' }
            ];
            if (self._successHandler) {
                self._successHandler({ success: true, students: mockStudents });
            }
        }, 300);
    },
    createExam: function(data, userId, token) {
        var self = this;
        setTimeout(function() {
            console.log('Mock createExam called with data:', data);
            window._lastSavedExamData = data;
            if (self._successHandler) {
                self._successHandler({ success: true, message: 'Jadwal Ujian berhasil disimpan!' });
            }
        }, 400);
    },
    updateExam: function(data, userId, token) {
        var self = this;
        setTimeout(function() {
            console.log('Mock updateExam called with data:', data);
            window._lastSavedExamData = data;
            if (self._successHandler) {
                self._successHandler({ success: true, message: 'Jadwal Ujian berhasil diperbarui!' });
            }
        }, 400);
    },
    saveExamPackageMapping: function(examId, mapping, userId, token) {
        var self = this;
        setTimeout(function() {
            if (self._successHandler) {
                self._successHandler({ success: true, message: 'Distribusi berhasil disimpan!' });
            }
        }, 300);
    },
    getTeacherAssignments: function(userId, token) {
        var self = this;
        setTimeout(function() {
            if (self._successHandler) {
                self._successHandler([
                    { subject: 'Matematika', class: 'Kelas 7A' },
                    { subject: 'Matematika', class: 'Kelas 7B' }
                ]);
            }
        }, 200);
    },
    getMasterData: function(userId, token) {
        var self = this;
        setTimeout(function() {
            if (self._successHandler) {
                self._successHandler({
                    subjects: ['Matematika', 'Bahasa Indonesia', 'IPA', 'IPS', 'Bahasa Inggris'],
                    classes: ['Kelas 7A', 'Kelas 7B', 'Kelas 8A', 'Kelas 8B']
                });
            }
        }, 200);
    }
};
</script>
"@

$testHtml = $testHtml.Replace("<head>", "<head>`n" + $mockScript)
[System.IO.File]::WriteAllText("scratch/test_page.html", $testHtml, [System.Text.Encoding]::UTF8)
Write-Host "Created scratch/test_page.html successfully"

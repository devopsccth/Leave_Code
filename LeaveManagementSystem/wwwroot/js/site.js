// Leave Management System - Site-wide JavaScript

// Auto-hide alerts after 5 seconds
document.addEventListener('DOMContentLoaded', function () {
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(alert => {
        setTimeout(() => {
            const bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        }, 5000);
    });

    // Date inputs - set min date to today
    const dateInputs = document.querySelectorAll('input[type="date"]');
    const today = new Date().toISOString().split('T')[0];
    dateInputs.forEach(input => {
        if (!input.value) {
            input.min = today;
        }
    });

    // Leave request form - calculate days
    const startDateInput = document.querySelector('input[name="StartDate"]');
    const endDateInput = document.querySelector('input[name="EndDate"]');
    const totalDaysInput = document.querySelector('input[name="TotalDays"]');

    if (startDateInput && endDateInput && totalDaysInput) {
        const calculateDays = () => {
            if (startDateInput.value && endDateInput.value) {
                const start = new Date(startDateInput.value);
                const end = new Date(endDateInput.value);
                const diffTime = Math.abs(end - start);
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
                totalDaysInput.value = diffDays;
            }
        };

        startDateInput.addEventListener('change', calculateDays);
        endDateInput.addEventListener('change', calculateDays);
    }

    // Leave type select - show remaining days
    const leaveTypeSelect = document.getElementById('leaveTypeSelect');
    if (leaveTypeSelect) {
        leaveTypeSelect.addEventListener('change', function () {
            const selectedOption = this.options[this.selectedIndex];
            const remaining = selectedOption.getAttribute('data-remaining');
            if (remaining) {
                console.log(`Remaining days: ${remaining}`);
            }
        });
    }

    // Confirm delete actions
    const deleteButtons = document.querySelectorAll('.btn-danger[type="submit"]');
    deleteButtons.forEach(button => {
        button.addEventListener('click', function (e) {
            if (!confirm('คุณแน่ใจหรือไม่ที่จะลบรายการนี้?')) {
                e.preventDefault();
            }
        });
    });

    // DataTable initialization (if jQuery DataTables is loaded)
    if (typeof $.fn.DataTable !== 'undefined') {
        $('.data-table').DataTable({
            language: {
                url: '//cdn.datatables.net/plug-ins/1.13.4/i18n/th.json'
            },
            pageLength: 25,
            responsive: true
        });
    }
});

// Export to Excel function
function exportToExcel(tableId, filename = 'export.xlsx') {
    const table = document.getElementById(tableId);
    if (!table) return;

    const wb = XLSX.utils.table_to_book(table, { sheet: "Sheet1" });
    XLSX.writeFile(wb, filename);
}

// Print function
function printPage() {
    window.print();
}

// Format date to Thai format
function formatDateThai(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('th-TH', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

// Show loading spinner
function showLoading() {
    const spinner = document.createElement('div');
    spinner.className = 'spinner-border text-primary';
    spinner.setAttribute('role', 'status');
    spinner.innerHTML = '<span class="visually-hidden">Loading...</span>';

    const overlay = document.createElement('div');
    overlay.className = 'loading-overlay';
    overlay.style.cssText = 'position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 9999;';
    overlay.appendChild(spinner);

    document.body.appendChild(overlay);
}

// Hide loading spinner
function hideLoading() {
    const overlay = document.querySelector('.loading-overlay');
    if (overlay) {
        overlay.remove();
    }
}

// ScienceBuddy Admin - Sign Out Modal (SweetAlert2)
function showSignOutModal() {
    // Ensure SweetAlert2 is loaded
    if (typeof Swal === 'undefined') {
        // Fallback if SweetAlert not loaded
        if (confirm('Are you sure you want to sign out?')) {
            window.location.href = window.location.origin + '/Logout.aspx';
        }
        return;
    }

    Swal.fire({
        html: '<div style="text-align:center;padding:8px 0;">' +
              '<div style="width:64px;height:64px;border-radius:50%;background:#FEE2E2;display:flex;align-items:center;justify-content:center;margin:0 auto 16px;"><i class="bi bi-box-arrow-right" style="font-size:1.5rem;color:#DC2626;"></i></div>' +
              '<h3 style="font-family:var(--font-primary,sans-serif);font-size:1.25rem;font-weight:700;color:#1E293B;margin-bottom:8px;">Sign Out</h3>' +
              '<p style="font-size:.9rem;color:#64748B;margin-bottom:4px;">Are you sure you want to sign out of ScienceBuddy Admin?</p>' +
              '<p style="font-size:.8rem;color:#94A3B8;">You will need to sign in again to continue managing the system.</p>' +
              '</div>',
        showCancelButton: true,
        confirmButtonText: '<i class="bi bi-box-arrow-right"></i> Sign Out',
        cancelButtonText: 'Cancel',
        confirmButtonColor: '#DC2626',
        cancelButtonColor: '#E2E8F0',
        reverseButtons: true,
        customClass: {
            popup: 'sb-signout-popup',
            confirmButton: 'sb-signout-confirm',
            cancelButton: 'sb-signout-cancel'
        },
        showClass: { popup: 'animate__animated animate__fadeIn animate__faster' },
        hideClass: { popup: 'animate__animated animate__fadeOut animate__faster' },
        backdrop: 'rgba(15,23,42,0.5)',
        allowOutsideClick: true,
        allowEscapeKey: true
    }).then(function(result) {
        if (result.isConfirmed) {
            window.location.href = window.location.pathname.replace(/\/Admin\/.*/, '') + '/Logout.aspx';
        }
    });
}

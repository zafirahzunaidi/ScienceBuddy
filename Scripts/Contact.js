/* ============================================================
   ScienceBuddy — Contact.js
   FAQ accordion + Role modal
   ============================================================ */
(function () {
    'use strict';

    // ── FAQ Accordion ──
    var faqBtns = document.querySelectorAll('.contact-faq__btn');
    faqBtns.forEach(function (btn) {
        btn.addEventListener('click', function () {
            var expanded = btn.getAttribute('aria-expanded') === 'true';
            // Close all
            faqBtns.forEach(function (b) {
                b.setAttribute('aria-expanded', 'false');
                var panel = document.getElementById(b.getAttribute('aria-controls'));
                if (panel) panel.style.maxHeight = '0';
            });
            // Open clicked if was closed
            if (!expanded) {
                btn.setAttribute('aria-expanded', 'true');
                var panel = document.getElementById(btn.getAttribute('aria-controls'));
                if (panel) panel.style.maxHeight = panel.scrollHeight + 'px';
            }
        });
    });

    // ── Role Modal ──
    var modal = document.getElementById('contactRoleModal');
    var openBtn = document.getElementById('contactGetStartedBtn');
    var closeBtn = modal ? modal.querySelector('.about-modal__close') : null;

    function openModal() {
        if (!modal) return;
        modal.classList.add('open');
        document.body.style.overflow = 'hidden';
        if (closeBtn) closeBtn.focus();
    }
    function closeModal() {
        if (!modal) return;
        modal.classList.remove('open');
        document.body.style.overflow = '';
        if (openBtn) openBtn.focus();
    }

    if (openBtn) openBtn.addEventListener('click', openModal);
    if (closeBtn) closeBtn.addEventListener('click', closeModal);
    if (modal) {
        modal.addEventListener('click', function (e) { if (e.target === modal) closeModal(); });
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && modal.classList.contains('open')) closeModal();
        });
    }
})();

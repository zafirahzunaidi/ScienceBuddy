/* ============================================================
   ScienceBuddy — About.js
   Scroll reveal, review animation, modal, visibility API
   ============================================================ */
(function () {
    'use strict';

    // ── Scroll Reveal ──
    var reveals = document.querySelectorAll('.about-reveal');
    if (reveals.length && !window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        var observer = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                    observer.unobserve(entry.target);
                }
            });
        }, { threshold: 0.15 });
        reveals.forEach(function (el) { observer.observe(el); });
    } else {
        reveals.forEach(function (el) { el.classList.add('visible'); });
    }

    // ── Review Track Pause on Hover ──
    var tracks = document.querySelectorAll('.about-reviews__track');
    tracks.forEach(function (track) {
        track.addEventListener('mouseenter', function () { track.classList.add('paused'); });
        track.addEventListener('mouseleave', function () { track.classList.remove('paused'); });
        track.addEventListener('touchstart', function () { track.classList.add('paused'); }, { passive: true });
        track.addEventListener('touchend', function () { track.classList.remove('paused'); });
    });

    // ── Pause on Tab Hidden ──
    document.addEventListener('visibilitychange', function () {
        var paused = document.hidden;
        tracks.forEach(function (track) {
            if (paused) track.classList.add('paused');
            else track.classList.remove('paused');
        });
    });

    // ── Role Modal ──
    var modal = document.getElementById('aboutRoleModal');
    var openBtn = document.getElementById('aboutGetStartedBtn');
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

    // ── Role Selection (navigate to registration pages) ──
    var roleCards = document.querySelectorAll('.about-modal__role');
    roleCards.forEach(function (card) {
        card.addEventListener('click', function () {
            // Allow default navigation — href already points to correct registration page
            closeModal();
        });
    });
})();

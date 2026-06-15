/* ============================================================
   ScienceBuddy - modal.js
   Accessible modal open/close with stacking support
   ============================================================ */

(function () {
    'use strict';

    window.ScienceBuddy = window.ScienceBuddy || {};

    var activeModals = [];   /* stack of open modals */
    var scrollBarWidth = 0;

    /* ── Measure scrollbar once ── */
    function getScrollBarWidth() {
        var div = document.createElement('div');
        div.style.cssText = 'width:99px;height:99px;overflow:scroll;position:absolute;top:-9999px';
        document.body.appendChild(div);
        var w = div.offsetWidth - div.clientWidth;
        div.remove();
        return w;
    }

    function lockScroll() {
        scrollBarWidth = getScrollBarWidth();
        document.body.style.paddingRight = scrollBarWidth + 'px';
        document.body.style.overflow = 'hidden';
    }

    function unlockScroll() {
        document.body.style.paddingRight = '';
        document.body.style.overflow = '';
    }

    /* ============================================================
       CORE OPEN / CLOSE
       ============================================================ */

    /**
     * Open a modal.
     * @param {string|HTMLElement} target - Modal overlay id or element.
     * @param {object} [options]
     *   options.onOpen  {Function}  - Callback after modal opens.
     *   options.onClose {Function}  - Callback after modal closes.
     */
    function openModal(target, options) {
        var overlay = (typeof target === 'string')
            ? document.getElementById(target)
            : target;

        if (!overlay) {
            console.warn('ScienceBuddy Modal: element not found –', target);
            return;
        }

        options = options || {};

        /* Prevent duplicate open */
        if (overlay.classList.contains('active')) return;

        overlay.classList.add('active');
        overlay.removeAttribute('hidden');
        overlay.setAttribute('aria-modal', 'true');
        overlay.setAttribute('role', 'dialog');

        /* Store callbacks */
        overlay._sbModalOptions = options;

        /* Manage focus */
        var prevFocus = document.activeElement;
        overlay._sbPrevFocus = prevFocus;

        /* Lock scroll on first modal */
        if (activeModals.length === 0) lockScroll();
        activeModals.push(overlay);

        /* Focus first focusable element */
        var focusable = getFocusable(overlay);
        if (focusable.length) {
            setTimeout(function () { focusable[0].focus(); }, 50);
        }

        /* Animate */
        overlay.style.display = 'flex';
        requestAnimationFrame(function () {
            overlay.classList.add('active');
        });

        /* Trap focus */
        overlay._sbFocusTrap = function (e) { trapFocus(e, overlay); };
        document.addEventListener('keydown', overlay._sbFocusTrap);

        /* ESC to close */
        overlay._sbEscHandler = function (e) {
            if (e.key === 'Escape') closeModal(overlay);
        };
        document.addEventListener('keydown', overlay._sbEscHandler);

        if (options.onOpen) options.onOpen(overlay);
    }

    /**
     * Close a modal.
     * @param {string|HTMLElement} target
     */
    function closeModal(target) {
        var overlay = (typeof target === 'string')
            ? document.getElementById(target)
            : target;

        if (!overlay || !overlay.classList.contains('active')) return;

        overlay.classList.remove('active');
        overlay.setAttribute('hidden', '');

        /* Remove event listeners */
        if (overlay._sbFocusTrap)  document.removeEventListener('keydown', overlay._sbFocusTrap);
        if (overlay._sbEscHandler) document.removeEventListener('keydown', overlay._sbEscHandler);

        /* Restore focus */
        if (overlay._sbPrevFocus && overlay._sbPrevFocus.focus) {
            overlay._sbPrevFocus.focus();
        }

        /* Remove from stack */
        var idx = activeModals.indexOf(overlay);
        if (idx !== -1) activeModals.splice(idx, 1);

        /* Unlock scroll if no more modals */
        if (activeModals.length === 0) unlockScroll();

        var options = overlay._sbModalOptions || {};
        if (options.onClose) options.onClose(overlay);
    }

    /** Close all open modals */
    function closeAllModals() {
        activeModals.slice().forEach(function (m) { closeModal(m); });
    }

    /** Toggle a modal open/closed */
    function toggleModal(target, options) {
        var overlay = (typeof target === 'string')
            ? document.getElementById(target)
            : target;
        if (!overlay) return;
        if (overlay.classList.contains('active')) closeModal(overlay);
        else openModal(overlay, options);
    }

    /* ============================================================
       FOCUS TRAP
       ============================================================ */
    function getFocusable(container) {
        return Array.prototype.slice.call(
            container.querySelectorAll(
                'a[href],button:not([disabled]),input:not([disabled]),' +
                'select:not([disabled]),textarea:not([disabled]),' +
                '[tabindex]:not([tabindex="-1"])'
            )
        ).filter(function (el) { return el.offsetParent !== null; });
    }

    function trapFocus(e, modal) {
        if (e.key !== 'Tab') return;
        var focusable = getFocusable(modal);
        if (!focusable.length) { e.preventDefault(); return; }

        var first = focusable[0];
        var last  = focusable[focusable.length - 1];

        if (e.shiftKey) {
            if (document.activeElement === first) {
                e.preventDefault();
                last.focus();
            }
        } else {
            if (document.activeElement === last) {
                e.preventDefault();
                first.focus();
            }
        }
    }

    /* ============================================================
       PROGRAMMATIC MODAL (create & show from JS)
       ============================================================ */

    /**
     * Create and show a modal from options.
     * @param {object} config
     *   config.id       {string}   - Optional id for the overlay.
     *   config.title    {string}   - Modal heading.
     *   config.content  {string}   - HTML content for the body.
     *   config.size     {string}   - 'sm'|'lg'|'xl' (default standard).
     *   config.footer   {string}   - HTML for footer (buttons etc.).
     *   config.onClose  {Function} - Callback on close.
     *   config.onConfirm{Function} - Callback for confirm button (if footer omitted).
     *   config.confirmText {string}- Label for confirm button.
     *   config.cancelText  {string}- Label for cancel button.
     *   config.type     {string}   - 'info'|'success'|'warning'|'danger' — adds icon tint.
     */
    function createModal(config) {
        config = config || {};

        var id = config.id || ('sb-modal-' + Date.now());

        /* Remove existing modal with same id */
        var existing = document.getElementById(id);
        if (existing) existing.remove();

        /* Size class */
        var sizeClass = '';
        if (config.size === 'sm') sizeClass = ' sb-modal-sm';
        else if (config.size === 'lg') sizeClass = ' sb-modal-lg';
        else if (config.size === 'xl') sizeClass = ' sb-modal-xl';

        /* Icon by type */
        var iconMap = {
            info:    '&#8505;',
            success: '&#10003;',
            warning: '&#9888;',
            danger:  '&#9888;',
            error:   '&#9888;'
        };
        var icon = config.type ? ('<span style="margin-right:8px">' + (iconMap[config.type] || '') + '</span>') : '';

        /* Footer HTML */
        var footerHtml = config.footer || '';
        if (!footerHtml) {
            var confirmLabel = config.confirmText || 'Confirm';
            var cancelLabel  = config.cancelText  || 'Cancel';
            var confirmClass = 'sb-btn-primary';
            if (config.type === 'danger' || config.type === 'error') confirmClass = 'sb-btn-danger';
            else if (config.type === 'warning') confirmClass = 'sb-btn-warning';
            else if (config.type === 'success') confirmClass = 'sb-btn-success';

            footerHtml = '<button type="button" class="sb-btn sb-btn-ghost sb-btn-sm" data-modal-close="' + id + '">' +
                             cancelLabel + '</button>' +
                         '<button type="button" class="sb-btn ' + confirmClass + ' sb-btn-sm" id="' + id + '-confirm">' +
                             confirmLabel + '</button>';
        }

        /* Build HTML */
        var html = '<div class="sb-modal-overlay" id="' + id + '" aria-modal="true" role="dialog" aria-labelledby="' + id + '-title" hidden>' +
                       '<div class="sb-modal' + sizeClass + '">' +
                           '<div class="sb-modal-header">' +
                               '<div class="sb-modal-title" id="' + id + '-title">' + icon + (config.title || 'Notice') + '</div>' +
                               '<button type="button" class="sb-modal-close" data-modal-close="' + id + '" aria-label="Close">&times;</button>' +
                           '</div>' +
                           '<div class="sb-modal-body">' + (config.content || '') + '</div>' +
                           (footerHtml ? '<div class="sb-modal-footer">' + footerHtml + '</div>' : '') +
                       '</div>' +
                   '</div>';

        var wrapper = document.createElement('div');
        wrapper.innerHTML = html;
        var overlay = wrapper.firstChild;
        document.body.appendChild(overlay);

        /* Wire confirm button */
        if (config.onConfirm) {
            var confirmBtn = document.getElementById(id + '-confirm');
            if (confirmBtn) {
                confirmBtn.addEventListener('click', function () {
                    config.onConfirm(overlay);
                });
            }
        }

        openModal(overlay, { onClose: config.onClose });
        return overlay;
    }

    /* ============================================================
       CONFIRM DIALOG SHORTHAND
       ============================================================ */

    /**
     * Show a confirmation dialog.
     * @param {string} message
     * @param {Function} onConfirm
     * @param {object} [options] - title, type, confirmText, cancelText
     */
    function confirm(message, onConfirm, options) {
        options = options || {};
        return createModal({
            title:       options.title || 'Are you sure?',
            content:     '<p style="font-size:.9375rem;color:var(--color-text-secondary)">' + message + '</p>',
            type:        options.type || 'warning',
            confirmText: options.confirmText || 'Yes, Confirm',
            cancelText:  options.cancelText  || 'Cancel',
            size:        options.size || 'sm',
            onConfirm:   function (overlay) {
                if (onConfirm) onConfirm();
                closeModal(overlay);
            }
        });
    }

    /**
     * Show an info/alert dialog (single OK button).
     */
    function alert(message, title, type) {
        return createModal({
            title:       title || 'Notice',
            content:     '<p style="font-size:.9375rem;color:var(--color-text-secondary)">' + message + '</p>',
            type:        type || 'info',
            size:        'sm',
            footer:      '<button type="button" class="sb-btn sb-btn-primary sb-btn-sm" data-modal-close-self>OK</button>',
            onOpen: function (overlay) {
                var btn = overlay.querySelector('[data-modal-close-self]');
                if (btn) btn.addEventListener('click', function () { closeModal(overlay); });
            }
        });
    }

    /* ============================================================
       EVENT DELEGATION — data attributes
       ============================================================ */

    function initDelegation() {
        document.addEventListener('click', function (e) {

            /* data-modal-open="targetId" */
            var openBtn = e.target.closest('[data-modal-open]');
            if (openBtn) {
                e.preventDefault();
                openModal(openBtn.getAttribute('data-modal-open'));
                return;
            }

            /* data-modal-close="targetId" */
            var closeBtn = e.target.closest('[data-modal-close]');
            if (closeBtn) {
                e.preventDefault();
                closeModal(closeBtn.getAttribute('data-modal-close'));
                return;
            }

            /* data-modal-toggle="targetId" */
            var toggleBtn = e.target.closest('[data-modal-toggle]');
            if (toggleBtn) {
                e.preventDefault();
                toggleModal(toggleBtn.getAttribute('data-modal-toggle'));
                return;
            }

            /* Click on overlay backdrop (not modal box) */
            if (e.target.classList.contains('sb-modal-overlay')) {
                /* Allow closing by clicking backdrop, unless data-modal-static */
                if (!e.target.hasAttribute('data-modal-static')) {
                    closeModal(e.target);
                }
                return;
            }
        });
    }

    /* ============================================================
       INIT
       ============================================================ */
    function init() {
        initDelegation();
    }

    function ready(fn) {
        if (document.readyState !== 'loading') fn();
        else document.addEventListener('DOMContentLoaded', fn);
    }

    ready(init);

    /* ============================================================
       PUBLIC API
       ============================================================ */
    ScienceBuddy.Modal = {
        open:        openModal,
        close:       closeModal,
        closeAll:    closeAllModals,
        toggle:      toggleModal,
        create:      createModal,
        confirm:     confirm,
        alert:       alert
    };

})();

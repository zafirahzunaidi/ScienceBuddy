/* ============================================================
   ScienceBuddy - site.js
   Core UI interactions: sidebar, tabs, dropdowns, pagination
   ============================================================ */

(function () {
    'use strict';

    /* ── DOM-ready helper ── */
    function ready(fn) {
        if (document.readyState !== 'loading') { fn(); }
        else { document.addEventListener('DOMContentLoaded', fn); }
    }

    /* ── Query helpers ── */
    var $ = function (sel, ctx) { return (ctx || document).querySelector(sel); };
    var $$ = function (sel, ctx) { return Array.prototype.slice.call((ctx || document).querySelectorAll(sel)); };

    /* ============================================================
       SIDEBAR TOGGLE
       ============================================================ */
    var ScienceBuddy = window.ScienceBuddy = window.ScienceBuddy || {};

    ScienceBuddy.Sidebar = {
        sidebar: null,
        overlay: null,
        isMobile: function () { return window.innerWidth < 768; },
        isTablet: function () { return window.innerWidth >= 768 && window.innerWidth < 1024; },

        init: function () {
            this.sidebar = $('.sb-sidebar');
            this.overlay = $('.sb-sidebar-overlay');
            if (!this.sidebar) return;

            /* Desktop / tablet toggle button */
            var toggleBtns = $$('[data-sidebar-toggle]');
            var self = this;
            toggleBtns.forEach(function (btn) {
                btn.addEventListener('click', function (e) {
                    e.stopPropagation();
                    self.toggle();
                });
            });

            /* Overlay click closes on mobile */
            if (this.overlay) {
                this.overlay.addEventListener('click', function () { self.close(); });
            }

            /* ESC key closes sidebar on mobile */
            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape' && self.isMobile()) { self.close(); }
            });

            /* Restore collapsed state from localStorage */
            if (!self.isMobile() && localStorage.getItem('sb_sidebar_collapsed') === 'true') {
                self.collapse();
            }

            /* Handle resize */
            var resizeTimer;
            window.addEventListener('resize', function () {
                clearTimeout(resizeTimer);
                resizeTimer = setTimeout(function () { self.onResize(); }, 150);
            });
        },

        open: function () {
            if (!this.sidebar) return;
            if (this.isMobile()) {
                this.sidebar.classList.add('mobile-open');
                if (this.overlay) this.overlay.classList.add('active');
                document.body.style.overflow = 'hidden';
            } else {
                this.sidebar.classList.remove('collapsed');
                var layout = $('.sb-layout-sidebar');
                if (layout) layout.classList.remove('sidebar-collapsed');
            }
        },

        close: function () {
            if (!this.sidebar) return;
            if (this.isMobile()) {
                this.sidebar.classList.remove('mobile-open');
                if (this.overlay) this.overlay.classList.remove('active');
                document.body.style.overflow = '';
            } else {
                this.collapse();
            }
        },

        collapse: function () {
            if (!this.sidebar) return;
            this.sidebar.classList.add('collapsed');
            var layout = $('.sb-layout-sidebar');
            if (layout) layout.classList.add('sidebar-collapsed');
            localStorage.setItem('sb_sidebar_collapsed', 'true');
        },

        expand: function () {
            if (!this.sidebar) return;
            this.sidebar.classList.remove('collapsed');
            var layout = $('.sb-layout-sidebar');
            if (layout) layout.classList.remove('sidebar-collapsed');
            localStorage.setItem('sb_sidebar_collapsed', 'false');
        },

        toggle: function () {
            if (!this.sidebar) return;
            if (this.isMobile()) {
                if (this.sidebar.classList.contains('mobile-open')) { this.close(); }
                else { this.open(); }
            } else {
                if (this.sidebar.classList.contains('collapsed')) { this.expand(); }
                else { this.collapse(); }
            }
        },

        onResize: function () {
            if (!this.sidebar) return;
            /* On resize to desktop, restore proper state */
            if (!this.isMobile()) {
                this.sidebar.classList.remove('mobile-open');
                if (this.overlay) this.overlay.classList.remove('active');
                document.body.style.overflow = '';
            }
        },

        /* Mark sidebar item as active based on current URL */
        markActive: function () {
            var currentPath = window.location.pathname.toLowerCase();
            $$('.sb-sidebar-item').forEach(function (item) {
                var href = (item.getAttribute('href') || '').toLowerCase();
                if (href && currentPath.indexOf(href) !== -1) {
                    item.classList.add('active');
                }
            });
        }
    };

    /* ============================================================
       TOP NAVIGATION MOBILE TOGGLE
       ============================================================ */
    ScienceBuddy.TopNav = {
        init: function () {
            var toggler = $('.sb-nav-toggler');
            var navLinks = $('.sb-topnav .sb-nav-links');
            if (!toggler || !navLinks) return;

            toggler.addEventListener('click', function (e) {
                e.stopPropagation();
                navLinks.classList.toggle('mobile-open');
                var expanded = navLinks.classList.contains('mobile-open');
                toggler.setAttribute('aria-expanded', expanded);
            });

            /* Close on outside click */
            document.addEventListener('click', function (e) {
                if (!navLinks.contains(e.target) && e.target !== toggler) {
                    navLinks.classList.remove('mobile-open');
                    toggler.setAttribute('aria-expanded', 'false');
                }
            });

            /* Mark active nav link */
            var currentPath = window.location.pathname.toLowerCase();
            $$('.sb-topnav .sb-nav-links a').forEach(function (link) {
                var href = (link.getAttribute('href') || '').toLowerCase();
                if (href && href !== '/' && currentPath.indexOf(href) !== -1) {
                    link.classList.add('active');
                }
            });
        }
    };

    /* ============================================================
       TABS
       ============================================================ */
    ScienceBuddy.Tabs = {
        init: function () {
            $$('[data-tab]').forEach(function (tabBtn) {
                tabBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    var targetId = tabBtn.getAttribute('data-tab');
                    var tabGroup = tabBtn.getAttribute('data-tab-group') || 'default';
                    ScienceBuddy.Tabs.activate(tabBtn, targetId, tabGroup);
                });
            });
        },

        activate: function (tabBtn, targetId, tabGroup) {
            /* Deactivate all tabs in the same group */
            $$('[data-tab-group="' + tabGroup + '"]').forEach(function (t) {
                t.classList.remove('active');
                t.setAttribute('aria-selected', 'false');
            });

            /* Deactivate all panes associated with this group */
            $$('[data-tab-pane-group="' + tabGroup + '"]').forEach(function (p) {
                p.classList.remove('active');
            });

            /* Activate clicked tab */
            tabBtn.classList.add('active');
            tabBtn.setAttribute('aria-selected', 'true');

            /* Activate target pane */
            var pane = document.getElementById(targetId);
            if (pane) { pane.classList.add('active'); }
        }
    };

    /* ============================================================
       DROPDOWNS
       ============================================================ */
    ScienceBuddy.Dropdown = {
        init: function () {
            /* Toggle on button click */
            $$('[data-dropdown-toggle]').forEach(function (btn) {
                btn.addEventListener('click', function (e) {
                    e.stopPropagation();
                    var targetId = btn.getAttribute('data-dropdown-toggle');
                    var menu = document.getElementById(targetId) || btn.nextElementSibling;
                    if (!menu) return;
                    var isOpen = menu.classList.contains('open');
                    /* Close all others */
                    ScienceBuddy.Dropdown.closeAll();
                    if (!isOpen) {
                        menu.classList.add('open');
                        btn.setAttribute('aria-expanded', 'true');
                    }
                });
            });

            /* Close on outside click */
            document.addEventListener('click', function () {
                ScienceBuddy.Dropdown.closeAll();
            });

            /* Close on ESC */
            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') ScienceBuddy.Dropdown.closeAll();
            });
        },

        closeAll: function () {
            $$('.sb-dropdown-menu.open').forEach(function (menu) {
                menu.classList.remove('open');
            });
            $$('[data-dropdown-toggle]').forEach(function (btn) {
                btn.setAttribute('aria-expanded', 'false');
            });
        }
    };

    /* ============================================================
       USER AVATAR MENU (nav)
       ============================================================ */
    ScienceBuddy.UserMenu = {
        init: function () {
            var userBtn = $('.sb-nav-user[data-dropdown-toggle]');
            if (userBtn) return; /* handled by Dropdown module */

            /* Fallback: simple click toggle for .sb-nav-user */
            var userBtn2 = $('.sb-nav-user');
            if (!userBtn2) return;
            var menu = userBtn2.nextElementSibling;
            if (!menu || !menu.classList.contains('sb-dropdown-menu')) return;

            userBtn2.addEventListener('click', function (e) {
                e.stopPropagation();
                menu.classList.toggle('open');
            });

            document.addEventListener('click', function () {
                menu.classList.remove('open');
            });
        }
    };

    /* ============================================================
       ACTIVE BREADCRUMB / PAGE TITLE
       ============================================================ */
    ScienceBuddy.PageTitle = {
        init: function () {
            /* Sync .sb-topheader .sb-page-title from <title> if not set */
            var titleEl = $('.sb-topheader .sb-page-title');
            if (titleEl && !titleEl.textContent.trim()) {
                var docTitle = document.title || '';
                var parts = docTitle.split('-');
                if (parts.length > 0) {
                    titleEl.textContent = parts[0].trim();
                }
            }
        }
    };

    /* ============================================================
       SEARCH BAR - clear button
       ============================================================ */
    ScienceBuddy.Search = {
        init: function () {
            $$('.sb-search').forEach(function (searchBox) {
                var input = searchBox.querySelector('.sb-input');
                var clearBtn = searchBox.querySelector('.search-clear');
                if (!input || !clearBtn) return;

                function toggle() {
                    clearBtn.style.display = input.value ? 'flex' : 'none';
                }

                input.addEventListener('input', toggle);
                clearBtn.addEventListener('click', function () {
                    input.value = '';
                    input.focus();
                    toggle();
                    input.dispatchEvent(new Event('input'));
                });

                toggle();
            });
        }
    };

    /* ============================================================
       PASSWORD TOGGLE (show/hide)
       ============================================================ */
    ScienceBuddy.PasswordToggle = {
        init: function () {
            $$('[data-password-toggle]').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    var targetId = btn.getAttribute('data-password-toggle');
                    var input = document.getElementById(targetId) || btn.closest('.sb-input-wrapper').querySelector('input');
                    if (!input) return;
                    var isText = input.type === 'text';
                    input.type = isText ? 'password' : 'text';
                    /* Toggle icon */
                    var icon = btn.querySelector('i, span');
                    if (icon) {
                        if (isText) {
                            icon.className = icon.className.replace('fa-eye-slash', 'fa-eye').replace('bi-eye-slash', 'bi-eye');
                        } else {
                            icon.className = icon.className.replace('fa-eye', 'fa-eye-slash').replace('bi-eye', 'bi-eye-slash');
                        }
                    }
                });
            });
        }
    };

    /* ============================================================
       PROGRESS BARS — animate on scroll into view
       ============================================================ */
    ScienceBuddy.ProgressBars = {
        init: function () {
            var bars = $$('.sb-progress-bar[data-value]');
            if (!bars.length) return;

            if ('IntersectionObserver' in window) {
                var observer = new IntersectionObserver(function (entries) {
                    entries.forEach(function (entry) {
                        if (entry.isIntersecting) {
                            var bar = entry.target;
                            bar.style.width = (bar.getAttribute('data-value') || '0') + '%';
                            observer.unobserve(bar);
                        }
                    });
                }, { threshold: 0.3 });

                bars.forEach(function (bar) {
                    bar.style.width = '0';
                    observer.observe(bar);
                });
            } else {
                /* Fallback: set immediately */
                bars.forEach(function (bar) {
                    bar.style.width = (bar.getAttribute('data-value') || '0') + '%';
                });
            }
        }
    };

    /* ============================================================
       RIPPLE EFFECT on buttons
       ============================================================ */
    ScienceBuddy.Ripple = {
        init: function () {
            document.addEventListener('click', function (e) {
                var btn = e.target.closest('.sb-btn');
                if (!btn) return;

                var circle = document.createElement('span');
                var rect   = btn.getBoundingClientRect();
                var size   = Math.max(rect.width, rect.height);
                var x = e.clientX - rect.left - size / 2;
                var y = e.clientY - rect.top  - size / 2;

                circle.style.cssText = [
                    'position:absolute',
                    'width:' + size + 'px',
                    'height:' + size + 'px',
                    'left:' + x + 'px',
                    'top:' + y + 'px',
                    'background:rgba(255,255,255,.35)',
                    'border-radius:50%',
                    'transform:scale(0)',
                    'animation:sb-ripple 0.5s ease',
                    'pointer-events:none'
                ].join(';');

                /* Ensure btn is positioned for absolute child */
                if (getComputedStyle(btn).position === 'static') {
                    btn.style.position = 'relative';
                }
                btn.style.overflow = 'hidden';
                btn.appendChild(circle);
                setTimeout(function () { circle.remove(); }, 600);
            });

            /* Inject keyframe once */
            if (!document.getElementById('sb-ripple-style')) {
                var style = document.createElement('style');
                style.id = 'sb-ripple-style';
                style.textContent = '@keyframes sb-ripple{to{transform:scale(4);opacity:0}}';
                document.head.appendChild(style);
            }
        }
    };

    /* ============================================================
       TOOLTIP  (data-tooltip attribute)
       ============================================================ */
    ScienceBuddy.Tooltip = {
        tip: null,

        init: function () {
            var self = this;

            document.addEventListener('mouseover', function (e) {
                var el = e.target.closest('[data-tooltip]');
                if (!el) return;
                self.show(el);
            });

            document.addEventListener('mouseout', function (e) {
                var el = e.target.closest('[data-tooltip]');
                if (!el) return;
                self.hide();
            });

            document.addEventListener('focusin', function (e) {
                if (e.target.hasAttribute('data-tooltip')) self.show(e.target);
            });

            document.addEventListener('focusout', function (e) {
                if (e.target.hasAttribute('data-tooltip')) self.hide();
            });
        },

        show: function (el) {
            this.hide();
            var text = el.getAttribute('data-tooltip');
            if (!text) return;

            var tip = document.createElement('div');
            tip.className = 'sb-tooltip-bubble';
            tip.textContent = text;
            tip.style.cssText = [
                'position:fixed',
                'z-index:9999',
                'background:#1E293B',
                'color:#F1F5F9',
                'font-size:.8125rem',
                'font-weight:600',
                'padding:6px 12px',
                'border-radius:8px',
                'pointer-events:none',
                'white-space:nowrap',
                'box-shadow:0 4px 16px rgba(0,0,0,.2)'
            ].join(';');

            document.body.appendChild(tip);
            this.tip = tip;

            var rect = el.getBoundingClientRect();
            var tipRect = tip.getBoundingClientRect();
            var top  = rect.top - tipRect.height - 8;
            var left = rect.left + rect.width / 2 - tipRect.width / 2;
            if (top < 8) top = rect.bottom + 8;
            if (left < 8) left = 8;
            if (left + tipRect.width > window.innerWidth - 8) {
                left = window.innerWidth - tipRect.width - 8;
            }

            tip.style.top  = top  + 'px';
            tip.style.left = left + 'px';
        },

        hide: function () {
            if (this.tip) { this.tip.remove(); this.tip = null; }
        }
    };

    /* ============================================================
       STAT COUNTER ANIMATION
       ============================================================ */
    ScienceBuddy.Counter = {
        init: function () {
            var counters = $$('[data-count]');
            if (!counters.length) return;

            function animateCounter(el) {
                var target = parseFloat(el.getAttribute('data-count')) || 0;
                var duration = parseInt(el.getAttribute('data-count-duration') || 1200);
                var start = 0;
                var startTime = null;
                var isFloat = el.getAttribute('data-count').indexOf('.') !== -1;

                function step(timestamp) {
                    if (!startTime) startTime = timestamp;
                    var progress = Math.min((timestamp - startTime) / duration, 1);
                    var ease = 1 - Math.pow(1 - progress, 3); /* ease-out cubic */
                    var current = start + ease * (target - start);
                    el.textContent = isFloat ? current.toFixed(1) : Math.round(current).toLocaleString();
                    if (progress < 1) requestAnimationFrame(step);
                    else el.textContent = isFloat ? target.toFixed(1) : target.toLocaleString();
                }

                requestAnimationFrame(step);
            }

            if ('IntersectionObserver' in window) {
                var observer = new IntersectionObserver(function (entries) {
                    entries.forEach(function (entry) {
                        if (entry.isIntersecting) {
                            animateCounter(entry.target);
                            observer.unobserve(entry.target);
                        }
                    });
                }, { threshold: 0.5 });

                counters.forEach(function (el) { observer.observe(el); });
            } else {
                counters.forEach(animateCounter);
            }
        }
    };

    /* ============================================================
       STICKY HEADER shrink on scroll
       ============================================================ */
    ScienceBuddy.StickyNav = {
        init: function () {
            var nav = $('.sb-topnav');
            if (!nav) return;

            window.addEventListener('scroll', function () {
                if (window.scrollY > 10) {
                    nav.style.boxShadow = '0 4px 20px rgba(37,99,235,.15)';
                } else {
                    nav.style.boxShadow = '';
                }
            }, { passive: true });
        }
    };

    /* ============================================================
       INIT ALL
       ============================================================ */
    ready(function () {
        ScienceBuddy.Sidebar.init();
        ScienceBuddy.Sidebar.markActive();
        ScienceBuddy.TopNav.init();
        ScienceBuddy.Tabs.init();
        ScienceBuddy.Dropdown.init();
        ScienceBuddy.UserMenu.init();
        ScienceBuddy.PageTitle.init();
        ScienceBuddy.Search.init();
        ScienceBuddy.PasswordToggle.init();
        ScienceBuddy.ProgressBars.init();
        ScienceBuddy.Ripple.init();
        ScienceBuddy.Tooltip.init();
        ScienceBuddy.Counter.init();
        ScienceBuddy.StickyNav.init();
    });

})();

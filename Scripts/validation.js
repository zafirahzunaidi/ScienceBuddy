/* ============================================================
   ScienceBuddy - validation.js
   Client-side form validation helpers
   ============================================================ */

(function () {
    'use strict';

    window.ScienceBuddy = window.ScienceBuddy || {};

    /* ============================================================
       RULES
       ============================================================ */
    var Rules = {
        required: function (val) {
            return val.trim().length > 0;
        },
        minLength: function (val, len) {
            return val.trim().length >= parseInt(len, 10);
        },
        maxLength: function (val, len) {
            return val.trim().length <= parseInt(len, 10);
        },
        email: function (val) {
            return /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(val.trim());
        },
        phone: function (val) {
            /* Malaysian mobile format: 01x-xxxxxxx or +601x-xxxxxxx */
            return /^(\+?60|0)[0-9]{1,2}[-\s]?[0-9]{6,8}$/.test(val.replace(/\s/g, ''));
        },
        numeric: function (val) {
            return /^\d+$/.test(val.trim());
        },
        alphanumeric: function (val) {
            return /^[a-zA-Z0-9]+$/.test(val.trim());
        },
        url: function (val) {
            try { new URL(val.trim()); return true; } catch (e) { return false; }
        },
        pattern: function (val, regex) {
            return new RegExp(regex).test(val);
        },
        min: function (val, min) {
            return parseFloat(val) >= parseFloat(min);
        },
        max: function (val, max) {
            return parseFloat(val) <= parseFloat(max);
        },
        match: function (val, otherId) {
            var other = document.getElementById(otherId);
            return other ? val === other.value : true;
        },
        passwordStrength: function (val) {
            /* Minimum 8 chars, 1 uppercase, 1 lowercase, 1 digit */
            return /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/.test(val);
        },
        date: function (val) {
            var d = new Date(val);
            return !isNaN(d.getTime());
        },
        futureDate: function (val) {
            return new Date(val) > new Date();
        },
        pastDate: function (val) {
            return new Date(val) < new Date();
        },
        fileSize: function (input, maxMB) {
            if (!input.files || !input.files.length) return true;
            return input.files[0].size <= parseFloat(maxMB) * 1024 * 1024;
        },
        fileType: function (input, types) {
            if (!input.files || !input.files.length) return true;
            var allowed = types.split(',').map(function (t) { return t.trim().toLowerCase(); });
            var ext = input.files[0].name.split('.').pop().toLowerCase();
            return allowed.indexOf('.' + ext) !== -1 || allowed.indexOf(ext) !== -1;
        },
        mykad: function (val) {
            /* Malaysian MyKad: YYMMDD-SS-NNNN */
            return /^\d{6}-\d{2}-\d{4}$/.test(val.trim());
        }
    };

    /* ============================================================
       MESSAGES
       ============================================================ */
    var Messages = {
        required:         'This field is required.',
        minLength:        'Must be at least {0} characters.',
        maxLength:        'Must be no more than {0} characters.',
        email:            'Please enter a valid email address.',
        phone:            'Please enter a valid Malaysian phone number.',
        numeric:          'Only numbers are allowed.',
        alphanumeric:     'Only letters and numbers are allowed.',
        url:              'Please enter a valid URL.',
        pattern:          'Invalid format.',
        min:              'Value must be at least {0}.',
        max:              'Value must be no more than {0}.',
        match:            'Passwords do not match.',
        passwordStrength: 'Password must be at least 8 characters and include uppercase, lowercase, and a number.',
        date:             'Please enter a valid date.',
        futureDate:       'Date must be in the future.',
        pastDate:         'Date must be in the past.',
        fileSize:         'File size must not exceed {0} MB.',
        fileType:         'Allowed file types: {0}.',
        mykad:            'Please enter a valid MyKad number (YYMMDD-SS-NNNN).'
    };

    function formatMsg(template, param) {
        return template.replace('{0}', param || '');
    }

    /* ============================================================
       DOM HELPERS
       ============================================================ */
    function getFieldError(field) {
        /* Look for sibling .sb-field-error */
        var parent  = field.closest('.sb-form-group') || field.parentElement;
        var errEl   = parent ? parent.querySelector('.sb-field-error') : null;
        if (!errEl) {
            /* Create one */
            errEl = document.createElement('div');
            errEl.className = 'sb-field-error';
            errEl.setAttribute('role', 'alert');
            errEl.setAttribute('aria-live', 'polite');
            field.parentNode.insertBefore(errEl, field.nextSibling);
        }
        return errEl;
    }

    function showError(field, message) {
        field.classList.add('input-error');
        field.classList.remove('input-success');
        field.setAttribute('aria-invalid', 'true');
        var errEl = getFieldError(field);
        errEl.innerHTML = '&#9888; ' + message;
        errEl.style.display = 'flex';
    }

    function clearError(field) {
        field.classList.remove('input-error');
        field.classList.add('input-success');
        field.setAttribute('aria-invalid', 'false');
        var errEl = getFieldError(field);
        if (errEl) { errEl.textContent = ''; errEl.style.display = 'none'; }
    }

    function clearAll(field) {
        field.classList.remove('input-error', 'input-success');
        field.removeAttribute('aria-invalid');
        var errEl = getFieldError(field);
        if (errEl) { errEl.textContent = ''; errEl.style.display = 'none'; }
    }

    /* ============================================================
       VALIDATE SINGLE FIELD
       Returns: { valid: bool, message: string }
       ============================================================ */
    function validateField(field) {
        var val = (field.type === 'file') ? '' : (field.value || '');
        var dataset = field.dataset;

        /* required */
        if (field.hasAttribute('data-validate-required') || field.required) {
            if (!Rules.required(val)) {
                return { valid: false, message: dataset.msgRequired || Messages.required };
            }
        }

        /* Skip further checks if empty and not required */
        if (!val.trim() && field.type !== 'file') return { valid: true };

        /* email */
        if (dataset.validateEmail !== undefined && !Rules.email(val)) {
            return { valid: false, message: dataset.msgEmail || Messages.email };
        }

        /* phone */
        if (dataset.validatePhone !== undefined && !Rules.phone(val)) {
            return { valid: false, message: dataset.msgPhone || Messages.phone };
        }

        /* numeric */
        if (dataset.validateNumeric !== undefined && !Rules.numeric(val)) {
            return { valid: false, message: dataset.msgNumeric || Messages.numeric };
        }

        /* alphanumeric */
        if (dataset.validateAlphanumeric !== undefined && !Rules.alphanumeric(val)) {
            return { valid: false, message: dataset.msgAlphanumeric || Messages.alphanumeric };
        }

        /* minLength */
        if (dataset.validateMinlength !== undefined) {
            var minLen = parseInt(dataset.validateMinlength, 10);
            if (!Rules.minLength(val, minLen)) {
                return { valid: false, message: dataset.msgMinlength || formatMsg(Messages.minLength, minLen) };
            }
        }

        /* maxLength */
        if (dataset.validateMaxlength !== undefined) {
            var maxLen = parseInt(dataset.validateMaxlength, 10);
            if (!Rules.maxLength(val, maxLen)) {
                return { valid: false, message: dataset.msgMaxlength || formatMsg(Messages.maxLength, maxLen) };
            }
        }

        /* min */
        if (dataset.validateMin !== undefined && !Rules.min(val, dataset.validateMin)) {
            return { valid: false, message: dataset.msgMin || formatMsg(Messages.min, dataset.validateMin) };
        }

        /* max */
        if (dataset.validateMax !== undefined && !Rules.max(val, dataset.validateMax)) {
            return { valid: false, message: dataset.msgMax || formatMsg(Messages.max, dataset.validateMax) };
        }

        /* url */
        if (dataset.validateUrl !== undefined && !Rules.url(val)) {
            return { valid: false, message: dataset.msgUrl || Messages.url };
        }

        /* pattern */
        if (dataset.validatePattern !== undefined && !Rules.pattern(val, dataset.validatePattern)) {
            return { valid: false, message: dataset.msgPattern || Messages.pattern };
        }

        /* match (e.g. confirm password) */
        if (dataset.validateMatch !== undefined && !Rules.match(val, dataset.validateMatch)) {
            return { valid: false, message: dataset.msgMatch || Messages.match };
        }

        /* password strength */
        if (dataset.validatePasswordStrength !== undefined && !Rules.passwordStrength(val)) {
            return { valid: false, message: dataset.msgPasswordStrength || Messages.passwordStrength };
        }

        /* date */
        if (field.type === 'date' || dataset.validateDate !== undefined) {
            if (val && !Rules.date(val)) {
                return { valid: false, message: Messages.date };
            }
            if (dataset.validateFutureDate !== undefined && !Rules.futureDate(val)) {
                return { valid: false, message: Messages.futureDate };
            }
            if (dataset.validatePastDate !== undefined && !Rules.pastDate(val)) {
                return { valid: false, message: Messages.pastDate };
            }
        }

        /* mykad */
        if (dataset.validateMykad !== undefined && !Rules.mykad(val)) {
            return { valid: false, message: dataset.msgMykad || Messages.mykad };
        }

        /* file size */
        if (field.type === 'file' && dataset.validateFilesize !== undefined) {
            if (!Rules.fileSize(field, dataset.validateFilesize)) {
                return { valid: false, message: formatMsg(Messages.fileSize, dataset.validateFilesize) };
            }
        }

        /* file type */
        if (field.type === 'file' && dataset.validateFiletype !== undefined) {
            if (!Rules.fileType(field, dataset.validateFiletype)) {
                return { valid: false, message: formatMsg(Messages.fileType, dataset.validateFiletype) };
            }
        }

        return { valid: true };
    }

    /* ============================================================
       VALIDATE ENTIRE FORM
       Returns true if all fields pass.
       ============================================================ */
    function validateForm(form) {
        var fields = Array.prototype.slice.call(
            form.querySelectorAll('[data-validate-required],[data-validate-email],[data-validate-phone],[data-validate-numeric],[data-validate-alphanumeric],[data-validate-minlength],[data-validate-maxlength],[data-validate-min],[data-validate-max],[data-validate-url],[data-validate-pattern],[data-validate-match],[data-validate-password-strength],[data-validate-date],[data-validate-mykad],[data-validate-filesize],[data-validate-filetype],[required]')
        );

        var formValid = true;
        var firstError = null;

        fields.forEach(function (field) {
            var result = validateField(field);
            if (result.valid) {
                clearError(field);
            } else {
                showError(field, result.message);
                formValid = false;
                if (!firstError) firstError = field;
            }
        });

        if (firstError) {
            firstError.focus();
            firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }

        return formValid;
    }

    /* ============================================================
       REAL-TIME VALIDATION (blur + input events)
       ============================================================ */
    function attachRealTime(form) {
        var fields = form.querySelectorAll('input, select, textarea');
        fields.forEach(function (field) {
            /* Validate on blur */
            field.addEventListener('blur', function () {
                if (hasValidationRules(field)) {
                    var result = validateField(field);
                    if (result.valid) { clearError(field); }
                    else { showError(field, result.message); }
                }
            });

            /* Clear error while typing */
            field.addEventListener('input', function () {
                if (field.classList.contains('input-error')) {
                    clearAll(field);
                }
            });

            field.addEventListener('change', function () {
                if (hasValidationRules(field)) {
                    var result = validateField(field);
                    if (result.valid) { clearError(field); }
                    else { showError(field, result.message); }
                }
            });
        });
    }

    function hasValidationRules(field) {
        var attrs = ['data-validate-required','data-validate-email','data-validate-phone',
                     'data-validate-numeric','data-validate-alphanumeric','data-validate-minlength',
                     'data-validate-maxlength','data-validate-min','data-validate-max',
                     'data-validate-url','data-validate-pattern','data-validate-match',
                     'data-validate-password-strength','data-validate-date','data-validate-mykad',
                     'required'];
        return attrs.some(function (a) { return field.hasAttribute(a); });
    }

    /* ============================================================
       PASSWORD STRENGTH METER
       ============================================================ */
    function initPasswordMeter(inputId, meterId) {
        var input = document.getElementById(inputId);
        var meter = document.getElementById(meterId);
        if (!input || !meter) return;

        input.addEventListener('input', function () {
            var val  = input.value;
            var score = 0;
            var label = '';
            var color = '';

            if (val.length >= 8)              score++;
            if (/[a-z]/.test(val))            score++;
            if (/[A-Z]/.test(val))            score++;
            if (/\d/.test(val))               score++;
            if (/[^a-zA-Z0-9]/.test(val))    score++;

            if      (score <= 1) { label = 'Weak';      color = '#EF4444'; }
            else if (score === 2) { label = 'Fair';      color = '#F59E0B'; }
            else if (score === 3) { label = 'Good';      color = '#FFD84D'; }
            else if (score === 4) { label = 'Strong';    color = '#22C55E'; }
            else                  { label = 'Very Strong'; color = '#16A34A'; }

            var pct = (score / 5) * 100;
            var bar = meter.querySelector('.sb-progress-bar');
            var text = meter.querySelector('.strength-label');

            if (bar)  { bar.style.width = pct + '%'; bar.style.background = color; }
            if (text) { text.textContent = val ? label : ''; text.style.color = color; }
        });
    }

    /* ============================================================
       CHARACTER COUNTER
       ============================================================ */
    function initCharCounter(inputId, counterId) {
        var input   = document.getElementById(inputId);
        var counter = document.getElementById(counterId);
        if (!input || !counter) return;

        var max = parseInt(input.getAttribute('maxlength') || input.getAttribute('data-validate-maxlength') || 0, 10);

        function update() {
            var len = input.value.length;
            counter.textContent = max > 0 ? (len + ' / ' + max) : len + ' characters';
            if (max > 0 && len > max * 0.9) { counter.style.color = '#EF4444'; }
            else { counter.style.color = ''; }
        }

        input.addEventListener('input', update);
        update();
    }

    /* ============================================================
       AUTO-INIT on forms with data-validate="true"
       ============================================================ */
    function autoInit() {
        var forms = document.querySelectorAll('form[data-validate="true"]');
        forms.forEach(function (form) {
            attachRealTime(form);

            form.addEventListener('submit', function (e) {
                if (!validateForm(form)) {
                    e.preventDefault();
                    e.stopPropagation();
                }
            });
        });
    }

    /* ============================================================
       PUBLIC API
       ============================================================ */
    ScienceBuddy.Validation = {
        validateField: validateField,
        validateForm:  validateForm,
        attachRealTime: attachRealTime,
        showError:     showError,
        clearError:    clearError,
        clearAll:      clearAll,
        initPasswordMeter: initPasswordMeter,
        initCharCounter:   initCharCounter,
        Rules:    Rules,
        Messages: Messages
    };

    /* Run auto-init on DOM ready */
    function ready(fn) {
        if (document.readyState !== 'loading') fn();
        else document.addEventListener('DOMContentLoaded', fn);
    }

    ready(autoInit);

})();

/**
 * script.js
 * ---------------------------------------------------------------------
 * Small, dependency-free (besides Bootstrap) JS helpers used across
 * the app: mobile sidebar toggle, client-side validation, live table
 * search/filter, and delete confirmations.
 * ---------------------------------------------------------------------
 */

document.addEventListener('DOMContentLoaded', function () {

    /* ---------------- Mobile sidebar toggle ---------------- */
    var toggleBtn = document.querySelector('.mobile-toggle');
    var sidebar = document.querySelector('.sidebar');
    var backdrop = document.querySelector('.sidebar-backdrop');

    function closeSidebar() {
        sidebar && sidebar.classList.remove('open');
        backdrop && backdrop.classList.remove('show');
    }

    if (toggleBtn && sidebar) {
        toggleBtn.addEventListener('click', function () {
            sidebar.classList.toggle('open');
            backdrop && backdrop.classList.toggle('show');
        });
    }
    if (backdrop) {
        backdrop.addEventListener('click', closeSidebar);
    }

    /* ---------------- Auto-dismiss flash alerts ---------------- */
    document.querySelectorAll('.app-alert').forEach(function (el) {
        setTimeout(function () {
            if (window.bootstrap) {
                var alert = bootstrap.Alert.getOrCreateInstance(el);
                alert.close();
            } else {
                el.remove();
            }
        }, 5000);
    });

    /* ---------------- Bootstrap client-side validation ---------------- */
    document.querySelectorAll('form.needs-validation').forEach(function (form) {
        form.addEventListener('submit', function (event) {
            if (!form.checkValidity()) {
                event.preventDefault();
                event.stopPropagation();
            }
            form.classList.add('was-validated');
        }, false);
    });

    /* ---------------- Password confirmation match (register form) ---------------- */
    var pwd = document.getElementById('password');
    var pwd2 = document.getElementById('confirm_password');
    if (pwd && pwd2) {
        function checkMatch() {
            if (pwd2.value && pwd.value !== pwd2.value) {
                pwd2.setCustomValidity('Passwords do not match');
            } else {
                pwd2.setCustomValidity('');
            }
        }
        pwd.addEventListener('input', checkMatch);
        pwd2.addEventListener('input', checkMatch);
    }

    /* ---------------- Live table / grid search filter ---------------- */
    document.querySelectorAll('[data-live-search]').forEach(function (input) {
        var targetSelector = input.getAttribute('data-live-search');
        var rows = document.querySelectorAll(targetSelector);
        input.addEventListener('keyup', function () {
            var q = input.value.trim().toLowerCase();
            rows.forEach(function (row) {
                var text = row.getAttribute('data-search-text') || row.textContent;
                row.style.display = text.toLowerCase().indexOf(q) > -1 ? '' : 'none';
            });
        });
    });

    /* ---------------- Delete confirmation ---------------- */
    document.querySelectorAll('[data-confirm]').forEach(function (el) {
        el.addEventListener('click', function (e) {
            var msg = el.getAttribute('data-confirm') || 'Are you sure?';
            if (!confirm(msg)) {
                e.preventDefault();
            }
        });
    });

    /* ---------------- Category/author/publisher filter select on browse page ---------------- */
    document.querySelectorAll('[data-auto-submit]').forEach(function (el) {
        el.addEventListener('change', function () {
            el.closest('form').submit();
        });
    });

});

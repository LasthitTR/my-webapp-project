<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Hello World</title>
    <style>
        :root {
            --bg: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --surface: rgba(255, 255, 255, 0.1);
            --text: #ffffff;
            --muted: rgba(255,255,255,0.8);
            --shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
            --border: rgba(255, 255, 255, 0.18);
        }
        .light {
            --bg: linear-gradient(135deg, #f6d365 0%, #fda085 100%);
            --surface: rgba(0,0,0,0.04);
            --text: #111827;
            --muted: rgba(0,0,0,0.6);
            --shadow: 0 8px 32px rgba(16,24,40,0.06);
            --border: rgba(0,0,0,0.06);
        }
        .dark {
            --bg: linear-gradient(135deg, #0f172a 0%, #0b1220 100%);
            --surface: rgba(255,255,255,0.03);
            --text: #e6eef8;
            --muted: rgba(255,255,255,0.7);
            --shadow: 0 8px 32px rgba(2,6,23,0.6);
            --border: rgba(255,255,255,0.04);
        }

        html, body {
            height: 100%;
        }
        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: var(--bg);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: var(--text);
            transition: background 250ms ease, color 200ms ease;
        }
        .container {
            text-align: center;
            background: var(--surface);
            padding: 3rem;
            border-radius: 20px;
            backdrop-filter: blur(6px);
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
        }
        h2 {
            font-size: 4rem;
            margin: 0;
            text-shadow: 2px 2px 10px rgba(0,0,0,0.08);
        }
        p {
            color: var(--muted);
            font-size: 1.2rem;
        }

        /* Top-right theme toggle */
        .theme-toggle {
            position: fixed;
            top: 16px;
            right: 16px;
            background: transparent;
            border: 1px solid var(--border);
            color: var(--text);
            padding: 8px 12px;
            border-radius: 999px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            backdrop-filter: blur(6px);
            transition: background 150ms ease, transform 120ms ease;
        }
        .theme-toggle:active { transform: scale(0.98); }
        .theme-toggle .icon { font-size: 1.1rem; }
    </style>
</head>
<body>
    <button id="theme-toggle" class="theme-toggle" aria-pressed="false" title="Toggle dark / light">
        <span class="icon" id="theme-icon">🌙</span>
        <span id="theme-label">Dark</span>
    </button>

    <div class="container">
        <h2>Hello World!</h2>
        <p>This page has been critically beautified.</p>
    </div>

    <script>
        (function() {
            var root = document.documentElement;
            var toggle = document.getElementById('theme-toggle');
            var icon = document.getElementById('theme-icon');
            var label = document.getElementById('theme-label');

            function applyTheme(theme) {
                root.classList.remove('light','dark');
                if (theme === 'dark') root.classList.add('dark');
                else if (theme === 'light') root.classList.add('light');
                // update UI
                var isDark = theme === 'dark';
                toggle.setAttribute('aria-pressed', String(isDark));
                icon.textContent = isDark ? '🌙' : '☀️';
                label.textContent = isDark ? 'Dark' : 'Light';
            }

            // Determine initial theme: localStorage -> prefers-color-scheme -> default dark
            var saved = null;
            try { saved = localStorage.getItem('theme'); } catch(e) {}
            if (saved === 'dark' || saved === 'light') {
                applyTheme(saved);
            } else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches) {
                applyTheme('light');
            } else {
                applyTheme('dark');
            }

            toggle.addEventListener('click', function() {
                // toggle between dark and light
                var current = root.classList.contains('dark') ? 'dark' : (root.classList.contains('light') ? 'light' : 'dark');
                var next = current === 'dark' ? 'light' : 'dark';
                applyTheme(next);
                try { localStorage.setItem('theme', next); } catch(e) {}
            });
        })();
    </script>
</body>
</html>

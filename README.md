
<style>
  @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600&family=Fraunces:wght@400;600&display=swap');

  * { box-sizing: border-box; margin: 0; padding: 0; }

  .readme-wrap {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    font-size: 14px;
    line-height: 1.7;
    color: var(--color-text-primary);
    background: var(--color-background-primary);
    border: 0.5px solid var(--color-border-tertiary);
    border-radius: var(--border-radius-lg);
    padding: 2rem 2.5rem;
    max-width: 780px;
    margin: 1rem auto;
  }

  .gh-header {
    display: flex;
    align-items: center;
    gap: 10px;
    padding-bottom: 1rem;
    border-bottom: 0.5px solid var(--color-border-tertiary);
    margin-bottom: 1.5rem;
  }

  .gh-dot { width: 12px; height: 12px; border-radius: 50%; }
  .d-red { background: #ff5f57; }
  .d-yellow { background: #febc2e; }
  .d-green { background: #28c840; }

  .gh-filename {
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
    color: var(--color-text-secondary);
    margin-left: 8px;
  }

  h1.proj-title {
    font-family: 'Fraunces', Georgia, serif;
    font-size: 28px;
    font-weight: 600;
    letter-spacing: -0.5px;
    margin-bottom: 0.4rem;
  }

  .tagline {
    font-size: 15px;
    color: var(--color-text-secondary);
    margin-bottom: 1.2rem;
  }

  .badges {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-bottom: 1.8rem;
  }

  .badge {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 11px;
    padding: 3px 10px;
    border-radius: 20px;
    font-weight: 600;
    border: 0.5px solid transparent;
  }

  .badge-green { background: #EAF3DE; color: #3B6D11; border-color: #97C459; }
  .badge-blue { background: #E6F1FB; color: #185FA5; border-color: #85B7EB; }
  .badge-amber { background: #FAEEDA; color: #854F0B; border-color: #EF9F27; }
  .badge-purple { background: #EEEDFE; color: #3C3489; border-color: #AFA9EC; }

  @media (prefers-color-scheme: dark) {
    .badge-green { background: #27500A; color: #C0DD97; border-color: #639922; }
    .badge-blue { background: #0C447C; color: #B5D4F4; border-color: #378ADD; }
    .badge-amber { background: #633806; color: #FAC775; border-color: #BA7517; }
    .badge-purple { background: #3C3489; color: #CECBF6; border-color: #7F77DD; }
  }

  .section { margin-bottom: 1.8rem; }

  h2.sec-title {
    font-size: 16px;
    font-weight: 500;
    margin-bottom: 0.8rem;
    padding-bottom: 0.4rem;
    border-bottom: 0.5px solid var(--color-border-tertiary);
    color: var(--color-text-primary);
  }

  .feature-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 10px;
  }

  .feature-card {
    background: var(--color-background-secondary);
    border: 0.5px solid var(--color-border-tertiary);
    border-radius: var(--border-radius-md);
    padding: 12px 14px;
    display: flex;
    align-items: flex-start;
    gap: 10px;
  }

  .feature-icon {
    width: 28px;
    height: 28px;
    border-radius: var(--border-radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    flex-shrink: 0;
  }

  .fi-teal { background: #E1F5EE; }
  .fi-blue { background: #E6F1FB; }
  .fi-amber { background: #FAEEDA; }
  .fi-purple { background: #EEEDFE; }
  .fi-coral { background: #FAECE7; }
  .fi-green { background: #EAF3DE; }
  .fi-pink { background: #FBEAF0; }
  .fi-gray { background: #F1EFE8; }

  @media (prefers-color-scheme: dark) {
    .fi-teal { background: #085041; }
    .fi-blue { background: #0C447C; }
    .fi-amber { background: #633806; }
    .fi-purple { background: #3C3489; }
    .fi-coral { background: #712B13; }
    .fi-green { background: #27500A; }
    .fi-pink { background: #72243E; }
    .fi-gray { background: #444441; }
  }

  .feature-text p:first-child {
    font-size: 13px;
    font-weight: 500;
    margin-bottom: 2px;
  }

  .feature-text p:last-child {
    font-size: 12px;
    color: var(--color-text-secondary);
  }

  .code-block {
    background: var(--color-background-secondary);
    border: 0.5px solid var(--color-border-tertiary);
    border-radius: var(--border-radius-md);
    padding: 14px 16px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
    line-height: 1.8;
    overflow-x: auto;
    color: var(--color-text-primary);
  }

  .code-comment { color: var(--color-text-tertiary); }
  .code-cmd { color: #185FA5; }
  @media (prefers-color-scheme: dark) { .code-cmd { color: #85B7EB; } }

  .stack-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  .stack-pill {
    font-family: 'JetBrains Mono', monospace;
    font-size: 11px;
    padding: 4px 12px;
    background: var(--color-background-secondary);
    border: 0.5px solid var(--color-border-secondary);
    border-radius: 20px;
    color: var(--color-text-secondary);
  }

  .divider {
    height: 0.5px;
    background: var(--color-border-tertiary);
    margin: 1.5rem 0;
  }

  .footer-text {
    font-size: 12px;
    color: var(--color-text-tertiary);
    text-align: center;
  }

  .copy-btn {
    float: right;
    font-size: 11px;
    padding: 3px 10px;
    cursor: pointer;
    border-radius: var(--border-radius-md);
    border: 0.5px solid var(--color-border-secondary);
    background: transparent;
    color: var(--color-text-secondary);
    font-family: 'JetBrains Mono', monospace;
    margin-bottom: 6px;
  }

  .copy-btn:hover { background: var(--color-background-secondary); }

  .preview-note {
    font-size: 12px;
    color: var(--color-text-tertiary);
    margin-bottom: 1rem;
    font-style: italic;
  }
</style>

<div class="readme-wrap">
  <div class="gh-header">
    <div class="gh-dot d-red"></div>
    <div class="gh-dot d-yellow"></div>
    <div class="gh-dot d-green"></div>
    <span class="gh-filename">README.md</span>
  </div>

  <p class="preview-note">Preview of your README — scroll down to copy the raw Markdown</p>

  <h1 class="proj-title">Finance Tracker</h1>
  <p class="tagline">A clean, offline-first Flutter app to track your money — income, expenses, and budgets in one place.</p>

  <div class="badges">
    <span class="badge badge-green">✓ Release</span>
    <span class="badge badge-blue">Flutter</span>
    <span class="badge badge-amber">Android</span>
    <span class="badge badge-purple">Dark mode</span>
  </div>

  <div class="section">
    <h2 class="sec-title">Features</h2>
    <div class="feature-grid">
      <div class="feature-card">
        <div class="feature-icon fi-teal">+</div>
        <div class="feature-text">
          <p>Transactions</p>
          <p>Add, edit, and delete income or expense records</p>
        </div>
      </div>
      <div class="feature-card">
        <div class="feature-icon fi-blue">↓</div>
        <div class="feature-text">
          <p>Monthly filter</p>
          <p>Browse transactions by month quickly</p>
        </div>
      </div>
      <div class="feature-card">
        <div class="feature-icon fi-gray">?</div>
        <div class="feature-text">
          <p>Search</p>
          <p>Find any transaction instantly by keyword</p>
        </div>
      </div>
      <div class="feature-card">
        <div class="feature-icon fi-purple">↗</div>
        <div class="feature-text">
          <p>Charts</p>
          <p>Visual breakdown of income vs expenses</p>
        </div>
      </div>
      <div class="feature-card">
        <div class="feature-icon fi-amber">$</div>
        <div class="feature-text">
          <p>Budget</p>
          <p>Set spending limits per category</p>
        </div>
      </div>
      <div class="feature-card">
        <div class="feature-icon fi-green">↓</div>
        <div class="feature-text">
          <p>CSV export</p>
          <p>Export your data for external analysis</p>
        </div>
      </div>
      <div class="feature-card">
        <div class="feature-icon fi-coral">☁</div>
        <div class="feature-text">
          <p>Backup & restore</p>
          <p>Never lose your data</p>
        </div>
      </div>
      <div class="feature-card">
        <div class="feature-icon fi-pink">◑</div>
        <div class="feature-text">
          <p>Dark mode</p>
          <p>Easy on the eyes, day or night</p>
        </div>
      </div>
    </div>
  </div>

  <div class="section">
    <h2 class="sec-title">Download</h2>
    <p style="font-size: 13px; color: var(--color-text-secondary); margin-bottom: 10px;">Get the latest <code style="font-family: 'JetBrains Mono', monospace; font-size: 11px; background: var(--color-background-secondary); padding: 2px 6px; border-radius: 4px;">.apk</code> from the Releases page and install it on any Android device.</p>
    <button class="copy-btn" onclick="copySection('dl')">copy</button>
    <div class="code-block" id="dl">
      <span class="code-comment"># Enable "Install from unknown sources" in Android settings first</span><br>
      <span class="code-comment"># Then open the .apk file to install</span>
    </div>
  </div>

  <div class="section">
    <h2 class="sec-title">Run locally</h2>
    <button class="copy-btn" onclick="copySection('run')">copy</button>
    <div class="code-block" id="run">
      <span class="code-cmd">git clone</span> https://github.com/Arjuanto/financial_tracker<br>
      <span class="code-cmd">cd</span> financial_tracker<br>
      <span class="code-cmd">flutter pub get</span><br>
      <span class="code-cmd">flutter run</span>
    </div>
  </div>

  <div class="section">
    <h2 class="sec-title">Built with</h2>
    <div class="stack-grid">
      <span class="stack-pill">Flutter</span>
      <span class="stack-pill">Dart</span>
      <span class="stack-pill">SQLite / Hive</span>
      <span class="stack-pill">fl_chart</span>
      <span class="stack-pill">csv</span>
      <span class="stack-pill">path_provider</span>
    </div>
  </div>

  <div class="divider"></div>
  <p class="footer-text">MIT License · made with Flutter</p>
</div>

<div style="margin: 1.5rem auto; max-width: 780px;">
  <button onclick="copyMarkdown()" style="font-family: 'JetBrains Mono', monospace; font-size: 12px; padding: 8px 18px; border-radius: var(--border-radius-md); border: 0.5px solid var(--color-border-secondary); background: var(--color-background-secondary); color: var(--color-text-primary); cursor: pointer; width: 100%;">
    Copy raw Markdown ↗
  </button>
  <p id="copy-confirm" style="font-size: 12px; color: var(--color-text-secondary); text-align: center; margin-top: 6px; min-height: 18px;"></p>
</div>

<script>
const RAW_MD = `# Finance Tracker

> A clean, offline-first Flutter app to track your money — income, expenses, and budgets in one place.

![Release](https://img.shields.io/badge/status-release-brightgreen)
![Flutter](https://img.shields.io/badge/built_with-Flutter-02569B)
![Android](https://img.shields.io/badge/platform-Android-3DDC84)
![Dark mode](https://img.shields.io/badge/dark_mode-supported-blueviolet)

---

## Features

| Feature | Description |
|---|---|
| Transactions | Add, edit, and delete income or expense records |
| Monthly filter | Browse transactions by month quickly |
| Search | Find any transaction instantly by keyword |
| Charts | Visual income vs expenses breakdown |
| Budget | Set spending limits per category |
| CSV export | Export your data for external analysis |
| Backup & restore | Never lose your data |
| Dark mode | Easy on the eyes, day or night |

---

## Download

Download the latest \`.apk\` from [Releases](../../releases) and install it on any Android device.

> Enable **Install from unknown sources** in your Android settings before installing.

---

## Run locally

\`\`\`bash
git clone https://github.com/Arjuanto/financial_tracker
cd financial_tracker
flutter pub get
flutter run
\`\`\`

---

## Built with

- [Flutter](https://flutter.dev) — UI framework
- [Dart](https://dart.dev) — language
- [SQLite / Hive](https://pub.dev/packages/hive) — local storage
- [fl_chart](https://pub.dev/packages/fl_chart) — charts
- \`csv\` — export
- \`path_provider\` — file access

---

## Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/5cb1b579-67f8-42d0-a4a7-fe7f975497e9" width="200"/>
  <img src="https://github.com/user-attachments/assets/425b26c9-3eaf-4c10-a044-7ecb0f1257d8" width="200"/>
  <img src="https://github.com/user-attachments/assets/65ad1e20-99b6-4c0d-924c-a905ba048698" width="200"/>
  <img src="https://github.com/user-attachments/assets/50c91bdd-2711-4614-970d-95ac299d57bc" width="200"/>
  <img src="https://github.com/user-attachments/assets/e141933c-7966-4b47-86a9-bb64503692d0" width="200"/>
  <img src="https://github.com/user-attachments/assets/63cf37fc-a39f-4f6e-8239-a0d63bd48094" width="200"/>
  <img src="https://github.com/user-attachments/assets/abe12c53-bb82-411b-906e-1097042fa9e7" width="200"/>
</p>

## License

MIT © Arjuanto`;

function copyMarkdown() {
  navigator.clipboard.writeText(RAW_MD).then(() => {
    const el = document.getElementById('copy-confirm');
    el.textContent = 'Copied! Paste it into your README.md file on GitHub.';
    setTimeout(() => { el.textContent = ''; }, 3000);
  });
}

function copySection(id) {
  const el = document.getElementById(id);
  navigator.clipboard.writeText(el.innerText);
}
</script>

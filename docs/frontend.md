# Frontend
## frontend/app.js
```js
// Change this if your API runs elsewhere (CI, container, remote)
const API_URL = (localStorage.getItem("API_URL") || "http://127.0.0.1:8000");
document.getElementById("apiUrlLabel").textContent = API_URL;

import {confirmDelete} from '.modal.js';

async function api(path, options = {}) {
  const res = await fetch(`${API_URL}${path}`, {
    headers: { "Content-Type": "application/json" },
    ...options,
  });
  if (res.status === 204) return null;
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.detail || `HTTP ${res.status}`);
  }
  return res.json();
}

function taskCard(task) {
  const div = document.createElement("div");
  div.className = "task";
  div.innerHTML = `
    <div class="row">
      <h3>${escapeHtml(task.title)}</h3>
      <span class="badge">${task.status}</span>
    </div>
    <p>${task.description ? task.description : "<em>Pas de description</em>"}</p>
    <small>id=${task.id} • créé=${new Date(task.created_at).toLocaleString()}</small>
    <div class="actions">
      <select data-role="status">
        <option value="TODO" ${task.status === "TODO" ? "selected" : ""}>TODO</option>
        <option value="DOING" ${task.status === "DOING" ? "selected" : ""}>DOING</option>
        <option value="DONE" ${task.status === "DONE" ? "selected" : ""}>DONE</option>
      </select>
      <button class="secondary" data-role="save">Mettre à jour</button>
      <button data-role="delete">Supprimer</button>
    </div>
  `;

  div.querySelector('[data-role="save"]').addEventListener("click", async () => {
    const status = div.querySelector('[data-role="status"]').value;
    await api(`/tasks/${task.id}`, { method: "PUT", body: JSON.stringify({ status }) });
    await refresh();
  });

  div.querySelector('[data-role="delete"]').addEventListener("click", async () => {
    
    const confirmed = await confirmDelete('Supprimer cette tâche ?');
    if (!confirmed) {
        return;
    };
    await api(`/tasks/${task.id}`, { method: "DELETE" });
    await refresh();
  });

  return div;
}

function escapeHtml(s) {
  return String(s)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

async function refresh() {
  const container = document.getElementById("tasks");
  container.innerHTML = "";
  try {
    const tasks = await api("/tasks");
    if (tasks.length === 0) {
      container.innerHTML = "<p><em>Aucune tâche pour l’instant.</em></p>";
      return;
    }
    tasks.forEach(t => container.appendChild(taskCard(t)));
  } catch (e) {
    container.innerHTML = `<p style="color:#b00020"><strong>Erreur:</strong> ${escapeHtml(e.message)}</p>
    <p>Vérifie que l’API tourne sur <code>${API_URL}</code>.</p>`;
  }
}

document.getElementById("refreshBtn").addEventListener("click", refresh);

document.getElementById("createForm").addEventListener("submit", async (ev) => {
  ev.preventDefault();
  const title = document.getElementById("title").value.trim();
  const description = document.getElementById("description").value.trim() || null;

  await api("/tasks", { method: "POST", body: JSON.stringify({ title, description }) });

  document.getElementById("title").value = "";
  document.getElementById("description").value = "";
  await refresh();
});

async function translate(locale = 'fr_fr') {
  const response = await fetch(`${locale}.json`);
  const labels = await response.json();

  // Texte des éléments
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (labels[key]) {
      el.textContent = labels[key];
    }
  });

  // Placeholder des inputs / textarea
  document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
    const key = el.getAttribute('data-i18n-placeholder');
    if (labels[key]) {
      el.setAttribute('placeholder', labels[key]);
    }
  });
}

// Appel initial
translate('fr_fr');

refresh();
```
## frontend/fr_fr.json
```json
{
    "appTitle": "Task Manager",
    "appSubtitle": "Mini app fil rouge pour CI/CD + tests",
    "confirmModalText": "Supprimer cette tâche ?",
    "confirmYes": "Oui",
    "confirmNo": "Non",
    "createTaskTitle": "Créer une tâche",
    "labelTitle": "Titre",
    "labelDescription": "Description (optionnel)",
    "placeholderTitle": "Ex: Écrire les tests API",
    "placeholderDescription": "Détails...",
    "buttonCreate": "Créer",
    "taskListTitle": "Liste des tâches",
    "buttonRefresh": "Rafraîchir",
    "apiExpected": "API attendue sur"
}```
## frontend/index.html
```html
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Task Manager (Demo)</title>
  <link rel="stylesheet" href="./styles.css" />
</head>
<body>
    <main class="container">
        <header class="header">
            <h1 data-i18n="appTitle"></h1>
            <p data-i18n="appSubtitle"></p>
        </header>

        <div id="confirm-modal" hidden>
            <p data-i18n="confirmModalText"></p>
            <button data-i18n="confirmYes"></button>
            <button data-i18n="confirmNo"></button>
        </div>

        <section class="card">
            <h2 data-i18n="createTaskTitle"></h2>
            <form id="createForm">
                <label>
                    <span data-i18n="labelTitle"></span>
                    <input id="title" type="text" required maxlength="200" data-i18n-placeholder="placeholderTitle" />
                </label>
                <label>
                    <span data-i18n="labelDescription"></span>
                    <textarea id="description" maxlength="1000" data-i18n-placeholder="placeholderDescription"></textarea>
                </label>
                <button type="submit" data-i18n="buttonCreate"></button>
            </form>
        </section>

        <section class="card">
            <div class="row">
                <h2 data-i18n="taskListTitle"></h2>
                <button id="refreshBtn" type="button" data-i18n="buttonRefresh"></button>
            </div>
            <div id="tasks"></div>
        </section>

        <footer class="footer">
            <small>
                <span data-i18n="apiExpected"></span> <code id="apiUrlLabel"></code>
            </small>
        </footer>
    </main>


  <script src="./app.js"></script>
</body>
</html>
```
## frontend/modal.js
```js
function confirmDelete(text) {
        return new Promise(resolve => {
            const modal = document.getElementById("confirm-modal");
            const yes = document.getElementById("confirm-yes");
            const no = document.getElementById("confirm-no");
            const textparagraphe = document.getElementById("modal-text");
            textparagraphe.innerText = text;

            modal.hidden = false;

            yes.onclick = () => {
            modal.hidden = true;
            resolve(true);
            };

            no.onclick = () => {
            modal.hidden = true;
            resolve(false);
            };
        });
    }
```
## frontend/styles.css
```css
* { box-sizing: border-box; }
body { margin: 0; font-family: system-ui, -apple-system, Segoe UI, Roboto, Arial; background: #f6f7fb; color: #111; }
.container { max-width: 900px; margin: 0 auto; padding: 24px; }
.header { margin-bottom: 18px; }
.card { background: white; border-radius: 12px; padding: 16px; margin-bottom: 16px; box-shadow: 0 2px 10px rgba(0,0,0,.06); }
label { display: block; margin-bottom: 10px; }
input, textarea, select { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 10px; }
textarea { min-height: 80px; resize: vertical; }
button { padding: 10px 12px; border: 0; border-radius: 10px; cursor: pointer; background: #111; color: white; }
button.secondary { background: #e9e9ef; color: #111; }
.row { display:flex; align-items:center; justify-content:space-between; gap: 10px; }
.task { border: 1px solid #eee; border-radius: 10px; padding: 12px; margin-top: 10px; }
.task h3 { margin: 0 0 6px 0; }
.task small { color: #555; }
.task .actions { margin-top: 10px; display:flex; gap: 8px; flex-wrap: wrap; }
.badge { display:inline-block; padding: 2px 8px; border-radius: 999px; background:#f0f0f7; font-size: 12px; }
.footer { opacity: .8; }
```

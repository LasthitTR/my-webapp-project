<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>TODO List</title>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
	<style>
		:root {
			--bg-dark: #0f172a;
			--bg-mid: #1e293b;
			--bg-light: #334155;
			--text-main: #f8fafc;
			--text-muted: #cbd5e1;
			--accent: #22d3ee;
			--accent-2: #a78bfa;
			--card-bg: rgba(255, 255, 255, 0.08);
			--border: rgba(255, 255, 255, 0.2);
		}

		* {
			margin: 0;
			padding: 0;
			box-sizing: border-box;
		}

		body {
			min-height: 100vh;
			font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
			background: radial-gradient(circle at top right, #312e81 0%, var(--bg-dark) 45%),
						linear-gradient(140deg, var(--bg-dark), var(--bg-mid));
			color: var(--text-main);
			display: flex;
			align-items: center;
			justify-content: center;
			padding: 32px;
		}

		.container {
			width: min(1000px, 100%);
			background: linear-gradient(145deg, rgba(255, 255, 255, 0.08), rgba(255, 255, 255, 0.03));
			border: 1px solid var(--border);
			border-radius: 24px;
			backdrop-filter: blur(10px);
			box-shadow: 0 20px 60px rgba(0, 0, 0, 0.35);
			overflow: hidden;
		}

		.hero {
			padding: 44px 34px 30px;
			text-align: center;
		}

		.tag {
			display: inline-block;
			padding: 8px 14px;
			font-size: 12px;
			letter-spacing: 1px;
			text-transform: uppercase;
			border-radius: 999px;
			background: rgba(34, 211, 238, 0.18);
			border: 1px solid rgba(34, 211, 238, 0.35);
			color: #67e8f9;
			margin-bottom: 18px;
		}

		.hero h1 {
			font-size: clamp(2rem, 5vw, 3rem);
			line-height: 1.15;
			margin-bottom: 14px;
		}

		.hero h1 .gradient {
			background: linear-gradient(90deg, var(--accent), var(--accent-2));
			-webkit-background-clip: text;
			-webkit-text-fill-color: transparent;
			background-clip: text;
			color: transparent;
		}

		.hero p {
			max-width: 680px;
			margin: 0 auto;
			color: var(--text-muted);
			font-size: 1rem;
		}

		.actions {
			margin-top: 22px;
			display: flex;
			justify-content: center;
			gap: 14px;
			flex-wrap: wrap;
		}

		.btn {
			border: none;
			cursor: pointer;
			padding: 11px 20px;
			border-radius: 12px;
			font-weight: 600;
			transition: transform 0.2s ease, box-shadow 0.2s ease, background-color 0.2s ease;
		}

		.btn-primary {
			background: linear-gradient(90deg, var(--accent), var(--accent-2));
			color: #0b1022;
			box-shadow: 0 10px 25px rgba(167, 139, 250, 0.35);
		}

		.btn-secondary {
			border: 1px solid var(--border);
			color: var(--text-main);
			background: rgba(255, 255, 255, 0.06);
		}

		.btn:hover {
			transform: translateY(-2px);
		}

		.todo-shell {
			padding: 0 30px 34px;
		}

		.form-row {
			display: flex;
			gap: 10px;
			margin-bottom: 16px;
		}

		.task-input {
			flex: 1;
			background: rgba(255, 255, 255, 0.08);
			border: 1px solid var(--border);
			color: var(--text-main);
			padding: 12px 14px;
			border-radius: 12px;
			outline: none;
		}

		.task-input::placeholder {
			color: var(--text-muted);
		}

		.task-list {
			list-style: none;
			display: flex;
			flex-direction: column;
			gap: 10px;
		}

		.task-item {
			display: flex;
			align-items: center;
			gap: 12px;
			padding: 14px 14px;
			background: var(--card-bg);
			border: 1px solid var(--border);
			border-radius: 14px;
		}

		.task-title {
			flex: 1;
			font-size: 0.98rem;
		}

		.task-title.done {
			text-decoration: line-through;
			color: var(--text-muted);
		}

		.icon-btn {
			border: 1px solid var(--border);
			background: rgba(255, 255, 255, 0.06);
			color: var(--text-main);
			border-radius: 10px;
			width: 34px;
			height: 34px;
			display: inline-flex;
			align-items: center;
			justify-content: center;
			cursor: pointer;
		}

		.icon-btn:hover {
			background: rgba(255, 255, 255, 0.14);
		}

		.icon-btn.delete {
			color: #fca5a5;
		}

		.status {
			margin-top: 12px;
			color: var(--text-muted);
			font-size: 0.9rem;
			min-height: 20px;
		}

		@media (max-width: 820px) {
			.hero {
				padding: 44px 24px 24px;
			}

			.todo-shell {
				padding: 0 16px 22px;
			}

			.form-row {
				flex-direction: column;
			}
		}
	</style>
</head>
<body>
	<main class="container">
		<section class="hero">
			<span class="tag">TODO</span>
			<h1><span class="gradient">Task Manager</span> Dashboard</h1>
			<p>
				Current tasks are loaded from your backend and SQLite database automatically.
			</p>
		</section>

		<section class="todo-shell">
			<div class="form-row">
				<input id="taskInput" class="task-input" type="text" placeholder="Write a new task...">
				<button id="addBtn" class="btn btn-primary" type="button">Add Task</button>
			</div>
			<ul id="tasksList" class="task-list"></ul>
			<div id="status" class="status"></div>
		</section>
	</main>

	<script>
		const API_BASE = '<%= request.getContextPath() %>/api/tasks';
		const tasksList = document.getElementById('tasksList');
		const taskInput = document.getElementById('taskInput');
		const addBtn = document.getElementById('addBtn');
		const statusEl = document.getElementById('status');

		function setStatus(message) {
			statusEl.textContent = message || '';
		}

		async function request(url, options) {
			const response = await fetch(url, options);
			if (!response.ok) {
				let errorText = 'Request failed';
				try {
					errorText = await response.text();
				} catch (error) {
					errorText = 'Request failed';
				}
				throw new Error(errorText);
			}
			return response;
		}

		function renderTasks(tasks) {
			tasksList.innerHTML = '';
			if (!tasks.length) {
				const empty = document.createElement('li');
				empty.className = 'task-item';
				empty.textContent = 'No tasks yet.';
				tasksList.appendChild(empty);
				return;
			}

			tasks.forEach((task) => {
				const item = document.createElement('li');
				item.className = 'task-item';

				const checkbox = document.createElement('input');
				checkbox.type = 'checkbox';
				checkbox.checked = !!task.completed;
				checkbox.addEventListener('change', () => toggleTask(task, checkbox.checked));

				const title = document.createElement('span');
				title.className = 'task-title' + (task.completed ? ' done' : '');
				title.textContent = task.title;

				const editBtn = document.createElement('button');
				editBtn.className = 'icon-btn';
				editBtn.title = 'Edit';
				editBtn.innerHTML = '<i class="bi bi-pencil"></i>';
				editBtn.addEventListener('click', () => editTask(task));

				const deleteBtn = document.createElement('button');
				deleteBtn.className = 'icon-btn delete';
				deleteBtn.title = 'Delete';
				deleteBtn.innerHTML = '<i class="bi bi-trash"></i>';
				deleteBtn.addEventListener('click', () => deleteTask(task.id));

				item.appendChild(checkbox);
				item.appendChild(title);
				item.appendChild(editBtn);
				item.appendChild(deleteBtn);
				tasksList.appendChild(item);
			});
		}

		async function loadTasks() {
			try {
				setStatus('Loading tasks...');
				const response = await request(API_BASE);
				const tasks = await response.json();
				renderTasks(tasks);
				setStatus('');
			} catch (error) {
				setStatus('Failed to load tasks.');
			}
		}

		async function addTask() {
			const title = taskInput.value.trim();
			if (!title) {
				setStatus('Task title is required.');
				return;
			}

			try {
				await request(API_BASE, {
					method: 'POST',
					headers: { 'Content-Type': 'application/json' },
					body: JSON.stringify({ title: title, completed: false })
				});
				taskInput.value = '';
				setStatus('Task added.');
				await loadTasks();
			} catch (error) {
				setStatus('Failed to add task.');
			}
		}

		async function toggleTask(task, completed) {
			try {
				await request(API_BASE + '/' + task.id, {
					method: 'PUT',
					headers: { 'Content-Type': 'application/json' },
					body: JSON.stringify({ title: task.title, completed: completed })
				});
				await loadTasks();
			} catch (error) {
				setStatus('Failed to update task.');
			}
		}

		async function editTask(task) {
			const newTitle = prompt('Update task title:', task.title);
			if (newTitle === null) {
				return;
			}

			const title = newTitle.trim();
			if (!title) {
				setStatus('Task title cannot be empty.');
				return;
			}

			try {
				await request(API_BASE + '/' + task.id, {
					method: 'PUT',
					headers: { 'Content-Type': 'application/json' },
					body: JSON.stringify({ title: title, completed: task.completed })
				});
				setStatus('Task updated.');
				await loadTasks();
			} catch (error) {
				setStatus('Failed to update task.');
			}
		}

		async function deleteTask(id) {
			try {
				await request(API_BASE + '/' + id, { method: 'DELETE' });
				setStatus('Task deleted.');
				await loadTasks();
			} catch (error) {
				setStatus('Failed to delete task.');
			}
		}

		addBtn.addEventListener('click', addTask);
		taskInput.addEventListener('keydown', function (event) {
			if (event.key === 'Enter') {
				addTask();
			}
		});

		loadTasks();
	</script>
</body>
</html>

#!/usr/bin/env node
// Minimal todo API - No dependencies, just Node built-ins
// Run with: node server.js

const http = require('http');
const PORT = 3000;

let todos = [
  { id: 1, text: 'Delete example-app/', completed: false },
  { id: 2, text: 'Add your own app', completed: false },
  { id: 3, text: 'Customize .claude/ for your conventions', completed: false }
];
let nextId = 4;

const server = http.createServer((req, res) => {
  // CORS for local development
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // Parse URL
  const url = new URL(req.url, `http://localhost:${PORT}`);
  const path = url.pathname;
  const id = path.split('/').filter(Boolean)[1];

  // Routes
  if (req.method === 'GET' && path === '/todos') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(todos));
  }
  else if (req.method === 'POST' && path === '/todos') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      const { text } = JSON.parse(body);
      const todo = { id: nextId++, text, completed: false };
      todos.push(todo);
      res.writeHead(201, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(todo));
    });
  }
  else if (req.method === 'PATCH' && path.startsWith('/todos/')) {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      const todo = todos.find(t => t.id === parseInt(id));
      if (todo) {
        const updates = JSON.parse(body);
        Object.assign(todo, updates);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(todo));
      } else {
        res.writeHead(404);
        res.end('Not found');
      }
    });
  }
  else if (req.method === 'DELETE' && path.startsWith('/todos/')) {
    const index = todos.findIndex(t => t.id === parseInt(id));
    if (index !== -1) {
      todos.splice(index, 1);
      res.writeHead(204);
      res.end();
    } else {
      res.writeHead(404);
      res.end('Not found');
    }
  }
  else {
    res.writeHead(404);
    res.end('Not found');
  }
});

server.listen(PORT, () => {
  console.log(`Todo API running on http://localhost:${PORT}`);
  console.log('Endpoints:');
  console.log('  GET    /todos     - List all todos');
  console.log('  POST   /todos     - Create todo');
  console.log('  PATCH  /todos/:id - Update todo');
  console.log('  DELETE /todos/:id - Delete todo');
});

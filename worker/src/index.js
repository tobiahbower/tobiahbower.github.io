import { createRetriever } from './retriever.js';
import { buildMessages, generateAnswer, validateUserMessage } from './llm.js';

const KNOWLEDGE_CACHE_TTL_MS = 5 * 60 * 1000;
let knowledgeCache = {
  fetchedAt: 0,
  text: '',
  json: null,
};

function corsHeaders(origin, env) {
  const allowed = (env.ALLOWED_ORIGINS || 'https://tobiahbower.github.io,http://localhost:8000,http://127.0.0.1:8000')
    .split(',')
    .map((value) => value.trim())
    .filter(Boolean);

  const headers = {
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Max-Age': '86400',
  };

  if (origin && allowed.includes(origin)) {
    headers['Access-Control-Allow-Origin'] = origin;
  }

  return headers;
}

function jsonResponse(body, status, origin, env) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders(origin, env),
    },
  });
}

async function fetchKnowledge(env) {
  const now = Date.now();
  if (knowledgeCache.text && now - knowledgeCache.fetchedAt < KNOWLEDGE_CACHE_TTL_MS) {
    return knowledgeCache;
  }

  const knowledgeUrl = env.KNOWLEDGE_URL || 'https://tobiahbower.github.io/data/knowledge.md';
  const knowledgeJsonUrl = env.KNOWLEDGE_JSON_URL || 'https://tobiahbower.github.io/data/knowledge.json';

  const [mdResponse, jsonResponse_] = await Promise.all([
    fetch(knowledgeUrl),
    fetch(knowledgeJsonUrl),
  ]);

  if (!mdResponse.ok) {
    throw new Error(`Failed to fetch knowledge.md (${mdResponse.status})`);
  }

  const text = await mdResponse.text();
  let json = null;

  if (jsonResponse_.ok) {
    json = await jsonResponse_.json();
  }

  knowledgeCache = {
    fetchedAt: now,
    text,
    json,
  };

  return knowledgeCache;
}

async function handleChat(request, env, origin) {
  let payload;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse({ error: 'Invalid JSON body.' }, 400, origin, env);
  }

  const validation = validateUserMessage(payload.message || '', env);
  if (!validation.ok) {
    return jsonResponse({ error: validation.error }, 400, origin, env);
  }

  const knowledge = await fetchKnowledge(env);
  const mode = env.RETRIEVAL_MODE || knowledge.json?.retrieval_mode || 'full';
  const retriever = createRetriever(mode);

  const retrieval =
    mode === 'vector'
      ? await retriever.retrieve(validation.message, knowledge.text, env, knowledge.json)
      : await retriever.retrieve(validation.message, knowledge.text);

  const messages = buildMessages(retrieval.context, validation.message);
  const answer = await generateAnswer(env, messages);

  return jsonResponse(
    {
      answer,
      mode,
      sources: retrieval.sources,
    },
    200,
    origin,
    env
  );
}

export default {
  async fetch(request, env) {
    const origin = request.headers.get('Origin');
    const url = new URL(request.url);

    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: corsHeaders(origin, env),
      });
    }

    if (url.pathname === '/api/health') {
      return jsonResponse({ ok: true }, 200, origin, env);
    }

    if (url.pathname === '/api/chat' && request.method === 'POST') {
      try {
        return await handleChat(request, env, origin);
      } catch (error) {
        console.error(error);
        return jsonResponse(
          { error: 'Chat request failed.', details: error.message },
          500,
          origin,
          env
        );
      }
    }

    return jsonResponse({ error: 'Not found' }, 404, origin, env);
  },
};

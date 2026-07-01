const SYSTEM_PROMPT = `You are a helpful assistant for Tobiah Bower's professional portfolio website.

Rules:
- Answer ONLY using the provided context about Tobiah Bower.
- If the answer is not in the context, say you don't have that information and suggest checking his resume or LinkedIn.
- Be concise, professional, and friendly.
- Do not invent employers, projects, dates, or skills.
- Prefer recent experience from 2024 onward when relevant.`;

/**
 * @param {string} context
 * @param {string} question
 * @returns {{ role: string, content: string }[]}
 */
export function buildMessages(context, question) {
  return [
    { role: 'system', content: SYSTEM_PROMPT },
    {
      role: 'user',
      content: `Context:\n${context}\n\nQuestion: ${question}`,
    },
  ];
}

/**
 * @param {object} env
 * @param {{ role: string, content: string }[]} messages
 */
export async function generateAnswer(env, messages) {
  const model = env.LLM_MODEL || '@cf/meta/llama-3.1-8b-instruct';

  const response = await env.AI.run(model, {
    messages,
    max_tokens: Number(env.LLM_MAX_TOKENS || 512),
    temperature: Number(env.LLM_TEMPERATURE || 0.2),
  });

  const answer =
    response?.response ??
    response?.result?.response ??
    response?.choices?.[0]?.message?.content;

  if (!answer) {
    throw new Error('LLM returned an empty response');
  }

  return String(answer).trim();
}

/**
 * Optional guardrails — extend with topic filters, regex blocks, etc.
 * @param {string} message
 * @param {object} env
 */
export function validateUserMessage(message, env) {
  const maxLength = Number(env.MAX_MESSAGE_LENGTH || 500);
  const trimmed = message.trim();

  if (!trimmed) {
    return { ok: false, error: 'Message cannot be empty.' };
  }

  if (trimmed.length > maxLength) {
    return { ok: false, error: `Message must be ${maxLength} characters or fewer.` };
  }

  return { ok: true, message: trimmed };
}

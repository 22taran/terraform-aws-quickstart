import { getAccessToken } from './auth';

const API_BASE = import.meta.env.VITE_API_URL || '';

async function request(path, options = {}) {
  const base = API_BASE.replace(/\/$/, '');
  const pathNorm = path.startsWith('/') ? path : `/${path}`;
  const url = path.startsWith('http') ? path : `${base}${pathNorm}`;
  const headers = { 'Content-Type': 'application/json', ...options.headers };

  try {
    const token = await getAccessToken();
    if (token) headers.Authorization = `Bearer ${token}`;
  } catch {
    // No token - public request (e.g. track)
  }

  const res = await fetch(url, { ...options, headers });
  const data = await res.json().catch(() => ({}));

  if (!res.ok) {
    throw new Error(data.error || data.message || `Request failed: ${res.status}`);
  }
  return data;
}

export const api = {
  get: (path) => request(path),
  post: (path, body) => request(path, { method: 'POST', body: JSON.stringify(body) }),
  patch: (path, body) => request(path, { method: 'PATCH', body: JSON.stringify(body) }),
  delete: (path) => request(path, { method: 'DELETE' }),
};

export function trackShipment(trackingNumber) {
  return request(`/api/shipments/track/${encodeURIComponent(trackingNumber)}`);
}

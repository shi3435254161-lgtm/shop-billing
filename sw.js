const CACHE_NAME = 'shop-billing-v2';
const ASSETS = [
  './',
  './index.html',
  './manifest.json'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  // API请求和CDN资源走网络
  if (e.request.url.includes('supabase.co') ||
      e.request.url.includes('cdn.jsdelivr.net') ||
      e.request.url.includes('fonts.googleapis.com') ||
      e.request.url.includes('deepseek.com')) {
    e.respondWith(fetch(e.request));
    return;
  }
  // 本地资源：网络优先，失败用缓存
  e.respondWith(
    fetch(e.request).then(response => {
      if (response.ok) {
        const clone = response.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(e.request, clone));
      }
      return response;
    }).catch(() => caches.match(e.request))
  );
});

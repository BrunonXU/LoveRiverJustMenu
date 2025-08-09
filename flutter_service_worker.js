'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "4195f5692c7d0e399db615fd5e5b3d75",
".git/config": "920a11de313bfb8d93d81f4a3a5b71b6",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "4cf2d64e44205fe628ddd534e1151b58",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "fe49c1d868a671a6450757e73e76cdb8",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "783422cce2759826cc8392f135cab76c",
".git/logs/refs/heads/master": "783422cce2759826cc8392f135cab76c",
".git/objects/05/c5d24e2a6b7e791b7f84f1d9f2f7b56ccbe638": "d886ad57504404d4f07d472137a6f8f0",
".git/objects/0a/79a57549fb344fc164f27c2eff85481f9b37a8": "0f8f5f7a095c18667d79730e834757e5",
".git/objects/15/3160986373d0fac7a535d38b38ef2bf10521bb": "8fde4eb33272b689a95b3a0511e0c972",
".git/objects/1a/d7683b343914430a62157ebf451b9b2aa95cac": "94fdc36a022769ae6a8c6c98e87b3452",
".git/objects/1d/cbb0ddb3af35e728759be15d14e6849eca8cbb": "3473061643a7f63450ee094b203ec0f5",
".git/objects/1e/73b4a33dae84d471bc033d6ccecbaf782b91af": "3216790f2924bd87a0fef3a606ae81ef",
".git/objects/1f/56befa8c8bd13b9365aad018727e58bb85744e": "afab55e685ed30c748c3023549c0a28e",
".git/objects/27/727f9643fc29560639f42f55baaf465b40be79": "65cf5d262163551d161bba43b317ff64",
".git/objects/27/d6a0b0751dc908110d952998da2029f6425cdb": "faed6ca4725b627eb532413808ffe6ad",
".git/objects/32/394e2226428fc19e0a56c25f4293d026cd96b5": "cb80bb79d957346f1ffbbcdb74144a2f",
".git/objects/33/00536d9f802765ff61774d5c3d590dfae9455e": "dde922dbebe5679d0d5baf4bd1c9ab2f",
".git/objects/3a/bf18c41c58c933308c244a875bf383856e103e": "30790d31a35e3622fd7b3849c9bf1894",
".git/objects/3d/594d0fdb92852230c09f548bcdeb923df479f8": "5659c66bf36532b97a0840dae94b2ac5",
".git/objects/41/797dc9108e90175162c835485bb5452499823c": "7bb8968b4c6130c803a0e09f8c7d17d0",
".git/objects/43/8c13687145d1cf83116ac41a683cca870f9fe7": "aadddff86942db3d1474ab7a8bc60f31",
".git/objects/4c/51fb2d35630595c50f37c2bf5e1ceaf14c1a1e": "a20985c22880b353a0e347c2c6382997",
".git/objects/50/96f5607df97255b67d572daf78d9007054708f": "eab32b3cfa1ac998cccaef0d33b5d963",
".git/objects/53/18a6956a86af56edbf5d2c8fdd654bcc943e88": "a686c83ba0910f09872b90fd86a98a8f",
".git/objects/53/3d2508cc1abb665366c7c8368963561d8c24e0": "4592c949830452e9c2bb87f305940304",
".git/objects/53/f38dbd458f12229fe6bd1e970209f662b389d5": "bac4dc214434542e426a02bfd322ef38",
".git/objects/5a/0a3ad9e5d9f9ef7d482f8bfede8068113c3c91": "d6dba11d688a74c12068ea997b37d474",
".git/objects/62/4d34e922ac4adf5998d774d2bc3621e89dede7": "ea47bfcffc296101811e0f102035413f",
".git/objects/67/1967badeb253d30789751a6b1585d845ede023": "bdf73786c9e2f26456ed269336efc289",
".git/objects/67/999ab782a1ca7050480395f9ea27a8ec35f3f1": "7d2ccd798a24b0c4bf2fe8b98e18722f",
".git/objects/6c/c3f8764e307e2339950d4d7542abb60133c2d5": "ff7b5b2776107e15c3da4e18684d4f54",
".git/objects/6c/f760cfda7d761c1e138f1f0e697dc00f9ef63e": "0ce258ade5ce14f0e02e4fa19d3801d6",
".git/objects/6f/76f46e7a1b14bbfece224cddd9ba0c3faed32e": "73d7e793096200142bfa5c4febd47680",
".git/objects/6f/fcd01ef809b6216dd33f843656f3f917b14305": "edc9cd91f7824e41b94b0e00f393fcc8",
".git/objects/70/a234a3df0f8c93b4c4742536b997bf04980585": "d95736cd43d2676a49e58b0ee61c1fb9",
".git/objects/71/0c5d29e2055a076470aca143d3b092da0bfac6": "75383e724bb28760abd0018c14189966",
".git/objects/73/c63bcf89a317ff882ba74ecb132b01c374a66f": "6ae390f0843274091d1e2838d9399c51",
".git/objects/8d/c22d03a7819572733cf542a5116914baf09e4b": "768335e4a0c0d1aab526a4b2c04cdd20",
".git/objects/8e/3c7d6bbbef6e7cefcdd4df877e7ed0ee4af46e": "025a3d8b84f839de674cd3567fdb7b1b",
".git/objects/9b/d3accc7e6a1485f4b1ddfbeeaae04e67e121d8": "784f8e1966649133f308f05f2d98214f",
".git/objects/9f/babfccbfd2359a138f8a34006b4c6e999d1e05": "9a2fe033af20d5ea4f165f8e511a0cd0",
".git/objects/a8/2656ce093f416f3e0f1a2c78c0f7654992720a": "98d76e81cccbc440523f93028ea3ec00",
".git/objects/af/7ca36e1cbfa0c746e60ac4ccf9efa8df03443b": "fbd4fbeb7a04c82b4bd490254dff17c1",
".git/objects/b9/6a5236065a6c0fb7193cb2bb2f538b2d7b4788": "4227e5e94459652d40710ef438055fe5",
".git/objects/c7/37b9f6f146b86d8e7d379cfb3f3f6e3cc590b0": "f258700db45fc03572644c6b4f33cff9",
".git/objects/c8/08fb85f7e1f0bf2055866aed144791a1409207": "92cdd8b3553e66b1f3185e40eb77684e",
".git/objects/cb/741aeb246dedff793acf7d481bf3ed584b27bd": "f23605c2604e70e39233caeedbc282f8",
".git/objects/d2/abaeb00045201fcdf359c7f87f17bacc1d5c5d": "46433f13570a88653c8a3ac147d79f48",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/da/19fc72028dbf753181cf6fc1d6e4c3ad877409": "6413ec39c7654f57640cfc751ce4c7c8",
".git/objects/dc/11fdb45a686de35a7f8c24f3ac5f134761b8a9": "761c08dfe3c67fe7f31a98f6e2be3c9c",
".git/objects/e0/7ac7b837115a3d31ed52874a73bd277791e6bf": "74ebcb23eb10724ed101c9ff99cfa39f",
".git/objects/e2/bff44a09238004faed1fa1bf38b7b989e62478": "9d5313cfb44b26e596bc27cfa614a920",
".git/objects/eb/e6897a5f0439322666170f79246e1ea017f877": "87f305026a78df8e2b6e93abdad6839d",
".git/objects/ee/8f9aac8283a8557576cca32e3c842bd64aaf1d": "a3b2cae991ce8651ce0f91553c9de1fb",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/fe/e343d9eec61d48cf6cee2d7fbf39cdc54e47be": "649b9b3700c4a87a5ac37b89fbcb2f71",
".git/refs/heads/master": "43f2a1e59f11345e6411d1b589b7cb40",
"assets/AssetManifest.bin": "4e5468d7f939b5c054e531fd1ce025f6",
"assets/AssetManifest.bin.json": "ca03d32c319286140a0839781990df3c",
"assets/AssetManifest.json": "a01cd110ba0c3ea38ea419bc82427e76",
"assets/assets/data/sample_recipes.json": "c66ca327d74e8fed701c24381e50336a",
"assets/assets/images/pixel_logo.webp": "d1e0723cfaf28109ddc64554b3ac33fa",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/fonts/MaterialIcons-Regular.otf": "1ec0b406f48c37ab1326f09cf24c8168",
"assets/NOTICES": "cf842d837c8ca24de3ddb972eff5df8d",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"CNAME": "f395819fab7491bc9b9ffad4ebde51e4",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "039e48ea895ef01abc4385e4e94e267a",
"icons/Recipe%20Icons.webp": "6a676d6a8ce8de5b1211cad179b99007",
"index.html": "591c589e18925b767ca50b5ecfac3fe4",
"/": "591c589e18925b767ca50b5ecfac3fe4",
"main.dart.js": "33ca2f5b7b7564cda7b0f0c6139f8cab",
"manifest.json": "7f092b4e542255f4f565632f8fca9ce6",
"version.json": "a228ddb54370277ff0ffc80b88247165"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}

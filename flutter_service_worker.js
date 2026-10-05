'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"assets/assets/config.json": "9e71bb9da985000e2b6b569a184f6779",
"assets/assets/images/meditation_image.jpg": "e182a25028c129b6115ab32be2c329c7",
"assets/assets/images/yoga/corpse-pose.jpg": "f9906753dd90f7632e447b1b44757b93",
"assets/assets/images/yoga/shoulderstand.png": "5fbb8125454a20f8d21a23cd760d30be",
"assets/assets/images/yoga/downward-facingdog.png": "77c45423f929c21a4b7bf69dd9044b6e",
"assets/assets/images/yoga/seatedforward.jpg": "4d267dfc00ad4366a2692cc1295aa0f7",
"assets/assets/images/yoga/plankpose.png": "2e845c12fa741d15b0b16580e3b01ed3",
"assets/assets/images/yoga/twist.jpg": "e93f7c3fc10b1b54d853ef5c1e027fda",
"assets/assets/images/yoga/Legs-Up-the-Wall.png": "c39e0bb3c81b2c345b27d7a9a832a874",
"assets/assets/images/yoga/boundangle.jpg": "78e5c925f9edb3e3023f5f69872aed93",
"assets/assets/images/yoga/bridgepose.png": "99c7ed22a26b8a1f51b984412a731db6",
"assets/assets/images/rest.jpg": "33e98f21f99214fb43ae5b1cd1299358",
"assets/assets/images/default.jpg": "7bf2f4a1d80daf34d1a90f2b153e01bf",
"assets/assets/images/upper/plank.webp": "8191cb5a86e4b413244ffec7c7578194",
"assets/assets/images/upper/Plank_jacks.jpg": "c2beaf83d2551dc2908e13041ce64113",
"assets/assets/images/upper/superman.jpg": "4dcb3cba36ba2ad2cbbba7beecdbe64f",
"assets/assets/images/upper/superman.webp": "f657fd47ea74bd6359a27226372e8d5c",
"assets/assets/images/upper/modified-pushups.jpg": "9054f3a3939684487ea96156eb5120c9",
"assets/assets/images/upper/plank.jpg": "4dcb3cba36ba2ad2cbbba7beecdbe64f",
"assets/assets/images/upper/PlankToDolphinPose.jpg": "9a2c6ccab0eca17ef7111c12f1f17242",
"assets/assets/images/upper/Plank_Ups.jpg": "a69dab2b687e30b4a46dbf29343091b9",
"assets/assets/images/upper/VUp.jpg": "ee358e3a455f04c9e7750baed55b2be3",
"assets/assets/images/lower/side_lunge.gif": "31304ca889221bcf2aeea755eed5536b",
"assets/assets/images/lower/squat.gif": "0610821b7eafa8ba7ba60d5418c087bd",
"assets/assets/images/lower/glute_bridge.gif": "6d6f9735eea54676070ad21c69b099a5",
"assets/assets/images/lower/side_lunge.jpg": "589619e7f463ca123a49b8c59f2e3d2f",
"assets/assets/images/lower/squat.jpg": "b7f7d1e0cfd55b8f3f81a959726bfb4f",
"assets/assets/images/lower/lunge.gif": "24d5161adf8c0c33ff334caa2503d350",
"assets/assets/images/lower/glute_bridge.jpg": "318105658424cd3b248a04d714a52852",
"assets/assets/images/lower/lunge.jpg": "a0c48e845d1576bb0b9ed096198d8c02",
"assets/assets/sounds/guide_bodyscan.mp3": "67668c03177bbbfa907331a570809fc5",
"assets/assets/sounds/cue_exhale.mp3": "634d19fc4607f6cfd9f92d2df1a9f30c",
"assets/assets/sounds/scan_08.mp3": "b13ff882618633d461375b7b2aa04993",
"assets/assets/sounds/scan_02.mp3": "ace9b15efb6f4c7dcaa998ac6769c2e4",
"assets/assets/sounds/scan_04.mp3": "3d4b3a18e54ac6e73928b81940cfeabe",
"assets/assets/sounds/guide_yoga.mp3": "2e05bc3fde9bc66519db544de2740874",
"assets/assets/sounds/start.mp3": "cbb6064fbb50de6741764eab5422cb64",
"assets/assets/sounds/scan_03.mp3": "bb0b38badba65c6c659944139221ea45",
"assets/assets/sounds/scan_06.mp3": "a3ef9929d89e5095d88c528f00538d66",
"assets/assets/sounds/scan_01.mp3": "6c9e840f18572a7133e085147d68bffd",
"assets/assets/sounds/guide_breath.mp3": "85591bf300cbaa180c97f2ad20dc4d1e",
"assets/assets/sounds/scan_07.mp3": "93c21b1ddc9acaed487b832b2338cb36",
"assets/assets/sounds/scan_05.mp3": "0f1fe7a94206bd3c61b0a8240ee79941",
"assets/assets/sounds/guide_loving.mp3": "83259fedee2eb9e02710f97c954a8acc",
"assets/assets/sounds/cue_inhale.mp3": "14b7d256efc7ea9da0d3d63a4b13b1fe",
"assets/assets/sounds/guide_workout.mp3": "fad664276f4ea9dd5d04b2bd0f17a6cd",
"assets/assets/sounds/cue_hold.mp3": "29b43da7378cea1738ad7d74a587e5fc",
"assets/assets/sounds/gong.mp3": "3222f2d201226c104863b65fb0e75046",
"assets/assets/sounds/guide_eating.mp3": "f630679a73349c95eb23dead896596a7",
"assets/assets/sounds/complete.mp3": "ea632cd040596b717f4429cae8cd1fd3",
"assets/assets/sounds/rest.mp3": "f9c852cdc216b1bb735ee3366a93e0b8",
"assets/assets/sounds/scan_09.mp3": "f0786426ba96a8a35c7ba0f581608998",
"assets/assets/sounds/guide_walking.mp3": "cf02d8505b32e5aac0a533a2309e7031",
"assets/assets/sounds/guide_pranayama.mp3": "ee6f453767fd19e71df526519ac71681",
"assets/assets/tasks.json": "27812990367f28a455daa04ae9471597",
"assets/AssetManifest.bin.json": "d1b2095529658f41dec411e535644bd5",
"assets/AssetManifest.json": "44cb9fbf321f7c64e73a2e28f9b30a77",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/NOTICES": "531b4ff5a2857bccfd59aaad9f7d9a06",
"assets/AssetManifest.bin": "f30c8904e9f92fa6a1d3cc60d0c22b46",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "d4d1d014b60596724dc189d40c3ae6f2",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"index.html": "0e829b5ed59d02085a41519b32441bf8",
"/": "0e829b5ed59d02085a41519b32441bf8",
"main.dart.js": "3d25c242a2f0eb41357e4141c195e6ac",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"manifest.json": "0c719fed91970f7cebbff7b84c4bb705",
"version.json": "b3e63ec75d383b6e944ccbc945bdd2b6",
"flutter_bootstrap.js": "de939b5d9f2d2da37f95aca7dccb1d26"};
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

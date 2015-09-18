# Bandcamp [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis] [![Coverage Status][coveralls-image]][coveralls]

> scrape the [bandcamp.com](https://bandcamp.com/).

## Installation

```bash
$ npm install band-camp --save
```

# API

## search(words,beginPage=1,endPage=10) -> Promise(results)

[fetch search results](https://bandcamp.com/search?q=flashygoodness) between the `beginPage` to `endPage`.

```js
bandcamp.search('flashygoodness')
.then(function(results){
  // takes a few minutes...
  
  console.log(results);
  // [
  //   {
  //     "type": "ARTIST",
  //     "url": "http://store.flashygoodness.com",
  //     "heading": "flashygoodness",
  //     "genre": "Electronic",
  //     "tags": [
  //       "instrumental",
  //       "flashygoodness",
  //       "soundtrack",
  //       "Electronic"
  //     ]
  //   },
  //   {
  //     "type": "ALBUM",
  //     "url": "http://store.flashygoodness.com/album/tower-of-heaven-original-soundtrack",
  //     "heading": "Tower of Heaven (Original Soundtrack)",
  //     "subhead": "by flashygoodness",
  //     "released": "2010-07-24",
  //     "tags": [
  //       "vgm",
  //       "askiisoft",
  //       "electronic",
  //       "United States",
  //       "instrumental",
  //       "game",
  //       "soundtrack",
  //       "chiptune",
  //       "flashygoodness",
  //       "video game music",
  //       "Electronic"
  //     ]
  //   },
  //   (more results...)
  // ]
});
```

## fetch(tag,beginPage=1,endPage=10,sortBy='pop') -> Promise(albums)

shorthand of `.fetchSummries` and `.fetchAlbums`

```js
bandcamp.fetch('vgm')
.then(function(albums){
  // takes a few minutes...
  
  console.log(albums);
  // [
  //   {
  //     "url": "http://dbsoundworks.bandcamp.com/album/crypt-of-the-necrodancer-ost",
  //     "title": "Crypt of the Necrodancer OST",
  //     "author": "Danny Baranowsky",
  //     "license": "copyright",
  //     "artwork": "http://f1.bcbits.com/img/a2187335077_10.jpg",
  //     "thumbnail": "http://f1.bcbits.com/img/a2187335077_16.jpg",
  //     "fanCount": 630,
  //     "tracks": [
  //       {
  //         "title": "Tombtorial (Tutorial)",
  //         "url": "http://popplers5.bandcamp.com/download/track?enc=mp3-128&fsig=663eefe823139816899fcf0746ff29c7&id=415514545&stream=1&ts=1439820305.0",
  //         "time": "03:18"
  //       },
  //       ...
  //     ]
  //   },
  //   (... more 399 albums... (40 album * 10 page - 1))
  // ]
});
```

## fetchSummries(tag,beginPage=1,endPage=10,sortBy='pop') -> Promise(summries)

[fetch summries](https://bandcamp.com/tag/vgm?page=1&sort_field=pop) between the `beginPage` to `endPage`.

```js
bandcamp.fetchSummries('vgm').then(function(summries){
  console.log(summries);
  // [
  //  {
  //    "url": "http://dbsoundworks.bandcamp.com/album/crypt-of-the-//necrodancer-ost",
  //    "thumbnail": "https://f1.bcbits.com/img/a2187335077_11.jpg",
  //    "title": "Crypt of the Necrodancer OST",
  //    "author": "Danny Baranowsky"
  //  },
  //
  //  (... more 399 summries... (40 album * 10 page - 1))
  // ]
});
```

## fetchAlbums(summriesOrUrls) -> Promise(albums)

[fetch album](https://dbsoundworks.bandcamp.com/album/crypt-of-the-necrodancer-ost) pages.

```js
bandcamp.fetchAlbums([
  'http://dbsoundworks.bandcamp.com/album/crypt-of-the-necrodancer-ost',
]).then(function(albums){
  console.log(albums);
  // [
  //   {
  //     "url": "http://dbsoundworks.bandcamp.com/album/crypt-of-the-necrodancer-ost",
  //     "title": "Crypt of the Necrodancer OST",
  //     "author": "Danny Baranowsky",
  //     "license": "copyright",
  //     "artwork": "http://f1.bcbits.com/img/a2187335077_10.jpg",
  //     "thumbnail": "http://f1.bcbits.com/img/a2187335077_16.jpg",
  //     "fanCount": 630,
  //     "tracks": [
  //       {
  //         "title": "Tombtorial (Tutorial)",
  //         "url": "http://popplers5.bandcamp.com/download/track?enc=mp3-128&fsig=663eefe823139816899fcf0746ff29c7&id=415514545&stream=1&ts=1439820305.0",
  //         "time": "03:18"
  //       },
  //       ...
  //     ]
  //   }
  // ]
});
```

```js
bandcamp.fetchSummries('vgm')
.then(function(summaries){
  return bandcamp.fetchAlbums(summaries);
})
.then(function(albums){
  // takes a few minutes...
  
  console.log(albums);
  // [
  //   {
  //     "url": "http://dbsoundworks.bandcamp.com/album/crypt-of-the-necrodancer-ost",
  //     "title": "Crypt of the Necrodancer OST",
  //     "author": "Danny Baranowsky",
  //     "license": "copyright",
  //     "artwork": "http://f1.bcbits.com/img/a2187335077_10.jpg",
  //     "thumbnail": "http://f1.bcbits.com/img/a2187335077_16.jpg",
  //     "fanCount": 630,
  //     "tracks": [
  //       {
  //         "title": "Tombtorial (Tutorial)",
  //         "url": "http://popplers5.bandcamp.com/download/track?enc=mp3-128&fsig=663eefe823139816899fcf0746ff29c7&id=415514545&stream=1&ts=1439820305.0",
  //         "time": "03:18"
  //       },
  //       ...
  //     ]
  //   },
  //   (... more 399 albums... (40 album * 10 page - 1))
  // ]
});
```

License
---
[MIT][License]

[License]: http://59naga.mit-license.org/

[sauce-image]: http://soysauce.berabou.me/u/59798/band-camp.svg
[sauce]: https://saucelabs.com/u/59798
[npm-image]:https://img.shields.io/npm/v/band-camp.svg?style=flat-square
[npm]: https://npmjs.org/package/band-camp
[travis-image]: http://img.shields.io/travis/59naga/band-camp.svg?style=flat-square
[travis]: https://travis-ci.org/59naga/band-camp
[coveralls-image]: http://img.shields.io/coveralls/59naga/band-camp.svg?style=flat-square
[coveralls]: https://coveralls.io/r/59naga/band-camp?branch=master

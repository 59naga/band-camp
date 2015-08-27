# Dependencies
bandcamp= require '../src'

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 50000

# Specs
describe 'bandcamp',->
  it '.fetch',(done)->
    length= 40

    bandcamp.fetch 'vgm',1,1
    .then (albums)->
      expect(albums.length).toBe length

      album= albums[length-1]
      expect(album.url).toBeTruthy()
      expect(album.title).toBeTruthy()
      expect(album.author).toBeTruthy()
      expect(album.license).toBeTruthy()
      expect(album.artwork).toBeTruthy()
      expect(album.thumbnail).toBeTruthy()
      expect(album.fanCount).toBeGreaterThan 0
      expect(album.tracks.length).toBeGreaterThan 0

      done()

  it '.fetchSummaries -> .fetchAlbums',(done)->
    length= 1

    bandcamp.fetchSummaries 'vgm',1,1
    .then (summaries)->
      summaries.length= length# mangle for test

      bandcamp.fetchAlbums summaries

    .then (albums)->
      expect(albums.length).toBe length

      album= albums[length-1]
      expect(album.url).toBeTruthy()
      expect(album.title).toBeTruthy()
      expect(album.author).toBeTruthy()
      expect(album.license).toBeTruthy()
      expect(album.artwork).toBeTruthy()
      expect(album.thumbnail).toBeTruthy()
      expect(album.fanCount).toBeGreaterThan 0
      expect(album.tracks.length).toBeGreaterThan 0

      done()

  it '.fetchSummaries',(done)->
    bandcamp.fetchSummaries 'vgm'
    .then (summaries)->
      length= 400# 40 * 10

      expect(summaries.length).toBe length

      summary= summaries[length-1]
      expect(summary.url).toBeTruthy()
      expect(summary.thumbnail).toBeTruthy()
      expect(summary.title).toBeTruthy()
      expect(summary.author).toBeTruthy()

      done()

  it '.fetchAlbums',(done)->
    bandcamp.fetchAlbums [
      'https://2mellomakes.bandcamp.com/album/chrono-jigga'
    ]
    .then (albums)->
      {url,title,author,license,artwork,thumbnail,fanCount,tracks}= albums[0]

      expect(url).toBe 'https://2mellomakes.bandcamp.com/album/chrono-jigga'
      expect(title).toBe 'Chrono Jigga'
      expect(author).toBe '2 Mello'
      expect(license).toBe 'by-nc'
      expect(artwork).toBe 'https://f1.bcbits.com/img/a2173525289_10.jpg'
      expect(thumbnail).toBe 'https://f1.bcbits.com/img/a2173525289_16.jpg'
      expect(fanCount).toBe 0

      expect(tracks.length).toBe 12
      expect(tracks[0].title).toBe 'Intro'
      expect(tracks[0].url).toMatch 'http://popplers5.bandcamp.com/download/track'
      expect(tracks[0].time).toBe '00:19'

      expect(tracks[11].title).toBe 'Outro'
      expect(tracks[11].url).toMatch 'http://popplers5.bandcamp.com/download/track'
      expect(tracks[11].time).toBe '01:07'

      done()

  describe '.search',->
    it 'ARTIST',(done)->
      bandcamp.search 'aivi-surasshu',1,1
      .then (results)->
        result= results[0]

        expect(Object.keys result).toEqual ['type','url','heading','subhead','genre','tags']
        expect(result.type).toBe 'ARTIST'
        expect(result.url).toBe 'http://aivi-surasshu.bandcamp.com'
        expect(result.heading).toBe 'aivi & surasshu'
        expect(result.subhead).toBe 'San Francisco, California'
        expect(result.genre).toBe 'Jazz'
        
        # order is unstable
        expect(result.tags).toContain 'chiptune'
        expect(result.tags).toContain 'electronic'
        expect(result.tags).toContain 'Jazz'
        expect(result.tags).toContain 'videogame'
        expect(result.tags).toContain 'prog'
        expect(result.tags).toContain 'piano'

        done()

    it 'ALBUM',(done)->
      bandcamp.search 'birth:Daydream',1,1
      .then (results)->
        result= results[0]

        expect(Object.keys result).toEqual ['type','url','heading','subhead','released','tags']
        expect(result.type).toBe 'ALBUM'
        expect(result.url).toBe 'http://ry-ha.bandcamp.com/album/birth-daydream'
        expect(result.heading).toBe 'birth:Daydream'
        expect(result.subhead).toBe 'by ry_ha'
        expect(result.released).toBe '2012-08-15'
        expect(result.tags).toEqual ['Minimal','Noise','Japan','Ambient','Electronica','Electronic']

        done()

    it 'TRACK',(done)->
      bandcamp.search 'Kiyoshi Kono Yoru/Silent Night',1,1
      .then (results)->
        result= results[0]

        expect(Object.keys result).toEqual ['type','url','heading','subhead','released','tags']
        expect(result.type).toBe 'TRACK'
        expect(result.url).toBe 'http://thehorribleholidayensemble.bandcamp.com/track/kiyoshi-kono-yoru-silent-night'
        expect(result.heading).toBe 'Kiyoshi Kono Yoru/Silent Night'
        expect(result.subhead).toBe 'from VOCALOID Christmas 2012 by VOCALOID'
        expect(result.released).toBe '2012-12-25'
        expect(result.tags).toEqual ['holiday','Christmas']

        done()

    it 'FAN',(done)->
      bandcamp.search 'vocaloidict',1,1
      .then (results)->
        result= results[0]

        expect(Object.keys result).toEqual ['type','url','heading','genre']
        expect(result.type).toBe 'FAN'
        expect(result.url).toBe 'http://bandcamp.com/vocaloidict'
        expect(result.heading).toBe 'vocaloidict'
        expect(result.genre).toBe 'Electronic'

        done()

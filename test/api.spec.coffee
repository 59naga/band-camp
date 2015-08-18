# Dependencies
bandcamp= require '../src'

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 50000

# Specs
describe 'bandcamp',->
  it '.fetchSummaries -> .fetchAlbums',(done)->
    length= 1

    bandcamp.fetchSummaries 'vgm'
    .then (summaries)->
      summaries.length= length# mangle for test

      bandcamp.fetchAlbums summaries
      .then (albums)->
        expect(albums.length).toBe length
        expect(albums[length-1].url).toBeTruthy()
        expect(albums[length-1].title).toBeTruthy()
        expect(albums[length-1].author).toBeTruthy()
        expect(albums[length-1].license).toBeTruthy()
        expect(albums[length-1].artwork).toBeTruthy()
        expect(albums[length-1].thumbnail).toBeTruthy()
        expect(albums[length-1].tracks.length).toBeGreaterThan 0

        done()

  it '.fetchSummaries',(done)->
    bandcamp.fetchSummaries 'vgm'
    .then (summaries)->
      length= 400# 40 * 10

      expect(summaries.length).toBe length
      expect(summaries[length-1].url).toBeTruthy()
      expect(summaries[length-1].thumbnail).toBeTruthy()
      expect(summaries[length-1].title).toBeTruthy()
      expect(summaries[length-1].author).toBeTruthy()

      done()

  it '.fetchAlbums',(done)->
    bandcamp.fetchAlbums [
      'https://2mellomakes.bandcamp.com/album/chrono-jigga'
    ]
    .then (albums)->
      {url,title,author,license,artwork,thumbnail,tracks}= albums[0]

      expect(url).toBe 'https://2mellomakes.bandcamp.com/album/chrono-jigga'
      expect(title).toBe 'Chrono Jigga'
      expect(author).toBe '2 Mello'
      expect(license).toBe 'by-nc'
      expect(artwork).toBe 'https://f1.bcbits.com/img/a2173525289_10.jpg'
      expect(thumbnail).toBe 'https://f1.bcbits.com/img/a2173525289_16.jpg'

      expect(tracks.length).toBe 12
      expect(tracks[0].title).toBe 'Intro'
      expect(tracks[0].url).toMatch 'http://popplers5.bandcamp.com/download/track'
      expect(tracks[0].time).toBe '00:19'

      expect(tracks[11].title).toBe 'Outro'
      expect(tracks[11].url).toMatch 'http://popplers5.bandcamp.com/download/track'
      expect(tracks[11].time).toBe '01:07'

      done()

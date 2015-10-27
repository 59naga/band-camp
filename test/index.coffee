# Dependencies
bandcamp= require '../src'

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 5000

# Specs
describe 'bandcamp',->
  it '.tags',(done)->
    bandcamp.tags()
    .then ({tags,locations})->
      expect(tags.length).toBeGreaterThan 300
      expect(locations.length).toBeGreaterThan 300

      done()

  it '.summaries',(done)->
    expect(bandcamp.summaries).toBe bandcamp

    bandcamp 'vgm'
    .then (summaries)->
      expect(summaries.length).toBe 40

      summary= summaries[summaries.length-1]
      expect(summary.url).toBeTruthy()
      expect(summary.thumbnail).toBeTruthy()
      expect(summary.title).toBeTruthy()
      expect(summary.author).toBeTruthy()

      done()

  it '.albums',(done)->
    bandcamp.albums [
      'https://2mellomakes.bandcamp.com/album/chrono-jigga'
    ]
    .then (albums)->
      album= albums[0]

      expect(album.url).toBe 'https://2mellomakes.bandcamp.com/album/chrono-jigga'
      expect(album.title).toBe 'Chrono Jigga'
      expect(album.author).toBe '2 Mello'
      expect(album.license).toBe 'by-nc'
      expect(album.artwork).toBe 'https://f1.bcbits.com/img/a2173525289_10.jpg'
      expect(album.thumbnail).toBe 'https://f1.bcbits.com/img/a2173525289_16.jpg'
      expect(album.fanCount).toBe 0

      expect(album.tracks.length).toBe 12
      expect(album.tracks[0].title).toBe 'Intro'
      expect(album.tracks[0].url).toMatch '//popplers5.bandcamp.com/'
      expect(album.tracks[0].time).toBe '00:19'

      expect(album.tracks[11].title).toBe 'Outro'
      expect(album.tracks[11].url).toMatch '//popplers5.bandcamp.com/'
      expect(album.tracks[11].time).toBe '01:07'

      done()

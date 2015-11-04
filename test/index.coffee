# Dependencies
bandcamp= require '../src'

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 5000

# Specs
describe 'bandcamp',->
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

      expect(album.tracks.length).toBe 12
      expect(album.tracks[0].title).toBe 'Intro'
      expect(album.tracks[0].url).toMatch '//popplers5.bandcamp.com/'
      expect(album.tracks[0].time).toBe '00:19'

      expect(album.tracks[11].title).toBe 'Outro'
      expect(album.tracks[11].url).toMatch '//popplers5.bandcamp.com/'
      expect(album.tracks[11].time).toBe '01:07'

      expect(album.fans.length).toBe 0
      expect(album.description).toBeTruthy()
      expect(album.credits).toBeTruthy()

      done()

  it '.search',(done)->
    keys= ['type','url','heading','subhead','genre','tags','released']
    types= ['ARTIST','ALBUM','TRACK','FAN']

    bandcamp.search '初音ミク'
    .then (items)->
      for item in items
        expect(keys).toEqual jasmine.arrayContaining Object.keys item

        expect(types).toEqual jasmine.arrayContaining [item.type]
        expect(item.url).toBeTruthy()
        expect(item.heading).toBeTruthy()

      done()

  it '.tags',(done)->
    bandcamp.tags()
    .then ({tags,locations})->
      expect(tags.length).toBeGreaterThan 300
      expect(locations.length).toBeGreaterThan 300

      done()

  describe 'issues',->
    it '#1',(done)->
      bandcamp '初音ミク'
      .then (summaries)->
        expect(summaries.length).toBeGreaterThan 1

        summary= summaries[summaries.length-1]
        expect(summary.url).toBeTruthy()
        expect(summary.thumbnail).toBeTruthy()
        expect(summary.title).toBeTruthy()
        expect(summary.author).toBeTruthy()

        done()

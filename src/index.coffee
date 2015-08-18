# Dependencies
caravan= require 'caravan'
cheerio= require 'cheerio'

querystring= require 'querystring'

# Environment
api= 'https://bandcamp.com/tag/'

# Public
class Bandcamp
  constructor: (@options={})->
    @options.concurrency?= 10

  fetchSummaries: (tag,begin=1,end=10,sort_field='pop')->
    uris=
    for page in [begin..end]
      uri= api+tag+'?'+querystring.stringify {
        page
        sort_field
      }

    caravan.fetchAll uris,@options
    .then (results)->
      albums= []

      for result,i in results
        unless typeof result is 'string'
          {url:urls[i],error:result}

        else
          $= cheerio.load result

          $items= $ '.item_list .item'
          for item in $items
            $item= $ item

            url= $item.find('a').eq(0).attr 'href'
            title= $item.find('.itemtext').eq(0).text().trim()
            author= $item.find('.itemsubtext').eq(0).text().trim()
            thumbnail= $item.find('.art').attr('onclick').match(/http.+?\.jpg/)[0]

            albums.push {url,thumbnail,title,author}

      albums

  fetchAlbums: (albums)->
    urls= (album?.url ? album for album in albums)

    caravan.fetchAll urls,@options
    .then (results)->
      for result,i in results
        url= urls[i]

        unless typeof result is 'string'
          {url,error:result}

        else
          $= cheerio.load result

          title= $('#name-section h2').eq(0).text().trim()
          author= $('#name-section a').eq(0).text().trim()
          
          artwork= $('#tralbumArt a').eq(0).attr 'href'
          thumbnail= $('#tralbumArt a img').eq(0).attr 'src'

          # TODO: 個別のライセンス表記には対応していない
          license= 'copyright'
          licenseUrl= $('#license a').eq(0).attr 'href'
          if licenseUrl
            license= licenseUrl?.match(/licenses\/([\w\-]+)/)[1]

          tracks= []
          $tracks= $ '.track_list .title'
          for track in $tracks
            $track= $ track

            tracks.push {
              title: $track.find('a').text()
              url: ''
              time: $track.find('.time').text().trim()
            }

          trackUrlKeyvalues= result.match(/"mp3-128":"(.+?)"/g) ? []
          for keyvalue,i in trackUrlKeyvalues when tracks[i]
            tracks[i].url= keyvalue.match(/"mp3-128":"(.+?)"/)?[1]

          {url,title,author,license,artwork,thumbnail,tracks}

module.exports= new Bandcamp
module.exports.Bandcamp= Bandcamp

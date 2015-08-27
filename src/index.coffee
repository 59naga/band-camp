# Dependencies
caravan= require 'caravan'
cheerio= require 'cheerio'
moment= require 'moment'

querystring= require 'querystring'
util= require 'util'

# Private
api=
  search: 'https://bandcamp.com/search'
  tag: 'https://bandcamp.com/tag/'
  # Next feature
  tags: 'https://bandcamp.com/tags'
  discover: 'https://bandcamp.com/discover'

# Public
class Bandcamp
  constructor: (@options={})->
    @options.concurrency?= 10

  fetch: ->
    @fetchSummaries arguments...
    .then (summaries)=>
      @fetchAlbums summaries

  fetchSummaries: (tag,begin=1,end=10,sort_field='pop')->
    uris=
    for page in [begin..end]
      uri= api.tag+tag+'?'+querystring.stringify {
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
          author= $('#name-section h3 span').eq(0).text().trim()
          
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

          try
            fans= JSON.parse result.match(/TralbumFans.initialize\((.+), null, null, true, null\);/)[1]
          catch
            fans= []
          # for fan in fans
          #   fan.thumbnail= util.format 'https://f1.bcbits.com/img/%d_42.jpg',('0000000000'+fan.image_id).slice(-10)
          fanCount= fans.length

          {url,title,author,license,artwork,thumbnail,fanCount,tracks}

  search: (q,begin=1,end=1)->
    uris=
    for page in [begin..end]
      uri= api.search+'?'+querystring.stringify {
        q
        page
      }

    caravan.fetchAll uris,@options
    .then (results)->
      items= []

      for result,i in results
        unless typeof result is 'string'
          {url:urls[i],error:result}

        else
          $= cheerio.load result

          $results= $ '.result-info'
          for result in $results
            $result= $ result

            item= {}
            item.type= $result.find('.itemtype').eq(0).text()
            item.url= $result.find('.itemurl').eq(0).text()
            item.heading= $result.find('.heading').eq(0).text()
            item.subhead= $result.find('.subhead').eq(0).text()
            item.genre= $result.find('.genre').eq(0).text()
            item.released= $result.find('.released').eq(0).text()
            item.tags= $result.find('.tags').eq(0).text()

            for key,value of item
              item[key]=
                value
                .trim()
                .replace /\s+/g    ,' '
                .replace /^(genre|tags): /,''
                .replace /^released /,''

              delete item[key] if item[key] is ''

            # "25 December 2012" -> "2012-12-25"
            item.released= moment(new Date item.released).format 'YYYY-MM-DD' if item.released

            # "holiday, Christmas" -> ["holiday", "Christmas"]
            item.tags= item.tags.replace(/, /g,',').split ',' if item.tags

            items.push item

      items

module.exports= new Bandcamp
module.exports.Bandcamp= Bandcamp

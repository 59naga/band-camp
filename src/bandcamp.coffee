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
  tags: 'https://bandcamp.com/tags'
  # Next feature
  discover: 'https://bandcamp.com/discover'

# Public
class Bandcamp
  summaries: (tag,options={})=>
    options.first?= 1
    options.last?= 1
    options.sort_field?= 'pop'
    options.concurrency?= 1

    urls=
    for page in [options.first..options.last]
      url= api.tag+encodeURIComponent(tag)+'?'+querystring.stringify
        page: page
        sort_field: options.sort_field

    caravan urls,options
    .then (results)->
      summaries= []

      for result,i in results
        unless typeof result is 'string'
          {url:urls[i],error:result}

        else
          $= cheerio.load result

          $items= $ '.item_list .item'
          for item in $items
            $item= $ item

            summary= {}
            summary.url= $item.find('a').eq(0).attr 'href'
            summary.title= $item.find('.itemtext').eq(0).text().trim()
            summary.author= $item.find('.itemsubtext').eq(0).text().trim()
            summary.thumbnail= $item.find('.art').attr('onclick').match(/http.+?\.jpg/)[0]

            summaries.push summary

      summaries

  search: (q,options={})=>
    options.first?= 1
    options.last?= 1
    options.sort_field?= 'pop'
    options.concurrency?= 1

    urls=
    for page in [options.first..options.last]
      url= api.search+'?'+querystring.stringify {q,page}

    caravan urls,options
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

  albums: (albums,options={})=>
    urls= (album?.url ? album for album in albums)

    caravan urls,options
    .then (results)->
      for result,i in results
        url= urls[i]

        unless typeof result is 'string'
          album= {url,error:result}

          album

        else
          $= cheerio.load result

          title= $('#name-section h2').eq(0).text().trim()
          author= $('#name-section h3 span').eq(0).text().trim()
          
          artwork= $('#tralbumArt a').eq(0).attr 'href'
          thumbnail= $('#tralbumArt a img').eq(0).attr 'src'

          # FIXME: Doesn't correspond to individual licenses notation
          license= 'copyright'
          licenseUrl= $('#license a').eq(0).attr 'href'
          if licenseUrl
            license= licenseUrl?.match(/licenses\/([\w\-]+)/)[1]

          tracks= []
          $tracks= $ '.track_list .title'
          for track in $tracks
            $track= $ track

            tracks.push
              title: $track.find('a').text()
              url: ''
              time: $track.find('.time').text().trim()

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

          album= {url,title,author,license,artwork,thumbnail,fanCount,tracks}

          album

  tags: =>
    caravan [api.tags]
    .then (results)->
      result= results[0]

      unless typeof result is 'string'
        {url:api.tags,error:result}

      else
        $= cheerio.load result

        unique= {}
        $tags= $ '#tags_cloud a'
        for tag in $tags
          $tag= $ tag

          tagName= $tag.attr('href').replace '/tag/',''
          unique[tagName]?= true if tagName

        tags= Object.keys unique

        locations= {}
        $locations= $ '#locations_cloud a'
        for location in $locations
          $location= $ location

          locationName= $location.attr('href').replace '/tag/',''
          locations[locationName]?= true if locationName

        locations= Object.keys locations

        {tags,locations}

module.exports= new Bandcamp
module.exports.Bandcamp= Bandcamp

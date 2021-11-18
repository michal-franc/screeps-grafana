###
hopsoft\screeps-statsd

Licensed under the MIT license
For full copyright and license information, please see the LICENSE file

@author     Bryan Conrad <bkconrad@gmail.com>
@copyright  2016 Bryan Conrad
@link       https://github.com/hopsoft/docker-graphite-statsd
@license    http://choosealicense.com/licenses/MIT  MIT License
###

rp = require 'request-promise'
zlib = require 'zlib'
StatsD = require 'node-statsd'
lodash = require 'lodash'

shards = (process.env.SCREEPS_SHARD || '').split(',')
resources = [
  'energy','power','H','O','U','K','L','Z','X','G',
  'OH','ZK','UL','UH','UO','KH','KO','LH','LO','ZH',
  'ZO','GH','GO','UH2O','UHO2','KH2O','KHO2','LH2O','LHO2','ZH2O',
  'ZHO2','GH2O','GHO2','XUH2O','XUHO2','XKH2O','XKHO2','XLH2O','XLHO2','XZH2O',
  'XZHO2','XGH2O','XGHO2','ops','silicon','metal','biomass','mist','utrium_bar','lemergium_bar',
  'zynthium_bar','keanium_bar','ghodium_melt','oxidant','reductant','purifier','battery','composite','crystal','liquid',
  'wire','switch','transistor','microchip','circuit','device','cell','phlegm','tissue','muscle',
  'organoid','organism','alloy','tube','fixtures','frame','hydraulics','machine','condensate','concentrate',
  'extract','spirit','emanation','essence',
]

class ScreepsStatsd
  run: ( string ) ->
    rp.defaults jar: true

    @counter = 0
    @token = ""
    @succes = false
    @client = new StatsD host: process.env.GRAPHITE_PORT_8125_UDP_ADDR

    console.log "will fetch data for", shards

    @loop()
    setInterval @loop, 15000

  loop: () =>
    if(!@token || !@succes)
      @signin()
      return

    @getStats()

    if(@counter % 5 == 0)
      @getMarket()

    @counter++

  signin: () =>
    console.log "New login request - " + new Date()

    options =
      uri: 'https://screeps.com/api/auth/signin'
      json: true
      method: 'POST'
      body:
        email: process.env.SCREEPS_EMAIL
        password: process.env.SCREEPS_PASSWORD
    rp(options)
      .then (x) =>
        @token = x.token

        console.log "Fetched auth data"
        @succes = true
      .catch (e) =>
        console.log e

  getStats: () =>
    console.log("getting stats")

    shards.forEach (shard) =>
      @succes = false
      options =
        uri: 'https://screeps.com/api/user/memory'
        method: 'GET' 
        json: true
        resolveWithFullResponse: true
        headers:
          "X-Token": @token
        qs:
          path: 'stats'
          shard: shard
      rp(options)
        .then (x) =>
          return unless x.body.ok && x.body.data
          @succes = true

          # Memory is returned in base64 encoded blob                    
          gzData = x.body.data.split('gz:')[1]
          data = JSON.parse zlib.gunzipSync(new Buffer(gzData, 'base64')).toString()

          @report(data, shard + '.')
        .catch (e) =>
          console.log "failed getting stats", @counter, shard
      

  getMarket: () =>
    # rotate the array
    resources.push(resources.shift())
    resource = resources[0]

    console.log "getting market data", resource

    shards.forEach (shard) =>
      @succes = false
      options =
        uri: 'https://screeps.com/api/game/market/orders'
        method: 'GET' 
        json: true
        resolveWithFullResponse: true
        headers:
          "X-Token": @token
        qs:
          resourceType: resource
          shard: shard
      rp(options)
        .then (x) =>
          return unless x.body.ok && x.body.list
          @succes = true
          orders = x.body.list

          sellOrders = orders.filter (o) =>
            return o.type == 'sell'

          sellOrders = lodash.sortBy sellOrders, 'price'
          minSell = sellOrders[0];
          if (minSell)
            @client.gauge([shard, 'market', resource, 'min', 'sell'].join('.'), minSell.price);
        
          buyOrders = orders.filter (o) =>
            return o.type == 'buy'
            
          buyOrders = lodash.sortBy buyOrders, 'price'
          buyOrders.reverse()
          maxBuy = buyOrders[0];
          if (maxBuy)
            @client.gauge([shard, 'market', resource, 'max', 'buy'].join('.'), maxBuy.price);

        .catch (e) =>
          console.log "failed getting market data", @counter, shard, resource

  report: (data, prefix) =>
    for k,v of data
      if typeof v is 'object'
        @report(v, prefix+k+'.')
      else
        @client.gauge prefix+k, v

module.exports = ScreepsStatsd

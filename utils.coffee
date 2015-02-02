Mongo.Collection.prototype.findAllByIds = (ids, options) ->
  return @find
    _id: $in: ids
  ,
    options

# Used with web packages which need to register their routes at Meteor.startup
# This allow to create a test version of IronRouter for testing purposes
# It is necessary to specify the 'path' option for each individual route
MS.registerRoutes = (routes, router = Router if Router?) ->
  if router?
    _.each routes, (route) ->
      router.route route.path, route
  else
    console.warn "Calling MS.registerRoutes without specying the router.
    Global Router is undefined. Make sure you\'re testing"

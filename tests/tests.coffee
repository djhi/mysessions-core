collection = new Mongo.Collection 'test'

describe "mysessions:core", ->
  beforeAll (test) ->
    if Meteor.isServer
      collection.remove {}

    spies.restoreAll()
    stubs.restoreAll()

    return

  afterAll (test) ->
    spies.restoreAll()
    stubs.restoreAll()
    return

  beforeEach (test) ->
    spies.create 'genericFind', collection, 'find'
    return

  afterEach (test) ->
    spies.restoreAll()
    return

  it "namespace MS should be an object", (test) ->
    expect(MS).to.be.an("object")
    return

  describe "utils", ->
    it "Mongo.Collection.findAllByIds should call find with a filter on _id an an $in operator", ->
      filter = ['id1', 'id2', 'id3']

      collection.findAllByIds filter

      expect(spies.genericFind).to.have.been.calledWith( _id: $in: filter)
      return

    it "Mongo.Collection.findAllByIds should call find with a filter on _id an an $in operator, and options", ->
      filter = ['id1', 'id2', 'id3']

      collection.findAllByIds filter, sort: field: 1

      expect(spies.genericFind).to.have.been.calledWith
        _id: $in: filter
      ,
        sort: field: 1
      return

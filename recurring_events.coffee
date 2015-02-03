###
Schema & Collection
--------------------------------------------------------------------------------
###
MS.RecurringEventSchema = new SimpleSchema
  name:
    type: String
    i18nLabel: 'name'

  userId:
    type: String
    autoValue: ->
      if @isFromTrustedCode then return

      if @isInsert
        return @userId
      else if @isUpsert
        return $setOnInsert: @userId
      else
        @unset()

  description:
    type: String
    optional: true
    i18nLabel: 'description'

  participantsIds:
    type: [String]
    defaultValue: []

  eventOccurencesIds:
    type: [String]
    defaultValue: []

MS.RecurringEvents = new Mongo.Collection 'recurringEvents'
MS.RecurringEvents.attachSchema MS.RecurringEventSchema
MS.RecurringEvents.attachBehaviour 'timestampable'

MS.RecurringEvents.allow
  insert: (userId, doc) -> !!userId
  update: (userId, doc) -> userId == doc.userId
  remove: (userId, doc) -> userId == doc.userId
  fetch: ['userId']

###
Static methods
--------------------------------------------------------------------------------
###
MS.RecurringEvents.findByUser = (userId) ->
  @find
    userId: userId
  ,
    sort: name: 1

###
Instance methods
--------------------------------------------------------------------------------
###
MS.RecurringEvents.helpers
  participantsCount: ->
    @participantsIds?.length or 0

  participants: ->
    MS.Participants.findAllByIds @participantsIds

  eventOccurencesCount: ->
    @eventOccurencesIds?.length or 0

  eventOccurences: ->
    MS.EventOccurences.findByRecurringEvent @_id

###
Publications
--------------------------------------------------------------------------------
###
if Meteor.isServer
  Meteor.publish "recurringEvents", ->
    MS.RecurringEvents.findByUser @userId

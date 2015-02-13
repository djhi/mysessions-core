###
Schema & Collection
--------------------------------------------------------------------------------
###
MS.ParticipantSchema = new SimpleSchema
  lastName:
    type: String
    i18nLabel: 'lastName'

  firstName:
    type: String
    i18nLabel: 'firstName'

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

  eventOccurencesIds:
    type: [String]
    defaultValue: []

  recurringEventsIds:
    type: [String]
    defaultValue: []

MS.Participants = new Mongo.Collection 'participants'
MS.Participants.attachSchema MS.ParticipantSchema
MS.Participants.attachBehaviour 'timestampable'

MS.Participants.allow
  insert: (userId, doc) -> !!userId
  update: (userId, doc) -> userId == doc.userId
  remove: (userId, doc) -> userId == doc.userId
  fetch: ['userId']

###
Static methods
--------------------------------------------------------------------------------
###
MS.Participants.findByUser = findByUser = (userId) ->
  MS.Participants.find
    userId: userId
  ,
    sort: name: 1

MS.Participants.findByRecurringEvent = findByRecurringEvent = (recurringEventId) ->
  MS.Participants.find
    recurringEventsIds: recurringEventId
  ,
    sort: name: 1

###
Instance methods
--------------------------------------------------------------------------------
###
MS.Participants.helpers
  name: ->
    lastName = @lastName
    firstName = @firstName
    "#{lastName}, #{firstName}"

  eventOccurencesCount: ->
    @eventOccurencesIds?.length or 0

  eventOccurences: ->
    MS.EventOccurences.findAllByIds @eventOccurencesIds

  recurringEventsCount: ->
    @recurringEventsIds?.length or 0

  recurringEvents: ->
    MS.RecurringEvents.findAllByIds @recurringEventsIds

###
Publications
--------------------------------------------------------------------------------
###
if Meteor.isServer
  Meteor.publish "participants", ->
    findByUser @userId

  Meteor.publish "participant", (id)->
    MS.Participants.find
      _id: id

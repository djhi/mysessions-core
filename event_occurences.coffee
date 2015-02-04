###
Schema & Collection
--------------------------------------------------------------------------------
###
MS.EventOccurenceSchema = new SimpleSchema
  date:
    i18nLabel: 'date'
    type: Date

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

  recurringEventId:
    i18nLabel: 'category'
    type: String

  participantsIds:
    i18nLabel: 'participants'
    type: [String]
    optional: true
    defaultValue: []

MS.EventOccurences = new Mongo.Collection 'eventOccurences'
MS.EventOccurences.attachSchema MS.EventOccurenceSchema
MS.EventOccurences.attachBehaviour 'timestampable'

MS.EventOccurences.allow
  insert: (userId, doc) -> !!userId
  update: (userId, doc) -> userId == doc.userId
  remove: (userId, doc) -> userId == doc.userId
  fetch: ['userId']

###
Static methods
--------------------------------------------------------------------------------
###
MS.EventOccurences.findByRecurringEvent = (recurringEventId) ->
  @find
    recurringEventId: recurringEventId
  ,
    sort: date: - 1

MS.EventOccurences.findByUser = (userId) ->
  @find
    userId: userId
  ,
    sort: date: - 1

###
Instance methods
--------------------------------------------------------------------------------
###
MS.EventOccurences.helpers
  participantsCount: ->
    @participantsIds?.length or 0

  participants: ->
    MS.Participants.findAllByIds @participantsIds

  recurringEvent: ->
    MS.RecurringEvents.findOne @recurringEventId

###
Hooks
--------------------------------------------------------------------------------
###
if Meteor.isServer
  MS.EventOccurences.before.insert (userId, doc) ->
    unless SimpleSchema.RegEx.Id.test doc.recurringEventId
      # if the recurringEventId is not an valid identifier
      # this is the name of a new recurring event
      recurringEventId = MS.RecurringEvents.insert
        name: doc.recurringEventId
        userId: userId

      if recurringEventId
        doc.recurringEventId = recurringEventId
      else
        doc.recurringEventId = undefined

  MS.EventOccurences.after.insert (userId, eventOccurence) ->
    if !eventOccurence.participantsIds or !eventOccurence.participantsIds.length
      return

    # add the event to the each participant list of events
    participantsModifiers = $addToSet: eventOccurencesIds: eventOccurence._id

    # and the recurring event if any
    if !!eventOccurence.recurringEventId
      participantsModifiers.$addToSet.recurringEventsIds = eventOccurence.recurringEventId

    MS.Participants.direct.update
      _id: $in: eventOccurence.participantsIds
      participantsModifiers

  MS.EventOccurences.after.update (userId, eventOccurence) ->
    if !eventOccurence.participantsIds or !eventOccurence.participantsIds.length
      return
    
    # add the event to the each participant list of events
    participantsModifiers = $addToSet: eventOccurencesIds: eventOccurence._id

    # and the recurring event if any
    if !!eventOccurence.recurringEventId
      participantsModifiers.$addToSet.recurringEventsIds = eventOccurence.recurringEventId

    MS.Participants.direct.update
      _id: $in: eventOccurence.participantsIds
      participantsModifiers

###
Publications
--------------------------------------------------------------------------------
###
if Meteor.isServer
  Meteor.publish "eventOccurences", ->
    MS.EventOccurences.findByUser @userId

  Meteor.publish "eventOccurence", (id)->
    MS.EventOccurences.find
      _id: id

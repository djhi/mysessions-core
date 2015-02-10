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
MS.EventOccurences.findByRecurringEvent = findByRecurringEvent = (recurringEventId) ->
  MS.EventOccurences.find
    recurringEventId: recurringEventId
  ,
    sort: date: -1

MS.EventOccurences.findByUser = findByUser = (userId) ->
  MS.EventOccurences.find
    userId: userId
  ,
    sort: date: -1

###
Instance methods
--------------------------------------------------------------------------------
###
MS.EventOccurences.helpers
  name: ->
    recurringEventName = @recurringEvent().name
    formattedDate = moment(@date).format('LL')
    "#{recurringEventName} - #{formattedDate}"

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
  MS.EventOccurences.ensureValidRecurringEvent = ensureValidRecurringEvent = (userId, recurringEventIdOrName) ->
    unless SimpleSchema.RegEx.Id.test recurringEventIdOrName
      # if the recurringEventId is not an valid identifier
      # this is the name of a new recurring event
      return MS.RecurringEvents.insert
        name: recurringEventIdOrName
        userId: userId

    return recurringEventIdOrName

  MS.EventOccurences.updateParticipants = updateParticipants = (userId, eventOccurence) ->
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

  MS.EventOccurences.before.insert (userId, eventOccurence) ->
    if !eventOccurence.recurringEventId then return

    recurringEventId = eventOccurence.recurringEventId
    recurringEventId = ensureValidRecurringEvent userId, recurringEventId
    eventOccurence.recurringEventId = recurringEventId

  MS.EventOccurences.before.update (userId, eventOccurence, fieldNames, modifiers) ->
    if !modifiers.$set.recurringEventId then return

    recurringEventId = modifiers.$set.recurringEventId
    recurringEventId = ensureValidRecurringEvent userId, recurringEventId
    modifiers.$set.recurringEventId = recurringEventId

  MS.EventOccurences.after.insert (userId, eventOccurence) ->
    updateParticipants userId, eventOccurence

  MS.EventOccurences.after.update (userId, eventOccurence) ->
    updateParticipants userId, eventOccurence

###
Publications
--------------------------------------------------------------------------------
###
if Meteor.isServer
  Meteor.publish "eventOccurences", ->
    findByUser @userId

  Meteor.publish "eventOccurence", (id)->
    MS.EventOccurences.find
      _id: id

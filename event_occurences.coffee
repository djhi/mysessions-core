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
    type: [String]
    defaultValue: []

MS.EventOccurences = new Mongo.Collection 'eventOccurences'
MS.EventOccurences.attachSchema MS.EventOccurenceSchema
MS.EventOccurences.attachBehaviour 'timestampable'

###
Static methods
--------------------------------------------------------------------------------
###
MS.EventOccurences.findByRecurringEvent = (recurringEventId) ->
  @find
    recurringEventId: recurringEventId
  ,
    sort: date: - 1

MS.EventOccurences.addParticipant = (eventOccurenceId, participantId) ->
  check(eventOccurenceId, String)
  check(participantId, String)

  # add the participant to this event occurence and to the recurring event
  MS.EventOccurences.update eventOccurenceId
  ,
    $addToSet: participantsIds: participantId

###
Instance methods
--------------------------------------------------------------------------------
###
MS.EventOccurences.helpers
  participants: ->
    MS.Participants.findAllByIds @participantsIds

  recurringEvent: ->
    MS.RecurringEvents.findOne @recurringEventId

  addParticipant: (participantId) ->
    MS.EventOccurences.addParticipant @_id, participantId


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

  MS.EventOccurences.after.update (userId, eventOccurence, fieldNames, modifiers, options) ->
    if !modifiers.$addToSet?.participantsIds then return

    # add the participant to the occurence recurring event if any
    if !!eventOccurence.recurringEventId
      MS.RecurringEvents.update eventOccurence.recurringEventId
      ,
        modifiers

    # add the event to the participant list of events
    participantsModifiers = $addToSet: eventOccurencesIds: eventOccurence._id

    # and the recurring event if any
    if !!eventOccurence.recurringEventId
      participantsModifiers.$addToSet.recurringEventsIds = eventOccurence.recurringEventId

    MS.Participants.update modifiers.$addToSet.participantsIds, participantsModifiers

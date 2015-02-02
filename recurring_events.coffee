###
Schema & Collection
--------------------------------------------------------------------------------
###
MS.RecurringEventSchema = new SimpleSchema
  name:
    type: String

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

  participantsIds:
    type: [String]
    defaultValue: []

  eventOccurencesIds:
    type: [String]
    defaultValue: []

MS.RecurringEvents = new Mongo.Collection 'recurringEvents'
MS.RecurringEvents.attachSchema MS.RecurringEventSchema
MS.RecurringEvents.attachBehaviour 'timestampable'

###
Static methods
--------------------------------------------------------------------------------
###
MS.RecurringEvents.addParticipant = (recurringEventId, participantId) ->
  check(recurringEventId, String)
  check(participantId, String)

  # add the participant to the recurring event
  modifiers = $addToSet: participantsIds: participantId
  MS.RecurringEvents.update recurringEventId, modifiers

  # add the recurring event to the participant list of recurring event
  modifiers = $addToSet: recurringEventsIds: recurringEventId
  MS.Participants.update participantId, modifiers

###
Instance methods
--------------------------------------------------------------------------------
###
MS.RecurringEvents.helpers
  participants: ->
    MS.Participants.findAllByIds @participantsIds

  eventOccurences: ->
    MS.EventOccurences.findByRecurringEvent @_id

  addParticipant: (participantId) ->
    MS.RecurringEvents.addParticipant @_id, participantId

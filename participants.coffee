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
Instance methods
--------------------------------------------------------------------------------
###
MS.Participants.helpers
  eventOccurences: ->
    MS.EventOccurences.findAllByIds @eventOccurencesIds

  recurringEvents: ->
    MS.RecurringEvents.findAllByIds @recurringEventsIds

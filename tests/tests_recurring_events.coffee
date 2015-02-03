describe "mysessions:core", ->
  describe "RecurringEvents", ->
    beforeAll (test) ->
      if Meteor.isServer
        MS.Participants.remove {}
        MS.EventOccurences.remove {}
        MS.RecurringEvents.remove {}

      spies.restoreAll()
      stubs.restoreAll()

      if Meteor.isServer
        # Insert 2 recurring events (not linked to anything)
        for index2 in [0..1]
          Factory.create 'recurringEvent'

        # Insert 2 recurring events (not linked to anything)
        for index3 in [0..4]
          Factory.create 'eventOccurence'

      return

    afterAll (test) ->
      spies.restoreAll()
      stubs.restoreAll()
      return

    beforeEach (test) ->
      spies.create 'participantsFind', MS.Participants, 'find'
      spies.create 'eventOccurencesFind', MS.EventOccurences, 'find'
      spies.create 'recurringEventsFind', MS.RecurringEvents, 'find'
      spies.create 'participantsFindOne', MS.Participants, 'findOne'
      spies.create 'eventOccurencesFindOne', MS.EventOccurences, 'findOne'
      spies.create 'recurringEventsFindOne', MS.RecurringEvents, 'findOne'
      spies.create 'participantsUpdate', MS.Participants, 'update'
      spies.create 'eventOccurencesUpdate', MS.EventOccurences, 'update'
      spies.create 'recurringEventsUpdate', MS.RecurringEvents, 'update'

      return

    afterEach (test) ->
      spies.restoreAll()
      return

    it "RecurringEvent.participants should call MS.Participants.find filtering _id by its array of participants ids", ->
      recurringEvent = MS.RecurringEvents.findOne()
      participants = recurringEvent.participants()

      expect(spies.participantsFind).to.have.been.calledWith _id: $in: recurringEvent.participantsIds

      return
      
    it "RecurringEvent.eventOccurences should call MS.EventOccurences.find filtering recurringEventId by its _id", ->
      recurringEvent = MS.RecurringEvents.findOne()
      eventOccurences = recurringEvent.eventOccurences()

      expect(spies.eventOccurencesFind).to.have.been.calledWith recurringEventId: recurringEvent._id

      return

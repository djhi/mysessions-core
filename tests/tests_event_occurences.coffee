describe "mysessions:core", ->
  describe "EventOccurences", ->
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

    it "MS.EventOccurences.findByRecurringEvent should call find with a filter on recurringEventId and a descending sort on date", ->
      MS.EventOccurences.findByRecurringEvent 'testId'

      expect(spies.eventOccurencesFind).to.have.been.calledWith
        recurringEventId: 'testId'
      ,
        sort: date: -1

      return

    it "EventOccurence.participants should call MS.Participants.find filtering _id by its array of participants ids", ->
      eventOccurence = MS.EventOccurences.findOne()
      participants = eventOccurence.participants()

      expect(spies.participantsFind).to.have.been.calledWith _id: $in: eventOccurence.participantsIds

      return

    it "EventOccurence.recurringEvent should call MS.RecurringEvents.find filtering _id by its recurringEventId", ->
      eventOccurence = MS.EventOccurences.findOne()
      recurringEvent = eventOccurence.recurringEvent()

      expect(spies.recurringEventsFindOne).to.have.been.calledWith eventOccurence.recurringEventId

      return

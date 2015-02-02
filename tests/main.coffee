Factory.define 'participant', MS.Participants,
  lastName: Fake.word()
  firstName: Fake.word()

Factory
  .define('recurringEvent', MS.RecurringEvents,name: Fake.word())

Factory
  .define('eventOccurence', MS.EventOccurences,
    recurringEventId: Factory.get 'recurringEvent'
    date: new Date(_.random(2000, 2014), _.random(0, 11), _.random(0, 20)))
  .after (eventOccurence) ->
    MS.RecurringEvents.update eventOccurence.recurringEventId
    ,
      $addToSet: eventOccurencesIds: eventOccurence._id

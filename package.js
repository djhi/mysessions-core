var both = ['client', 'server'];

Package.describe({
  name: 'mysessions:core',
  summary: "MySessions Core"
});

Package.on_use(function(api, where) {
  api.use('underscore', both);
  api.use('coffeescript', both);
  api.use('mongo', both);
  api.use('templating', both);
  api.use('dburles:collection-helpers@1.0.2', both);
  api.use('matb33:collection-hooks@0.7.9', both);
  api.use('aldeed:simple-schema', both);
  api.use('aldeed:collection2', both);
  api.use('zimme:collection-behaviours', both);
  api.use('zimme:collection-timestampable', both);
  api.use('zimme:collection-softremovable', both);

  api.imply('underscore', both);
  api.imply('coffeescript', both);
  api.imply('mongo', both);
  api.imply('aldeed:simple-schema', both);
  api.imply('aldeed:collection2', both);

  api.add_files([
    "namespaces.coffee",
    "utils.coffee",
    "participants.coffee",
    "event_occurences.coffee",
    "recurring_events.coffee",
  ], both);

  api.export("MS", both);
});

Package.on_test(function(api) {
  api.use('underscore', both);
  api.use('coffeescript', both);
  api.use('autopublish', both);
  api.use('mysessions:core', both);
  api.use('practicalmeteor:munit', both);
  api.use('dburles:factory@0.3.7', both);
  api.use('anti:fake@0.4.1', both);

  api.add_files([
    'tests/main.coffee',
    'tests/tests.coffee',
    'tests/tests_event_occurences.coffee',
    'tests/tests_recurring_events.coffee',
  ], both);
});

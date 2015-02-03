SimpleSchema.extendOptions
  i18nLabel: Match.Optional String

# should be used to safely get a label as string
SimpleSchema.prototype.originalLabel = SimpleSchema.prototype.label

SimpleSchema.prototype.label = (key) ->
  # Get all labels
  if key is null then return this.originalLabel()

  # Get label for one field
  def = this.getDefinition key

  if def and def.i18nLabel
    language = if not Meteor.isClient then Meteor.user().profile.language
    return TAPi18n.__ def.i18nLabel, {}, language
  else
    return this.originalLabel key

  return null

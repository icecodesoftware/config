doc ("A way to retrieve, validate, and have default values from configuration")
shared class Key<T>(shared String key,
  shared PropertyConverter<T> converter,
  shared T? defaultValue = null) {
}

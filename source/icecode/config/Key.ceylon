doc ("A way to retrieve, validate, and have default values from configuration")
shared class Key<T>(
  doc("the key to search for")
  shared String key,
  
  doc("the converter used to convert a String to wanted Type")
  shared PropertyConverter<T> converter,
  
  doc("User face description of what this property will be used for")
  shared String description="",
  
  doc("A default value for the property if it can't be found defaults to null")
  shared T? defaultValue = null
  ) {
}

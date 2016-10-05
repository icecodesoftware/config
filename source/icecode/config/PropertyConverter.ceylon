import ceylon.time {
  DateTime
}
import ceylon.time.iso8601 {
  parseDateTime
}

shared PropertyConverter<Boolean?> booleanConverter = PropertyConverter(parseBoolean);
shared PropertyConverter<Integer?> integerConverter = PropertyConverter(parseInteger); 
shared PropertyConverter<Float?> floatConverter = PropertyConverter(parseFloat);
shared PropertyConverter<DateTime?> dateTimeConverter = PropertyConverter(parseDateTime);
shared PropertyConverter<String> stringConverter = PropertyConverter((String propVal) => propVal);


doc ("information to convert a property to the given form")
shared class PropertyConverter<T>(
  doc("function to parse the passed in property value")
  Callable<T,[String]> parserFn) {
  shared T convert(String propVal) {
    return parserFn(propVal);
  }
}
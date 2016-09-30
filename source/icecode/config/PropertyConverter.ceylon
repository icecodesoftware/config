import ceylon.time.iso8601 {
  parseDateTime
}
import ceylon.time {
  DateTime
}
shared PropertyConverter<String> stringConverter = PropertyConverter((String propVal) => propVal);
shared PropertyConverter<Integer?> integerConverter = PropertyConverter(parseInteger); 
shared PropertyConverter<DateTime?> dateTimeConverter = PropertyConverter(parseDateTime);

doc ("information to convert a property to the given form")
shared class PropertyConverter<T>(
  doc("function to parse the passed in property value")
  Callable<T,[String]> parserFn) {
  shared T convert(String propVal) {
    return parserFn(propVal);
  }
}
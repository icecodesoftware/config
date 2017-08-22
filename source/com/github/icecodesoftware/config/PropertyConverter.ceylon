import ceylon.time {
  DateTime
}
import ceylon.time.iso8601 {
  parseDateTime
}

shared PropertyConverter<Boolean?> booleanConverter = PropertyConverter((String val)=>convert(val,Boolean.parse));
shared PropertyConverter<Integer?> integerConverter = PropertyConverter((String val)=>convert(val,Integer.parse)); 
shared PropertyConverter<Float?> floatConverter = PropertyConverter((String val)=>convert(val,Float.parse));
shared PropertyConverter<DateTime?> dateTimeConverter = PropertyConverter(parseDateTime);
shared PropertyConverter<String> stringConverter = PropertyConverter((String propVal) => propVal);

Return? convert<Return>(String val,Callable<Return|ParseException, [String]> func){
	return if (is Return bval = func(val)) then bval else null;	
}


"class to convert a given string value to the given type T"
shared class PropertyConverter<Return>(
  doc("function to parse the passed in property value")
  Callable<Return,[String]> parserFn) {
  shared Return convert(String propVal) {
    return parserFn(propVal);
  }
}
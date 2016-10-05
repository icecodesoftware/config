doc ("A way to retrieve, validate, and have default values from configuration")
shared class Key<T>(
  doc("the key to search for")
  shared String key,
  
  doc("the converter used to convert a String to the given Type")
  shared PropertyConverter<T> converter,
  
  doc("User facing description of what this property will be used for")
  shared String description="",
  
  doc("Default value for the property if it can't be found defaults to [[null]")
  shared T? defaultValue = null,
  
  doc ("Used to validate the value of the property. If validation fails the previous value for this [[Key]] will not be changed. 
        The default validator validates that a value exists")
  Callable<ErrorMessage?, [String,T]> validator=existenceValidator
) {
  
  shared ErrorMessage? validate(String prop){
   return validator(key,converter.convert(prop));
  }
}



shared ErrorMessage? existenceValidator(String key,Anything possibleVal){  
  if(exists possibleVal){
    return null;
  }
  return ErrorMessage("The value for ``key`` doesn't exist");
}

shared class ErrorMessage(shared String message){}
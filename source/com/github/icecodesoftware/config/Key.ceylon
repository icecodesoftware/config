"A way to retrieve, validate, and have default values from configuration"
shared class Key<T>(
  "the key to search for"
  shared String keyName,
  
  "the converter used to convert a String to the given Type"
  shared PropertyConverter<T> converter,
  
  "User facing description of what this property will be used for"
  shared String description="",
  
  "Default value for the property if it can't be found defaults to [[null]"
  shared T? defaultValue = null,
  
  "Used to validate the value of the property. If validation fails the previous value for this [[Key]] will not be changed. 
        The default validator validates that a value exists"
  Callable<ErrorMessage?, [String,T]> validator=existenceValidator
) {
  
  shared ErrorMessage? validate(String prop){
   return validator(keyName,converter.convert(prop));
  }
}


"Validator that checks if [[possibleVal]] is not [[null]] otherwise give a [[ErrorMessage]]"
shared ErrorMessage? existenceValidator(String key,Anything possibleVal){  
  if(exists possibleVal){
    return null;
  }
  return ErrorMessage("The value for ``key`` doesn't exist");
}

shared class ErrorMessage(shared String message){}
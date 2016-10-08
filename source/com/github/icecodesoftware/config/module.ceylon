"""
   # What is IceCode Config
   Having worked with many java configuration libraries. I have not found one that did what I wanted.  This library addresses issue I found missing in other config libs
   
   # Basics
   A ConfigurationService is basically a String to String Map with facilities to manage conversion, validation,defaults, monitoring, and loading of values of that map. 
   
   # Getting Started:
   ```ceylon
   value key = Key("key",stringConverter);
   value config = createFromFile("test.properties",{key})
   value val = config.getValueAs<String>("key");
   value val2 = config.getValue(key);
   ```
   
   #What is a Key
   A Key is object that contains all information related to managing a Property in the ConfigurationService
   ##keyName
   The key to match on in the ConfigurationService can be anything accept a '='
   
   ## converter
   The PropertyConverter to convert the value from a String to the type defined in the converter. The default converter is String Converter.
   ### Built In Property Converters
   * String Converter 
   * ex. `hello`
   * Integer Converter 
   * ex. `5`
   * Float Converter 
   * ex. `5.5`
   * DateTime Converter 
   * ex. `2016-10-05T18:29:58.185`
   * Boolean Converter 
   * ex. `true`
   
   ##description
   Used to describe what the Key is used for. Defaults to no description
   
   ##defaultValue
   A default value if the property can't be converted
   
   ##validator
   A function used to validate the value after it has been converted
   
   ###What is Validation
   Validation is a follow on step after conversion to make sure the value of the property is valid. If validation fails the internal map will not be updated. Additionally, an error event will be sent to all listners of the ConfigurationService. Validation is only applied to properties that have a defined Key associated with it. The default validator just checks for existence.
   Example of a Key with an Empty String Validator:
   ```ceylon
   value key1 = Key {
      key = "key";
      converter = stringConverter;
      validator = (String key, String val) => if (!val.empty) then null else ErrorMessage("String is empty"); 
   };
   ```
   #Observing Configuration Changes
   Clients can observer changes to the ConfigurationService by implementing the Listener and subscribing to the service.
   ```ceylon
   object listener1 satisfies Listener {
      shared actual void onChange(String key, String? val, ChangeType changeType) {
    if (changeType == changed) {
      print("key ``key`` changed to ``val``")
    }
   }
   }
   configService.addListener(listener1);
   configService.reload(...);
   ```
   
   ##ChangeTypes
   * added 
   * if the property didn't exist and now exists
   * changed 
   * if the property exists but the value changed
   * removed 
   * if the property existed but has been removed
   * error 
   * if validation failed on reloading a given property
"""
native ("jvm") 
module com.github.icecodesoftware.config "1.0.0" {
  shared import ceylon.file "1.3.0";
  import ceylon.logging "1.3.0";
  import ceylon.collection "1.3.0";
  shared import ceylon.time "1.3.0";
}

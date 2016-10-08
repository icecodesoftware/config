import ceylon.collection {
  HashSet,
  HashMap,
  ArrayList
}
import ceylon.file {
  Path,
  File,
  lines
}
import ceylon.logging {
  logger,
  Logger
}

/**
 logger for this module
 */
Logger log = logger(`module com.github.icecodesoftware.config`);

"A service for getting properties from a backing source."
shared interface ConfigurationService {
  
  "get a value from the config service with the given type"
  shared formal T? getValueAs<T>(String key);
  
  "get a value using a Key"
  shared formal T? getValue<T>(Key<T> key);
  
  "add a Listener that can listen to property changes on reload"
  shared formal void addListener(Listener listener);
  
  "unsubscribe a user from listening to property changes"
  shared formal void removeListener(Listener listener);
  
  "Change the property with the ones passed in"
  shared formal void reload({<String->String>*} entries);
  
  "take a snapshot of the properties in the config service"
  shared formal Map<String,String> getSnapshot();
}

"Implementation of the [[ConfigurationService]]"
shared class BasicConfigurationService(
  "Then entries used to populate the configuration service"
  {<String->String>*} entries = {},
  "The keys used for validation of the [[entries]]"
  {Key<out Anything>*} keys= emptySet) satisfies ConfigurationService {
  
  /*
   This needs to be variable because for reloads
   */
  variable HashMap<String,String> currentProps = HashMap<String,String>{entries = entries;};
  
  value keySet = HashSet{elements=keys;};
  value listeners = HashSet<Listener>();
  value propertyConverters = {stringConverter,integerConverter,dateTimeConverter};
  
  shared actual T? getValueAs<T>(String key) {
    value mval = currentProps[key];
    if (exists mval) {
      for (value converter in propertyConverters) {
        if (is T val = converter.convert(mval)) {
          return val;
        }
      }
    }
    return null;
  }
  shared actual Map<String,String> getSnapshot() => currentProps.clone();
  
  shared actual T? getValue<T>(Key<T> key){
    value val = currentProps[key.keyName];
    if(exists val){
      return key.converter.convert(val);
    }
    return key.defaultValue;
  }
  
  shared actual void addListener(Listener listener) {
    listeners.add(listener);
  }
  shared actual void removeListener(Listener listener) {
    listeners.remove(listener);
  }
  
  //TODO #9 make  this thread safe
  shared actual void reload({<String->String>*} newEntries){
    value map = HashMap<String,String>();
    value events = ArrayList<[String,String?,ChangeType]>();
    for(newKey->newVal in newEntries){
      Key<out Anything>? keyInfo = keySet.filter((k)=>k.keyName.equals(newKey)).first;
      value current = currentProps[newKey];
      if(exists keyInfo){
        value errorMsg = keyInfo.validate(newVal);
        if(exists errorMsg){
          log.error("Could not set new property reason:"+errorMsg.message);
          events.add([newKey,newVal,error]);
          continue;
        }
      }
      if(exists current){
        map[newKey]=newVal;
        if(current != newVal){
          events.add([newKey,newVal,changed]);
        }
      }else{
        map[newKey]=newVal;
        events.add([newKey,newVal,added]);
      }      
    }
    
    for(key in currentProps.keys){
      if(!map.keys.contains(key)){
        events.add([key,null,removed]);
      }
    }
    currentProps = map;
    for(item in events){
      for(listener in listeners){
        listener.onChange(item[0],item[1], item[2]);
        log.trace("event ``item``");
      }
    }
  }
}

"create a [[ConfigurationService]] from a property file"
shared ConfigurationService? createFromFile(Path path,{Key<out Anything>*} keys={}) {
  if (is File file = path.resource) {
    value props = { for (line in lines(file)) if (exists prop = parseProp(line)) prop[0] -> prop[1] };
    return BasicConfigurationService(props,keys);
  }
  return null;
}

"create a [[ConfigurationService]] from a set of key value pairs"
shared ConfigurationService? createFromEntries({<String->String>*} entries,{Key<out Anything>*} keys={}) {
  return BasicConfigurationService(entries,keys);
}

shared [String, String]|Null parseProp(String line) {
  value separatorIndex = line.indexOf("=");
  log.trace("parsing line ``line``");
  if (separatorIndex != -1) {
    String key = line[... separatorIndex-1];
    if (key.empty) {
      return null;
    }
    String val = line[separatorIndex+1 ...];
    return [key, val];
  } else {
    log.error("Could not turn line ``line`` int a property");
    return null;
  }
}

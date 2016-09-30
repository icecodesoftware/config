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

Logger log = logger(`module icecode.config`);

doc ("A service for getting properties from a backing source.")
by ("Mark Lester")
shared interface ConfigurationService {
  
  doc ("get a value from the config service with the given type")
  shared formal T? getValueAs<T>(String key);
  
  doc("get a value using a Key")
  shared formal T? getValue<T>(Key<T> key);
  
  doc("add a Listener that can listen to property changes on reload")
  shared formal void subscribe(Listener listener);
  
  doc("unsubscribe a user from listening to property changes")
  shared formal void unsubscribe(Listener listener);
  
  doc("Change the property with the ones passed in")
  shared formal void reload({<String->String>*} entries);
  
  doc ("take a snapshot of the properties in the config service")
  shared formal Map<String,String> getSnapshot();
}

shared class BasicConfigurationService({<String->String>*} entries = {}) satisfies ConfigurationService {
  
  variable HashMap<String,String> currentProps = HashMap<String,String>{entries = entries;};
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
    value val = currentProps[key.key];
    if(exists val){
      return key.converter.convert(val);
    }
    return key.defaultValue;
  }
  
  shared actual void subscribe(Listener listener) {
    listeners.add(listener);
  }
  shared actual void unsubscribe(Listener listener) {
    listeners.remove(listener);
  }
  
  //TODO #9 make  this thread safe
  shared actual void reload({<String->String>*} entries){
    value map = HashMap<String,String>();
    value events = ArrayList<[String,String?,ChangeType]>();
    for(key->val in entries){
      value current = currentProps[key];
      if(exists current){
        map[key]=val;
        if(current != val){
          events.add([key,val,changed]);
        }
      }else{
        map[key]=val;
        events.add([key,val,added]);
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

shared ConfigurationService? createFromFile(Path path) {
  if (is File file = path.resource) {
    value props = { for (line in lines(file)) if (exists prop = parseProp(line)) prop[0] -> prop[1] };
    return BasicConfigurationService(props);
  }
  return null;
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

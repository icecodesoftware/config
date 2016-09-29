import ceylon.collection {
  TreeMap
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
  
  doc ("take a snapshot of the properties in the config service")
  shared formal Map<String,String> getSnapshot();
}

shared class BasicConfigurationService({<String->String>*} entries = {}) satisfies ConfigurationService {
  value map = TreeMap<String,String>((String x, String y) => x <=> y, entries);
  
  value propertyConverters = {stringConverter,integerConverter,dateTimeConverter};
  
  shared actual T? getValueAs<T>(String key) {
    value mval = map[key];
    if (exists mval) {
      for (value converter in propertyConverters) {
        if (is T val = converter.convert(mval)) {
          return val;
        }
      }
    }
    return null;
  }
  shared actual Map<String,String> getSnapshot() => map.clone();
  
  shared actual T? getValue<T>(Key<T> key){
    value val = map[key.key];
    if(exists val){
      return key.converter.convert(val);
    }
    return key.defaultValue;
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

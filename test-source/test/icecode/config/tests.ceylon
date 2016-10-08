import ceylon.file {
  parsePath
}
import ceylon.test {
  test,
  assertEquals,
  assertNull,
  assertNotNull
}
import ceylon.time {
  now,
  DateTime
}

import com.github.icecodesoftware.config {
  BasicConfigurationService,
  createFromFile,
  parseProp,
  stringConverter,
  Key,
  integerConverter,
  Listener,
  ChangeType,
  added,
  changed,
  removed,
  error,
  ErrorMessage,
  floatConverter
}
import ceylon.collection {
  ArrayList
}

class ConfigurationServiceTests() {
  test
  shared void testGetValueAsString() {
    value configService = BasicConfigurationService({ "string"->"value" });
    assertEquals(configService.getValueAs<String>("string"), "value");
    assertNull(configService.getValueAs<String>("nothere"));
  }
  
  test
  shared void testGetValueAsInteger() {
    value configService = BasicConfigurationService({ "key"->"5" });
    assertEquals(configService.getValueAs<String>("key"), "5");
    assertEquals(configService.getValueAs<Integer>("key"), 5);
  }
  
  test
  shared void testGetValueAsDate() {
    value dt = now().dateTime();
    value configService = BasicConfigurationService({ "key"->dt.string });
    assertEquals(configService.getValueAs<String>("key"), dt.string);
    assertEquals(configService.getValueAs<DateTime>("key"), dt);
  }
  
  test
  shared void testGetWithKey() {
    value str = "astring";
    Key<String> key = Key("name", stringConverter);
    Key<String> doesntExistKey = Key("dne", stringConverter);
    Key<String> doesntExistKeyWithDefault = Key { keyName = "dne_default"; converter = stringConverter; defaultValue = "defaultValue"; };
    Key<Integer?> dneIntKey = Key { keyName = "dne.int"; converter = integerConverter; defaultValue = 5; };
    
    value configService = BasicConfigurationService({ key.keyName->str });
    assertEquals(configService.getValue(key), str);
    
    assertNull(configService.getValue(doesntExistKey));
    
    assertEquals(configService.getValue(doesntExistKeyWithDefault), "defaultValue");
    
    assertEquals(configService.getValue(dneIntKey), 5);
  }
  
  test
  shared void testParsePropertyFile() {
    value config = createFromFile(parsePath("resource/test.properties"));
    assertNotNull(config);
    if (exists config) {
      assertEquals(3, config.getSnapshot().size);
      assertEquals(config.getValueAs<String>("a"),"1");
    }
  }
  
  test
  shared void testPropertyParsing() {
    //valid prop
    value actual = parseProp("a=1");
    assertEquals(["a", "1"], actual);
    
    //test empty string on empty value
    value novalue = parseProp("b=");
    assertEquals(["b", ""], novalue);
    
    //test missing key
    value nokey = parseProp("=3");
    assertEquals(null, nokey);
    
    //test multiple tokens in line
    value valueWithToken = parseProp("a=3=");
    assertEquals(["a", "3="], valueWithToken);
    
    value whiteSpaceLine = parseProp(" ");
    assertEquals(null, whiteSpaceLine);
  }
  
  test
  shared void testListenToAddProperty() {
    value configService = BasicConfigurationService();
    variable Integer addCount = 0;
    object listener1 satisfies Listener {
      shared actual void onChange(String key, String? val, ChangeType changeType) {
        if (changeType == added) {
          addCount++;
        }
      }
    }
    
    configService.addListener(listener1);
    configService.reload({ "key"->"value" });
    assertEquals(addCount, 1);
    
    configService.removeListener(listener1);
    assertEquals(addCount, 1);
  }
  
  test
  shared void testListenToChangeProperty() {
    value configService = BasicConfigurationService();
    variable Integer changeCount = 0;
    object listener1 satisfies Listener {
      shared actual void onChange(String key, String? val, ChangeType changeType) {
        if (changeType == changed) {
          changeCount++;
        }
      }
    }
    
    configService.addListener(listener1);
    configService.reload({ "key"->"value" });
    assertEquals(changeCount, 0);
    
    configService.reload({ "key"->"value_changed" });
    assertEquals(changeCount, 1);
    
    configService.removeListener(listener1);
    configService.reload({ "key"->"value_changed_again" });
    assertEquals(changeCount, 1);
  }
  
  test
  shared void testListenToRemovedProperty() {
    value configService = BasicConfigurationService({ "key"->"value" });
    variable Integer removedCount = 0;
    object listener1 satisfies Listener {
      shared actual void onChange(String key, String? val, ChangeType changeType) {
        if (changeType == removed) {
          removedCount++;
        }
      }
    }
    
    configService.addListener(listener1);
    configService.reload({ "key"->"value" });
    assertEquals(removedCount, 0);
    
    configService.reload({});
    assertEquals(removedCount, 1);
    
    configService.removeListener(listener1);
    configService.reload({ "key"->"value_changed_again" });
    assertEquals(removedCount, 1);
  }
  
  test
  shared void testMultiListeners() {
    value configService = BasicConfigurationService({ "key"->"value" });
    value actualEvents = ArrayList<[String, String, String?, ChangeType]>();
    
    class TestListener(String name, ChangeType listenedTo) satisfies Listener {
      shared actual void onChange(String key, String? val, ChangeType changeType) {
        if (changeType == listenedTo) {
          actualEvents.add([name, key, val, changeType]);
        }
      }
    }
    
    configService.addListener(TestListener("alistener", added));
    configService.addListener(TestListener("rlistener", removed));
    configService.addListener(TestListener("clistener", changed));
    configService.reload({ "key"->"value" });
    assertEquals(actualEvents.size, 0);
    
    configService.reload({});
    assertEquals(actualEvents.size, 1);
    assertEquals(actualEvents[0]?.first, "rlistener");
    
    actualEvents.clear();
    configService.reload({ "key"->"value" });
    assertEquals(actualEvents.size, 1);
    assertEquals(actualEvents[0]?.first, "alistener");
    
    actualEvents.clear();
    configService.reload({ "key"->"value1" });
    assertEquals(actualEvents.size, 1);
    assertEquals(actualEvents[0]?.first, "clistener");
  }
  
  test
  shared void testValidation() {
    value key1 = Key {
      keyName = "key";
      converter = stringConverter;
      validator = (String key, String val) => if (!val.empty) then null else ErrorMessage("String is empty"); 
    };
    value key2 = Key("key.int", integerConverter);
    value key3 = Key {
      keyName = "key.float";
      converter = floatConverter;
      defaultValue = 3.5;};
    Set<Key<out Anything>> keys = set({ key1, key2, key3 });
    value configService = BasicConfigurationService({ "key"->"value" }, keys);
    value actualEvents = ArrayList<[String, String, String?, ChangeType]>();
    
    class TestListener(String name, ChangeType listenedTo) satisfies Listener {
      shared actual void onChange(String key, String? val, ChangeType changeType) {
        if (changeType == listenedTo) {
          actualEvents.add([name, key, val, changeType]);
        }
      }
    }
    
    configService.addListener(TestListener("clistener", error));
    
    configService.reload({ "key"->"value" });
    assertEquals(actualEvents.size, 0);
    assertEquals(configService.getValue(key1), "value");
    assertNull(configService.getValue(key2));
    assertEquals(configService.getValue(key3), 3.5);
    
    configService.reload({ "key"->"" });
    assertEquals(actualEvents.size, 1);
    actualEvents.clear();
   
    configService.reload({ "key"->"value", "key.int"->"5" });
    assertEquals(configService.getValue(key1), "value");
    assertEquals(configService.getValue(key2), 5);
    
    configService.reload({ "key"->"value", "key.int"->"NotNumber" });
    assertNull(configService.getValue(key2));
    assertEquals(actualEvents.size, 1);
  }
}
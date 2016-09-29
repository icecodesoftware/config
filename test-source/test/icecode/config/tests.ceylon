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

import icecode.config {
  BasicConfigurationService,
  createFromFile,
  parseProp,
  stringConverter,
  Key,
  integerConverter
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
  shared void testGetWithKey(){
    value str = "astring";
    Key<String> key = Key("name", stringConverter);
    Key<String> doesntExistKey = Key("dne", stringConverter);
    Key<String> doesntExistKeyWithDefault = Key("dne_default", stringConverter,"defaultValue");
    Key<Integer?> dneIntKey = Key("dne.int", integerConverter,5);
    value configService = BasicConfigurationService({ key.key->str });
    assertEquals(configService.getValue(key),str);
    
    assertNull(configService.getValue(doesntExistKey));
    
    assertEquals(configService.getValue(doesntExistKeyWithDefault),"defaultValue");
    
    assertEquals(configService.getValue(dneIntKey),5);
  }
  
  test
  shared void testParsePropertyFile() {
    value config = createFromFile(parsePath("resource/test.properties"));
    assertNotNull(config);
    if (exists config) {
      assertEquals(3, config.getSnapshot().size);
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
}

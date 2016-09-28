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
	DateTime,
	now
}
class ConfigurationServiceTests(){
	test
	shared void testGetValueAsString(){
		value x = BasicConfigurationService({"string"->"value"});
		assertEquals(x.getValueAs<String>("string"),"value");
		assertNull(x.getValueAs<String>("nothere"));
	}
	
	test
	shared void testGetValueAsInteger(){
		value x = BasicConfigurationService({"key"->"5"});
		assertEquals(x.getValueAs<String>("key"),"5");
		assertEquals(x.getValueAs<Integer>("key"),5);
	}
	
	test
	shared void testGetValueAsDate(){
		value dt = now().dateTime();
		value x = BasicConfigurationService({"key"->dt.string});
		assertEquals(x.getValueAs<String>("key"),dt.string);
		assertEquals(x.getValueAs<DateTime>("key"),dt);
	}
	
	test
	shared void testParsePropertyFile(){
		value config = createFromFile(parsePath("resource/test.properties"));
		assertNotNull(config);
		if(exists config){
			assertEquals(3, config.getSnapshot().size);			
		}
	}
	
	test
	shared void testPropertyParsing(){
		//valid prop
		value actual = parseProp("a=1");
		assertEquals(["a","1"],actual);
		
		//test empty string on empty value
		value novalue = parseProp("b=");
		assertEquals(["b",""],novalue);
		
		//test missing key
		value nokey = parseProp("=3");
		assertEquals(null,nokey);
		
		//test multiple tokens in line
		value valueWithToken = parseProp("a=3=");
		assertEquals(["a","3="],valueWithToken);
		
		
		value whiteSpaceLine = parseProp(" ");
		assertEquals(null,whiteSpaceLine);
	}
}
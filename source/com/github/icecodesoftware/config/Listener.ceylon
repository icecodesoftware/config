"Interface to implement if a client wants to listen to property changes"
shared interface Listener{
  shared formal void onChange(String key,String? val,ChangeType changeType);
}

"Types of changes that a client can listen to"
shared abstract class ChangeType() of added|removed|changed|error{}

"Only fired if a property exists and the value changes"
shared object changed extends ChangeType() {}

"Only fired if a property is removed"
shared object removed extends ChangeType() {}

"Only fired if a property is added"
shared object added extends ChangeType() {}

"Fired if a property failed validation"
shared object error extends ChangeType() {}
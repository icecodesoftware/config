doc("Interface to implement if a client wants to listen to property changes")
shared interface Listener{
  shared formal void onChange(String key,String? val,ChangeType changeType);
}

doc("Types of changes that a client can listen to")
shared abstract class ChangeType() of added|removed|changed|error{}

doc("Only fired if a property exists and the value changes")
shared object changed extends ChangeType() {}

doc("Only fired if a property is removed")
shared object removed extends ChangeType() {}

doc("Only fired if a property is added")
shared object added extends ChangeType() {}

doc("Fired if a property failed validation")
shared object error extends ChangeType() {}
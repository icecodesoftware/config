doc("Interface to implement if a client wants to listen to property changes")

shared abstract class ChangeType() of added|removed|changed{}
shared object changed extends ChangeType() {}
shared object removed extends ChangeType() {}
shared object added extends ChangeType() {}

shared interface Listener{
  shared formal void onChange(String key,String? val,ChangeType changeType);
}
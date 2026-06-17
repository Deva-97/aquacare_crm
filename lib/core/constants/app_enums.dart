enum EntityType {
  customer('customers'),
  installation('installations'),
  serviceRequest('service_requests'),
  user('users');

  const EntityType(this.value);
  final String value;
}

enum SyncOperation {
  create('create'),
  update('update'),
  delete('delete');

  const SyncOperation(this.value);
  final String value;
}
